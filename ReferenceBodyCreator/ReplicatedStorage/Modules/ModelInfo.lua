local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))
local Constants = require(Config:WaitForChild("Constants"))
local MakeupHeads = require(Config:WaitForChild("MakeupHeads"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushRegistry = require(Brushes:WaitForChild("BrushRegistry"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))
local MakeupGuideManager = require(TextureManipulation:WaitForChild("MakeupGuideManager"))
local MakeupMaskManager = require(TextureManipulation:WaitForChild("MakeupMaskManager"))

local Utils = require(Modules:WaitForChild("Utils"))
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MakeupProjectionUtils = require(MeshManipulation:WaitForChild("MakeupProjectionUtils"))
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

function ModelInfo.new(
	editableManager,
	model,
	blankData: BlanksData.BlankData,
	creationPrice: number?,
	makeupItemPrices: { [string]: number }?
): ModelInfoClass
	local self = setmetatable({}, ModelInfo)

	self.model = model
	self.blankData = blankData
	self.brushRegistry = BrushRegistry.new()
	self.makeupHeadSwapInProgress = false
	self.makeupHeadId = MakeupHeads.DefaultId
	self.makeupHeadInitialized = false

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
		return TextureInfo.new(editableManager, self.model, blankData)
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

	self.creationPrice = creationPrice or 0
	self.makeupItemPrices = makeupItemPrices or {}

	-- Bake the makeup group-composite masks up front
	if blankData.creationType == Constants.CREATION_TYPES.Makeup and not blankData.isMakeupAccessory then
		self.makeupMaskManager = MakeupMaskManager.new(self)
		local ok, err = pcall(function()
			self.makeupMaskManager:PrebakeAll()
		end)
		if not ok then
			warn("[ModelInfo] Makeup mask prebake failed; group composites will not be masked. " .. tostring(err))
		end

		if RunService:IsClient() then
			self.makeupGuideManager = MakeupGuideManager.new(self)
			local guideOk, guideErr = pcall(function()
				self.makeupGuideManager:PrebakeAll()
			end)
			if not guideOk then
				warn(
					"[ModelInfo] Makeup guide prebake failed; region guides will be unavailable. " .. tostring(guideErr)
				)
			end
		end
	end

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
	if self.textureInfo and self.textureInfo.editingCache then
		self.textureInfo.editingCache:Destroy()
	end
	for _, piece in self.placedPieces or {} do
		piece.meshPart:Destroy()
		piece.positionMarker:Destroy()
	end
	self.placedPieces = nil
	if self.accessoryEditSelections then
		for _, selection in self.accessoryEditSelections do
			if selection.editModelInfo then
				selection.editModelInfo:Destroy()
			end
			if selection.accessory then
				selection.accessory:Destroy()
			end
			if selection.previewMesh then
				selection.previewMesh:Destroy()
			end
		end
		table.clear(self.accessoryEditSelections)
	end

	if self.makeupDefaultHead then
		self.makeupDefaultHead:Destroy()
	end

	if self.brushRegistry then
		self.brushRegistry:Destroy()
	end

	if self.model then
		self.model:Destroy()
	end

	if self.meshInfo then
		self.meshInfo:Destroy()
	end
	if self.textureInfo then
		self.textureInfo:Destroy()
	end
	if self.makeupGuideManager then
		self.makeupGuideManager:Destroy()
	end
	if self.makeupMaskManager then
		self.makeupMaskManager:Destroy()
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

-- Preserve accessory edits when this head re-enters creation mode.
function ModelInfo:GetAccessoryEditSelections()
	if not self.accessoryEditSelections then
		self.accessoryEditSelections = {}
	end
	return self.accessoryEditSelections
end

function ModelInfo:SetServerEditTarget(target: string, revision: string)
	self.serverEditTarget = target
	self.serverEditRevision = revision
end

function ModelInfo:GetServerEditTarget(): string?
	return self.serverEditTarget
end

function ModelInfo:GetServerEditRevision(): string?
	return self.serverEditRevision
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
	return self.blankData.enableStickerPatterning and self.blankData.enableRegionalStickerPatterning
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

function ModelInfo:GetMakeupItemPrices(): { [string]: number }
	return self.makeupItemPrices
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

function ModelInfo:GetBrushRegistry(): BrushRegistry.BrushRegistryClass
	return self.brushRegistry
end

function ModelInfo:GetMeshInfo(): MeshInfo.MeshInfoClass
	return self.meshInfo
end

function ModelInfo:GetMakeupMaskManager(): MakeupMaskManager.MakeupMaskManagerClass?
	return self.makeupMaskManager
end

-- Keep the original head with the model, which survives closing and reopening the editor UI.
function ModelInfo:GetMakeupDefaultHead(): MeshPart
	if not self.makeupDefaultHead then
		local head = assert(self:GetMeshPartByName("Head"), "Missing editing head")
		self.makeupDefaultHead = MakeupProjectionUtils.CloneHead(head)
	end
	return self.makeupDefaultHead
end

function ModelInfo:GetMakeupHeadId(): string
	return self.makeupHeadId
end

function ModelInfo:SetMakeupHeadId(headId: string)
	self.makeupHeadId = headId
end

-- Each template starts with its own skin tone and retains the user's override on reentry.
function ModelInfo:GetMakeupHeadColor(headId: string): Color3?
	return self.makeupHeadColors and self.makeupHeadColors[headId]
end

function ModelInfo:SetMakeupHeadColor(headId: string, color: Color3)
	self.makeupHeadColors = self.makeupHeadColors or {}
	self.makeupHeadColors[headId] = color
end

function ModelInfo:GetMakeupHeadSwapInProgress(): boolean
	return self.makeupHeadSwapInProgress
end

function ModelInfo:SetMakeupHeadSwapInProgress(inProgress: boolean)
	self.makeupHeadSwapInProgress = inProgress
end

function ModelInfo:GetMakeupGuideManager(): MakeupGuideManager.MakeupGuideManagerClass?
	return self.makeupGuideManager
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
