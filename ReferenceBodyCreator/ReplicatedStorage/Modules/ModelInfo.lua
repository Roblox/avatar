local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshWidgetUtils = require(MeshManipulation:WaitForChild("MeshWidgetUtils"))

local ModelInfo = {}
ModelInfo.__index = ModelInfo

local function BuildMeshPartsByNameMap(model)
	local meshPartsByNameMap = {}

	for _, meshPart in model:GetDescendants() do
		if meshPart:IsA("MeshPart") then
			if meshPartsByNameMap[meshPart.Name] then
				error("Error setting up model: Multiple MeshParts with the same name " .. meshPart.Name .. " found.")
			end

			meshPartsByNameMap[meshPart.Name] = meshPart
		end
	end

	return meshPartsByNameMap
end

local function BuildOriginalTextureIdMap(model)
	local originalTextureIdMap = {}

	for _, meshPart in model:GetDescendants() do
		if meshPart:IsA("MeshPart") then
			originalTextureIdMap[meshPart] = meshPart.TextureID
		end
	end

	return originalTextureIdMap
end

function ModelInfo:InitializeMeshPartPositions()
	local modelPositionMarker = game.Workspace:WaitForChild("ModelPositionMarker")
	modelPositionMarker.Transparency = 1

	local primaryPart = self.model.PrimaryPart
	assert(primaryPart ~= nil, "Model " .. self.blankData.sourceModel.Name .. " does not have a PrimaryPart")
	local originalPrimaryPartPosition: Vector3 = primaryPart.CFrame.Position

	for _, child in pairs(self.model:GetDescendants()) do
		if child:IsA("MeshPart") then
			child.Anchored = true

			local offset = child.Position - originalPrimaryPartPosition
			child.Position = modelPositionMarker.CFrame.Position
				+ offset
				+ Vector3.new(0, 0, self.blankData.initialZOffset)
		end
	end
end

function ModelInfo.new(model, blankData: BlanksData.BlankData): ModelInfoClass
	local self = setmetatable({}, ModelInfo)

	self.model = model
	self.blankData = blankData

	self.meshPartsByNameMap = BuildMeshPartsByNameMap(model)
	self.originalTextureIdMap = BuildOriginalTextureIdMap(model)

	self.meshInfo = MeshInfo.new(self.model, blankData)
	MeshWidgetUtils.FixupWidgets(self.meshInfo)

	self.textureInfo = TextureInfo.new(self.model, blankData)

	self.meshParts = {}
	for _, meshPart in pairs(self.model:GetDescendants()) do
		if not meshPart:IsA("MeshPart") then
			continue
		end

		if meshPart.Name == "PrimaryPart" then
			continue
		end

		table.insert(self.meshParts, meshPart)
	end

	AccessoryUtils.AddOriginalSizes(self.model)
	AccessoryUtils.ResizeAccessoriesForDisplay(self.model)

	AttachmentUtils.AddOriginalPositions(self.model)

	AttachmentUtils.MoveAccessoriesToAttachmentPoints(self.model)

	self:InitializeMeshPartPositions()

	self.initialModelCFrame = self.model:GetModelCFrame()

	return self
end

function ModelInfo:GetInitialModelCFrame()
	return self.initialModelCFrame
end

function ModelInfo:Destroy()
	self.model:Destroy()

	self.meshInfo:Destroy()
	self.textureInfo:Destroy()
end

function ModelInfo:GetModel()
	return self.model
end

function ModelInfo:GetBlankName()
	return self.blankData.name
end

function ModelInfo:GetHumanoidDescription()
	return self.model:FindFirstChildWhichIsA("HumanoidDescription")
end

function ModelInfo:UpdateOutputColorMap()
	for meshPart, _ in self.textureInfo:GetUniqueLayerMap() do
		self.textureInfo:UpdateOutputColorMap(meshPart)
	end
end

function ModelInfo:GetTextureInfo(): TextureInfo.TextureInfoClass
	return self.textureInfo
end

function ModelInfo:GetMeshInfo(): MeshInfo.MeshInfoClass
	return self.meshInfo
end

function ModelInfo:GetMeshPartByName(meshPartName: string?): MeshPart?
	if not meshPartName then
		return nil
	end

	return self.meshPartsByNameMap[meshPartName]
end

function ModelInfo:GetOriginalTextureId(meshPart: MeshPart?): string?
	if not meshPart then
		return nil
	end

	return self.originalTextureIdMap[meshPart]
end

function ModelInfo:GetMeshParts(): { MeshPart }
	return self.meshParts
end

function ModelInfo:SaveAppliedStickers(stickers: {any})
	self.stickers = stickers
end

function ModelInfo:GetAppliedStickers(): {any}
	return self.stickers or {}
end

export type ModelInfoClass = typeof(ModelInfo)

return ModelInfo
