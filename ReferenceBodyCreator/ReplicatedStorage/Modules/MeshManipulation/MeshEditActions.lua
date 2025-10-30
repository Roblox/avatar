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
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshWidgetUtils = require(MeshManipulation:WaitForChild("MeshWidgetUtils"))
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local MeshEditActions = {}

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
	positionMarkerCFrame: CFrame,
	scale: number,
	rotation: number,
	atlasSlot: number?,
	hasDrawnToAtlas: boolean,
}

export type UnmergeKitbashPieceActionMetadata = {
	targetMeshPartName: string,
	mergedFaceIds: { number },
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
		if not actionMetaData.targetMeshPartName or not actionMetaData.kitbashMeshId then
			return false
		end
		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: MergeKitbashPieceActionMetadata)
		local meshInfo = modelInfo:GetMeshInfo()
		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		if not targetMeshPart then
			warn("Could not find target mesh part:", actionMetaData.targetMeshPartName)
			return
		end

		local editableMeshMap = meshInfo:GetKitbashEditableMeshMap()
		local targetEditableMesh = editableMeshMap[targetMeshPart]

		local meshScaleFactorMap = meshInfo:GetScaleFactorMap()
		local targetScaleFactor = meshScaleFactorMap[targetMeshPart]

		local baseTextureLayer = textureInfo:GetBaseLayer(targetMeshPart)

		local addedFaceIds = MeshUtils.MergeKitbashPiece({
			targetMeshPart = targetMeshPart,
			targetEditableMesh = targetEditableMesh,
			targetScaleFactor = targetScaleFactor,
			kitbashMeshId = actionMetaData.kitbashMeshId,
			kitbashTextureId = actionMetaData.kitbashTextureId,
			positionMarkerCFrame = targetMeshPart.CFrame:ToWorldSpace(actionMetaData.positionMarkerOffset),
			scale = actionMetaData.scale,
			rotation = actionMetaData.rotation,
			baseTextureLayer = baseTextureLayer,
			atlasSlot = actionMetaData.atlasSlot,
			hasDrawnToAtlas = actionMetaData.hasDrawnToAtlas,
		})

		if baseTextureLayer and not actionMetaData.hasDrawnToAtlas then
			textureInfo:UpdateOutputColorMap(targetMeshPart)
		end
	end,
}

MeshEditActions.UnmergeKitbashPieceAction = {
	IsValidAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UnmergeKitbashPieceActionMetadata)
		if not actionMetaData.targetMeshPartName or not actionMetaData.mergedFaceIds then
			return false
		end
		if #actionMetaData.mergedFaceIds == 0 then
			return false
		end
		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: UnmergeKitbashPieceActionMetadata)
		local meshInfo = modelInfo:GetMeshInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		if not targetMeshPart then
			warn("Could not find target mesh part:", actionMetaData.targetMeshPartName)
			return
		end

		local editableMeshMap = meshInfo:GetKitbashEditableMeshMap()
		local targetEditableMesh = editableMeshMap[targetMeshPart]

		-- Remove merged geometry by removing all added faces and cleaning
		-- up unused vertices
		for _, faceId in actionMetaData.mergedFaceIds do
			targetEditableMesh:RemoveFace(faceId)
		end
		targetEditableMesh:RemoveUnused()

		-- If we intend to delete the kitbash piece from the creation, remove the
		-- texture from the atlas
		if actionMetaData.atlasSlot then
			local textureInfo = modelInfo:GetTextureInfo()
			local brushLayer, _ = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.BRUSH_LAYER)

			local atlasSize = brushLayer.Size
			local slotInfo = Constants.ATLAS_SLOTS[actionMetaData.atlasSlot]
			local slotScale = 1.0 / Constants.ATLAS_GRID_SIZE
			local slotWidth = atlasSize.X * slotScale
			local slotHeight = atlasSize.Y * slotScale
			local slotX = atlasSize.X * slotInfo.uOffset
			local slotY = atlasSize.Y * slotInfo.vOffset

			brushLayer:DrawRectangle(
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

return MeshEditActions
