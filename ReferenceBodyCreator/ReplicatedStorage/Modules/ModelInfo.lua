local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))
local Constants = require(Config:WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local Utils = require(Modules:WaitForChild("Utils"))
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

	-- Resize accessories so the editable mesh is generated correctly
	AccessoryUtils.AddOriginalSizes(self.model)
	AccessoryUtils.ResizeAccessoriesForDisplay(self.model)

	self.meshInfo = MeshInfo.new(self.model, blankData)
	if blankData.creationType == Constants.CREATION_TYPES.Body then
		MeshWidgetUtils.FixupWidgets(self.meshInfo)
	end

	-- If TextureInfo fails setting up EditableImages,
	-- destroy the current model in order to support freeing
	-- memory and retrying with lower resolution EditableImages.
	local success, result = pcall(function()
		return TextureInfo.new(self.model, blankData)
	end)
	if not success then
		self:Destroy()
		error(result)
	end
	self.textureInfo = result

	self.meshParts = {}
	for _, meshPart in pairs(self.model:GetDescendants()) do
		if not meshPart:IsA("MeshPart") then
			continue
		end

		if meshPart.Name == "PrimaryPart" then
			continue
		end

		-- Only include parts of the model that we want to edit.
		if not blankData.individualPartsNames[meshPart.Name] then
			continue
		end

		table.insert(self.meshParts, meshPart)
	end

	AttachmentUtils.AddOriginalPositions(self.model)

	AttachmentUtils.MoveAccessoriesToAttachmentPoints(self.model)

	self:InitializeMeshPartPositions()

	self.initialModelCFrame = self.model:GetPrimaryPartCFrame()

	self.creationPrice = Utils:getPriceForCreation(self:GetCreationToken())

	return self
end

-- Gets the name of region parts, along with the model name.
function ModelInfo:GetRegionPartsList()
	local regionMapSubParts = self.blankData.regionMapSubParts
	local modelName = self.blankData.name

	local partNames = {}

	-- Add whole body region
	table.insert(partNames, modelName)

	-- Get list of partNames from regionMap
	for partName, _ in regionMapSubParts do
		table.insert(partNames, partName)
	end

	return partNames
end

function ModelInfo:GetInitialModelCFrame()
	return self.initialModelCFrame
end

function ModelInfo:Destroy()
	if self.model then
		self.model:Destroy()
	end

	if self.meshInfo then
		self.meshInfo:Destroy()
	end
	if self.textureInfo then
		self.textureInfo:Destroy()
	end
end

function ModelInfo:GetModel()
	return self.model
end

function ModelInfo:GetBlankName()
	return self.blankData.name
end

function ModelInfo:GetCreationType()
	return self.blankData.creationType
end

function ModelInfo:GetKitbashingEnabled()
	return self.blankData.enableKitbashing
end

function ModelInfo:GetStickerPatterningEnabled()
	return self.blankData.enableStickerPatterning
end

function ModelInfo:GetWidgetMeshEditingEnabled()
	return self.blankData.enableWidgetMeshEditing
end

function ModelInfo:GetRegionalStickerPatterningEnabled()
	-- Disable regional sticker patterning on accessories
	return self:GetCreationType() ~= Constants.CREATION_TYPES.Accessory
end

function ModelInfo:GetPreviewScale()
	return self.blankData.previewScale
end

function ModelInfo:GetCreationToken()
	return Utils.getToken(game.GameId, self.blankData.avatarAssetType)
end

function ModelInfo:GetAvatarAssetType()
	if self.blankData.avatarAssetType then
		return self.blankData.avatarAssetType
	else
		return nil
	end
end

function ModelInfo:GetCreationPrice()
	return self.creationPrice
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

function ModelInfo:SaveAppliedStickers(stickers: { any })
	self.stickers = stickers
end

function ModelInfo:GetAppliedStickers(): { any }
	return self.stickers or {}
end

function ModelInfo:SavePlacedKitbashPieces(placedPieces: { any })
	self.placedPieces = placedPieces
end

function ModelInfo:GetPlacedKitbashPieces(): { any }
	return self.placedPieces or {}
end

export type ModelInfoClass = typeof(ModelInfo)

return ModelInfo
