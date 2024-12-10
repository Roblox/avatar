-- This is a module script that processes actions for editing meshes. It should be used by both the client and the server.
-- A mesh edit action consists of:
--   - The set of all widgets that modify this mesh (each widget contains a start pos/end pos)
-- Whenever any of these values change, both the client and the server should call into this module to perform the action and update their respective meshes.
-- In addition to action data, the functions in this module also take an EditableMesh as a parameter.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshWidgetUtils = require(MeshManipulation:WaitForChild("MeshWidgetUtils"))

local MeshEditActions = {}

export type UpdateWidgetPositionActionMetadata = {
	widgetName: string,

	newPosition: Vector3,

	newActiveControl: number?,
	newLinearProgress: number?,
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

return MeshEditActions
