-- This tool is responsible for changing the base color of a given item
-- Eventually we would like to be able to change base Roughness/Metalness/Normals as well, but support for this is a long way off.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Actions = require(Modules:WaitForChild("Actions"))
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local FabricTool = {}
FabricTool.__index = FabricTool

function FabricTool.new(modelInfo: ModelInfo.ModelInfoClass)
	local self = {}
	setmetatable(self, FabricTool)

	self.modelInfo = modelInfo

	self.selectedRegionName = nil

	return self
end

function FabricTool:ApplyColorRegion(color, isFinalInput)
	local recolorActionMetadata: ImageEditActions.RecolorRegionActionMetadata = {
		regionName = self.selectedRegionName,
		color = color,
	}

	local recolorAction = Actions.CreateNewAction(Actions.ActionTypes.RecolorRegion, recolorActionMetadata)

	Actions.ExecuteAction(self.modelInfo, recolorAction)

	if isFinalInput then
		SendActionToServerEvent:FireServer(recolorAction)
	end

	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
	local region: TextureInfo.Region = textureInfo:GetRegion(self.selectedRegionName)
	local uniqueLayersForMeshParts = textureInfo:GetUniqueLayerMapForMeshPartNames(region.meshPartNames)

	for meshPart, _ in uniqueLayersForMeshParts do
		textureInfo:UpdateOutputColorMap(meshPart)
	end
end

function FabricTool:ApplyColor(color, isFinalInput)
	if self.selectedRegionName then
		self:ApplyColorRegion(color, isFinalInput)
		return
	end

	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	local uniqueLayerMap = textureInfo:GetUniqueLayerMap()
	for meshPart, _ in uniqueLayerMap do
		local recolorActionMetadata: ImageEditActions.RecolorActionMetadata = {
			targetMeshPartName = meshPart.Name,
			color = color,
		}

		local recolorAction = Actions.CreateNewAction(Actions.ActionTypes.Recolor, recolorActionMetadata)

		Actions.ExecuteAction(self.modelInfo, recolorAction)

		if isFinalInput then
			SendActionToServerEvent:FireServer(recolorAction)
		end

		textureInfo:UpdateOutputColorMap(meshPart)
	end
end

function FabricTool:ClearAll()
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	local uniqueLayerMap = textureInfo:GetUniqueLayerMap()
	for meshPart, _ in uniqueLayerMap do
		local clearActionMetadata: ImageEditActions.ClearActionMetadata = {
			targetMeshPartName = meshPart.Name,
		}

		local clearAction = Actions.CreateNewAction(Actions.ActionTypes.Clear, clearActionMetadata)

		Actions.ExecuteAction(self.modelInfo, clearAction)

		SendActionToServerEvent:FireServer(clearAction)

		textureInfo:UpdateOutputColorMap(meshPart)
	end
end

function FabricTool:SetSelectedRegion(regionName: string)
	if regionName and string.find(regionName, "Model") then
		self.selectedRegionName = nil
		return
	end

	self.selectedRegionName = regionName
end

function FabricTool:Destroy() end

return FabricTool
