-- This is a module script that processes actions for editing meshes. It should be used by both the client and the server.
-- A mesh edit action consists of:
--   - The set of all widgets that modify this mesh (each widget contains a start pos/end pos)
-- Whenever any of these values change, both the client and the server should call into this module to perform the action and update their respective meshes.
-- In addition to action data, the functions in this module also take an EditableMesh as a parameter.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MakeupProjectionUtils = require(MeshManipulation:WaitForChild("MakeupProjectionUtils"))
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshWidgetUtils = require(MeshManipulation:WaitForChild("MeshWidgetUtils"))
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local KitbashData = require(Config:WaitForChild("KitbashData"))
local MakeupHeads = require(Config:WaitForChild("MakeupHeads"))

local MeshEditActions = {}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

export type SetAccessoryShapeControlMetadata = {
	targetMeshPartName: string,
	controlId: string,
	value: number,
}

MeshEditActions.SetAccessoryShapeControlAction = {
	IsValidAction = function(modelInfo, metadata): boolean
		if
			type(metadata) ~= "table"
			or type(metadata.targetMeshPartName) ~= "string"
			or type(metadata.controlId) ~= "string"
			or not Constants.MAKEUP_ACCESSORY_ASSET_TYPES[modelInfo:GetServerEditTarget()]
		then
			return false
		end
		local part = modelInfo:GetMeshPartByName(metadata.targetMeshPartName)
		local meshInfo = part and modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
		return meshInfo ~= nil
			and meshInfo.accessoryShape ~= nil
			and meshInfo.accessoryShape:IsValidValue(metadata.controlId, metadata.value)
			and meshInfo.cageInfo ~= nil
			and meshInfo.cageInfo.isWrapLayer == true
	end,
	ExecuteAction = function(modelInfo, metadata: SetAccessoryShapeControlMetadata, _, historyTool)
		local meshInfoClass = modelInfo:GetMeshInfo()
		local meshInfo = meshInfoClass:GetMeshInfoByName(metadata.targetMeshPartName)
		if not meshInfo.accessoryShape:SetValue(meshInfo, metadata.controlId, metadata.value) then
			return
		end
		meshInfoClass:MarkMeshPartDirty(meshInfo.meshPart)
		-- Projected texture strokes cannot be replayed against a different shape.
		if historyTool then
			historyTool:clear()
		end
	end,
}

export type UpdateWidgetPositionActionMetadata = {
	widgetName: string,

	newPosition: Vector3,

	newActiveControl: number?,
	newLinearProgress: number?,
}

export type MergeKitbashPieceActionMetadata = {
	targetMeshPartName: string,
	kitbashMeshId: string,
	kitbashTextureId: string,
	kitbashSourcePart: MeshPart?,
	positionMarkerOffset: CFrame,
	scale: number,
	rotation: number,
	atlasSlot: number,
	hasDrawnToAtlas: boolean,
}

export type UnmergeKitbashPieceActionMetadata = {
	targetMeshPartName: string,
	pieceSlot: number,
	atlasSlot: number?,
}

local function UpdateDeformedMeshes(meshInfoClass: MeshInfo.MeshInfoClass, deformedPartName: string)
	local meshInfo: MeshInfo.MeshInfo = meshInfoClass:GetMeshInfoByName(deformedPartName)

	local deformedPositions =
		MeshWidgetUtils.GetDeformedMeshData(meshInfoClass, meshInfoClass:GetAllWidgets(), deformedPartName)

	local updatedVertex = false
	assert(meshInfo.cageInfo ~= nil, "Cage info is nil")
	local cageMesh = meshInfo.cageInfo.cageEditableMesh
	for vertexId, vertexPos in deformedPositions do
		cageMesh:SetPosition(vertexId, vertexPos)
		updatedVertex = true
	end

	if updatedVertex then
		meshInfoClass:MarkMeshPartDirty(meshInfo.meshPart)
	end
end

local function UpdateWidgetInfo(
	meshInfoClass: MeshInfo.MeshInfoClass,
	updatedWidget: MeshInfo.WidgetData,
	actionMetaData: UpdateWidgetPositionActionMetadata
)
	if actionMetaData.newActiveControl then
		updatedWidget.activeControl = updatedWidget.controls[actionMetaData.newActiveControl]
		if not updatedWidget.activeControl then
			warn("Active control not found for widget: ", updatedWidget.name)
		end
	end

	if actionMetaData.newLinearProgress and updatedWidget.activeControl then
		local activeLineControl = updatedWidget.activeControl :: MeshInfo.LineWidgetControl
		activeLineControl.linearProgress = actionMetaData.newLinearProgress
	end

	if actionMetaData.newPosition then
		updatedWidget.position = actionMetaData.newPosition
	end

	for _, deformedPartName in updatedWidget.deformsPartNames do
		UpdateDeformedMeshes(meshInfoClass, deformedPartName)
	end
end

local function CheckMirrorWidget(
	meshInfoClass: MeshInfo.MeshInfoClass,
	updatedWidget: MeshInfo.WidgetData,
	actionMetaData: UpdateWidgetPositionActionMetadata
)
	if updatedWidget.mirroredWidget then
		local mirroredPosition = actionMetaData.newPosition * Vector3.new(-1, 1, 1)

		local mirroredActionMetaData: UpdateWidgetPositionActionMetadata = {
			widgetName = updatedWidget.mirroredWidget.name,
			newPosition = mirroredPosition,
			newActiveControl = actionMetaData.newActiveControl,
			newLinearProgress = actionMetaData.newLinearProgress,
		}

		UpdateWidgetInfo(meshInfoClass, updatedWidget.mirroredWidget, mirroredActionMetaData)
	end
end

MeshEditActions.UpdateWidgetPositionAction = {
	IsValidAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UpdateWidgetPositionActionMetadata)
		local meshInfoClass: MeshInfo.MeshInfoClass = modelInfo:GetMeshInfo()

		if not meshInfoClass:HasWidgetByName(actionMetaData.widgetName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UpdateWidgetPositionActionMetadata)
		local meshInfoClass: MeshInfo.MeshInfoClass = modelInfo:GetMeshInfo()

		local updatedWidget: MeshInfo.WidgetData = meshInfoClass:GetWidgetByName(actionMetaData.widgetName)
		UpdateWidgetInfo(meshInfoClass, updatedWidget, actionMetaData)

		CheckMirrorWidget(meshInfoClass, updatedWidget, actionMetaData)
	end,
}

-- This is an action so that we keep the server and client in sync
export type UpdateAttachmentsPositionsActionMetadata = {
	-- No metadata needed for this action
}

MeshEditActions.UpdateAttachmentsPositionsAction = {
	IsValidAction = function(
		modelInfo: ModelInfo.ModelInfoClass,
		actionMetaData: UpdateAttachmentsPositionsActionMetadata
	)
		return true
	end,
	ExecuteAction = function(
		modelInfo: ModelInfo.ModelInfoClass,
		actionMetaData: UpdateAttachmentsPositionsActionMetadata
	)
		local model = modelInfo:GetModel()

		AttachmentUtils.UpdateAccessoryAttachmentsPositions(model)

		AttachmentUtils.MoveAccessoriesToAttachmentPoints(model)
	end,
}

MeshEditActions.MergeKitbashPieceAction = {
	IsValidAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: MergeKitbashPieceActionMetadata)
		if
			not modelInfo:GetKitbashingEnabled()
			or not actionMetaData.targetMeshPartName
			or not actionMetaData.kitbashMeshId
		then
			return false
		end
		local part = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local slot = actionMetaData.atlasSlot
		if not part or not Constants.ATLAS_SLOTS[slot] then
			return false
		end
		if actionMetaData.kitbashSourcePart ~= nil then
			local isMakeup = Constants.MAKEUP_ACCESSORY_ASSET_TYPES[modelInfo:GetServerEditTarget()] == true
			local found = false
			for _, entry in KitbashData.GetPieces(isMakeup) do
				if entry.sourcePart == actionMetaData.kitbashSourcePart then
					found = entry.sourcePart.MeshId == actionMetaData.kitbashMeshId
					break
				end
			end
			if not found then
				return false
			end
		end
		local info = modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
		local faceIds = info and info.kitbashFacesBySlot and info.kitbashFacesBySlot[slot]
		return info ~= nil and (not faceIds or #faceIds == 0)
	end,
	ExecuteAction = function(
		modelInfo: ModelInfo.ModelInfoClass,
		actionMetaData: MergeKitbashPieceActionMetadata,
		_,
		historyTool
	)
		local meshInfo = modelInfo:GetMeshInfo()
		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		if not targetMeshPart then
			warn("Could not find target mesh part:", actionMetaData.targetMeshPartName)
			return
		end

		local info = meshInfo:GetModelMeshInfo()[targetMeshPart]
		local targetEditableMesh = info.kitbashEditableMesh or info.editableMesh

		local baseTextureLayer = textureInfo:GetBaseLayer(targetMeshPart)

		local addedFaceIds, sourcePositions = MeshUtils.MergeKitbashPiece({
			editableManager = textureInfo.editableManager,
			targetMeshPart = targetMeshPart,
			targetEditableMesh = targetEditableMesh,
			targetScaleFactor = info.scaleFactor,
			kitbashMeshId = actionMetaData.kitbashMeshId,
			kitbashTextureId = actionMetaData.kitbashTextureId,
			kitbashSourcePart = actionMetaData.kitbashSourcePart,
			positionMarkerCFrame = targetMeshPart.CFrame:ToWorldSpace(actionMetaData.positionMarkerOffset),
			scale = actionMetaData.scale,
			rotation = actionMetaData.rotation,
			baseTextureLayer = baseTextureLayer,
			atlasSlot = actionMetaData.atlasSlot,
			hasDrawnToAtlas = actionMetaData.hasDrawnToAtlas,
			useSkinningTransfer = Constants.MAKEUP_ACCESSORY_ASSET_TYPES[modelInfo:GetServerEditTarget()] == true,
		})
		-- Face IDs belong to this EditableMesh; never use client IDs on the server.
		info.kitbashFacesBySlot = info.kitbashFacesBySlot or {}
		info.kitbashFacesBySlot[actionMetaData.atlasSlot] = addedFaceIds
		info.kitbashVerticesBySlot = info.kitbashVerticesBySlot or {}
		info.kitbashVerticesBySlot[actionMetaData.atlasSlot] = sourcePositions
		meshInfo:RefreshKitbashMesh(targetMeshPart)
		if historyTool then
			historyTool:clear()
		end

		if baseTextureLayer and not actionMetaData.hasDrawnToAtlas then
			textureInfo:UpdateOutputColorMap(targetMeshPart)
		end
	end,
}

MeshEditActions.UpdateKitbashPieceAction = {
	IsValidAction = function(modelInfo, metadata)
		if
			not modelInfo:GetKitbashingEnabled()
			or not Constants.MAKEUP_ACCESSORY_ASSET_TYPES[modelInfo:GetServerEditTarget()]
			or type(metadata) ~= "table"
			or type(metadata.targetMeshPartName) ~= "string"
			or typeof(metadata.positionMarkerOffset) ~= "CFrame"
			or not isFiniteNumber(metadata.scale)
			or metadata.scale <= 0
			or not isFiniteNumber(metadata.rotation)
		then
			return false
		end
		for _, component in { metadata.positionMarkerOffset:GetComponents() } do
			if not isFiniteNumber(component) then
				return false
			end
		end
		local part = modelInfo:GetMeshPartByName(metadata.targetMeshPartName)
		local info = part and modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
		return info ~= nil
			and info.kitbashVerticesBySlot ~= nil
			and info.kitbashVerticesBySlot[metadata.pieceSlot] ~= nil
	end,
	ExecuteAction = function(modelInfo, metadata, _, historyTool)
		local meshInfo = modelInfo:GetMeshInfo()
		local part = modelInfo:GetMeshPartByName(metadata.targetMeshPartName)
		local info = meshInfo:GetModelMeshInfo()[part]
		MeshUtils.UpdateKitbashVertices(
			info.kitbashEditableMesh,
			info.kitbashVerticesBySlot[metadata.pieceSlot],
			metadata.positionMarkerOffset,
			metadata.scale,
			metadata.rotation,
			info.scaleFactor
		)
		meshInfo:RefreshKitbashMesh(part)
		if historyTool then
			historyTool:clear()
		end
	end,
}

MeshEditActions.UnmergeKitbashPieceAction = {
	IsValidAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UnmergeKitbashPieceActionMetadata)
		if not modelInfo:GetKitbashingEnabled() or not actionMetaData.targetMeshPartName then
			return false
		end
		local part = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		if not part then
			return false
		end
		local info = modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
		return info ~= nil
			and info.kitbashFacesBySlot ~= nil
			and info.kitbashFacesBySlot[actionMetaData.pieceSlot] ~= nil
			and (#info.kitbashFacesBySlot[actionMetaData.pieceSlot] > 0 or actionMetaData.atlasSlot ~= nil)
			and (actionMetaData.atlasSlot == nil or actionMetaData.atlasSlot == actionMetaData.pieceSlot)
	end,
	ExecuteAction = function(
		modelInfo: ModelInfo.ModelInfoClass,
		actionMetaData: UnmergeKitbashPieceActionMetadata,
		_,
		historyTool
	)
		local meshInfo = modelInfo:GetMeshInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		if not targetMeshPart then
			warn("Could not find target mesh part:", actionMetaData.targetMeshPartName)
			return
		end

		local info = meshInfo:GetModelMeshInfo()[targetMeshPart]
		local targetEditableMesh = info.kitbashEditableMesh or info.editableMesh
		local faceIds = info.kitbashFacesBySlot[actionMetaData.pieceSlot]

		-- Remove merged geometry by removing all added faces and cleaning
		-- up unused vertices
		for _, faceId in faceIds do
			targetEditableMesh:RemoveFace(faceId)
		end
		-- Keep the atlas slot deletable while its geometry is unmerged.
		table.clear(faceIds)
		if info.kitbashVerticesBySlot then
			info.kitbashVerticesBySlot[actionMetaData.pieceSlot] = nil
		end
		info.kitbashFacesBySlot[actionMetaData.pieceSlot] = if actionMetaData.atlasSlot then nil else faceIds
		targetEditableMesh:RemoveUnused()
		meshInfo:RefreshKitbashMesh(targetMeshPart)
		if historyTool then
			historyTool:clear()
		end

		-- If we intend to delete the kitbash piece from the creation, remove the
		-- texture from the atlas
		if actionMetaData.atlasSlot then
			local textureInfo = modelInfo:GetTextureInfo()
			local baseLayer = textureInfo:GetBaseLayer(targetMeshPart)

			local atlasSize = baseLayer.Size
			local slotInfo = Constants.ATLAS_SLOTS[actionMetaData.atlasSlot]
			local slotScale = 1.0 / Constants.ATLAS_GRID_SIZE
			local slotWidth = atlasSize.X * slotScale
			local slotHeight = atlasSize.Y * slotScale
			local slotX = atlasSize.X * slotInfo.uOffset
			local slotY = atlasSize.Y * slotInfo.vOffset

			baseLayer:DrawRectangle(
				Vector2.new(slotX, slotY),
				Vector2.new(slotWidth, slotHeight),
				Color3.new(0, 0, 0),
				1,
				Enum.ImageCombineType.Overwrite
			)

			textureInfo:UpdateOutputColorMap(targetMeshPart)
		end
	end,
}

-- This is an action so that we keep the server and client in sync
export type UpdateDeformedEditableMeshesMetadata = {
	-- No metadata needed for this action
}

MeshEditActions.UpdateDeformedEditableMeshesAction = {
	IsValidAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UpdateDeformedEditableMeshesMetadata)
		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UpdateDeformedEditableMeshesMetadata)
		local meshInfo: MeshInfo.MeshInfoClass = modelInfo:GetMeshInfo()
		meshInfo:UpdateDeformedEditableMeshes()
	end,
}

MeshEditActions.SetMakeupHeadAction = {
	-- Checks that the action targets makeup and the selected head supports transfer.
	IsValidAction = function(modelInfo, metadata): boolean
		if
			modelInfo:GetCreationType() ~= Constants.CREATION_TYPES.Makeup
			or typeof(metadata) ~= "table"
			or typeof(metadata.headId) ~= "string"
			or not MakeupHeads.GetOption(metadata.headId)
		then
			return false
		end
		if metadata.headId ~= MakeupHeads.DefaultId then
			return typeof(metadata.sourceHead) == "Instance"
				and metadata.sourceHead:IsA("MeshPart")
				and metadata.sourceHead:FindFirstChildOfClass("WrapTarget") ~= nil
		end
		return true
	end,

	-- Applies the head swap on the server, refreshes projection data, and clears geometry-dependent history.
	ExecuteAction = function(modelInfo, metadata, _, historyTool)
		local head = assert(modelInfo:GetMeshPartByName("Head"), "Missing editing head")
		local defaultHead = modelInfo:GetMakeupDefaultHead()
		local source = if metadata.headId == MakeupHeads.DefaultId then defaultHead else metadata.sourceHead
		local sourceCopy = MakeupProjectionUtils.CloneHead(source)
		MakeupProjectionUtils.ApplyHead(head, sourceCopy)
		sourceCopy:Destroy()
		local transfer = head:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME, true)
		assert(transfer and transfer:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")
		transfer:PrepareProjectionMeshDataAsync()
		modelInfo:SetMakeupHeadId(metadata.headId)
		modelInfo:GetMeshInfo():GetModelMeshInfo()[head].scaleFactor = head.MeshSize / head.Size
		historyTool:clear()
	end,
}

return MeshEditActions
