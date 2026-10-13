local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))
local LayerEditActions = require(TextureManipulation:WaitForChild("LayerEditActions"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))

local HistoryEditActions =
	require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("HistoryEditActions"))

local Actions = {}

local ActionProcessorMap = {
	-- Image Edit Actions
	[ActionUtils.ActionTypes.Recolor] = ImageEditActions.RecolorAction,
	[ActionUtils.ActionTypes.RecolorRegion] = ImageEditActions.RecolorRegionAction,
	[ActionUtils.ActionTypes.ApplyPBRToRegion] = ImageEditActions.ApplyPBRToRegionAction,
	[ActionUtils.ActionTypes.ClearBrush] = ImageEditActions.ClearBrushAction,
	[ActionUtils.ActionTypes.Sticker] = ImageEditActions.StickerAction,
	[ActionUtils.ActionTypes.ProjectedSticker] = ImageEditActions.ProjectedStickerAction,
	[ActionUtils.ActionTypes.TiledSticker] = ImageEditActions.TiledStickerAction,
	[ActionUtils.ActionTypes.RemoveSticker] = ImageEditActions.RemoveStickerAction,
	[ActionUtils.ActionTypes.Clear] = ImageEditActions.ClearAction,
	[ActionUtils.ActionTypes.ClearRegion] = ImageEditActions.ClearRegionAction,
	[ActionUtils.ActionTypes.ImageProjectionBrush] = ImageEditActions.ImageProjectionBrushAction,
	[ActionUtils.ActionTypes.BakeStamp] = ImageEditActions.BakeStampAction,
	[ActionUtils.ActionTypes.StampMerge] = ImageEditActions.StampMergeAction,

	-- Layer Edit Actions
	[ActionUtils.ActionTypes.AddLayer] = LayerEditActions.AddLayerAction,
	[ActionUtils.ActionTypes.DeleteLayer] = LayerEditActions.DeleteLayerAction,
	[ActionUtils.ActionTypes.SetTargetLayer] = LayerEditActions.SetTargetLayerAction,
	[ActionUtils.ActionTypes.MoveLayer] = LayerEditActions.MoveLayerAction,
	[ActionUtils.ActionTypes.SetLayerOpacity] = LayerEditActions.SetLayerOpacityAction,
	[ActionUtils.ActionTypes.SetLayerVisibility] = LayerEditActions.SetLayerVisibilityAction,
	[ActionUtils.ActionTypes.AddGroup] = LayerEditActions.AddGroupAction,
	[ActionUtils.ActionTypes.DeleteGroup] = LayerEditActions.DeleteGroupAction,
	[ActionUtils.ActionTypes.SetTargetGroup] = LayerEditActions.SetTargetGroupAction,
	[ActionUtils.ActionTypes.MoveGroup] = LayerEditActions.MoveGroupAction,
	[ActionUtils.ActionTypes.SetGroupVisibility] = LayerEditActions.SetGroupVisibilityAction,

	-- Mesh Edit Actions
	[ActionUtils.ActionTypes.UpdateWidgetPosition] = MeshEditActions.UpdateWidgetPositionAction,
	[ActionUtils.ActionTypes.UpdateAttachmentsPositions] = MeshEditActions.UpdateAttachmentsPositionsAction,
	[ActionUtils.ActionTypes.MergeKitbashPiece] = MeshEditActions.MergeKitbashPieceAction,
	[ActionUtils.ActionTypes.UpdateKitbashPiece] = MeshEditActions.UpdateKitbashPieceAction,
	[ActionUtils.ActionTypes.UnmergeKitbashPiece] = MeshEditActions.UnmergeKitbashPieceAction,
	[ActionUtils.ActionTypes.UpdateDeformedEditableMeshes] = MeshEditActions.UpdateDeformedEditableMeshesAction,
	[ActionUtils.ActionTypes.SetMakeupHead] = MeshEditActions.SetMakeupHeadAction,
	[ActionUtils.ActionTypes.SetAccessoryShapeControl] = MeshEditActions.SetAccessoryShapeControlAction,

	-- History Actions
	[ActionUtils.ActionTypes.Undo] = HistoryEditActions.UndoAction,
	[ActionUtils.ActionTypes.Redo] = HistoryEditActions.RedoAction,
	[ActionUtils.ActionTypes.ImageProjectionStrokeCompleted] = HistoryEditActions.AddStrokeAction,
}

function Actions.IsKnownActionType(actionType: string)
	return ActionProcessorMap[actionType] ~= nil
end

function Actions.IsValidAction(
	modelInfo: any,
	action: ActionUtils.Action,
	useReplayLayer: boolean?,
	historyTool: any?
): boolean
	if not Actions.IsKnownActionType(action.actionType) then
		return false
	end

	if
		not ActionProcessorMap[action.actionType].IsValidAction(
			modelInfo,
			action.actionMetaData,
			useReplayLayer,
			historyTool
		)
	then
		return false
	end

	return true
end

local function executeAction(
	modelInfo: any,
	action: ActionUtils.Action,
	useReplayLayer: boolean?,
	historyTool: any?,
	brushOverride: any?
): boolean
	if not Actions.IsValidAction(modelInfo, action, useReplayLayer, historyTool) then
		return false
	end

	ActionProcessorMap[action.actionType].ExecuteAction(
		modelInfo,
		action.actionMetaData,
		useReplayLayer,
		historyTool,
		brushOverride
	)

	return true
end

function Actions.ExecuteAction(
	modelInfo: any,
	action: ActionUtils.Action,
	useReplayLayer: boolean?,
	historyTool: any?,
	brushOverride: any?
): boolean
	local cache = modelInfo.textureInfo and modelInfo.textureInfo.editingCache
	-- Refreshing mesh snapshots does not read or modify texture images.
	if not cache or action.actionType == ActionUtils.ActionTypes.UpdateDeformedEditableMeshes then
		return executeAction(modelInfo, action, useReplayLayer, historyTool, brushOverride)
	end
	cache:BeginUse()
	local success, result = pcall(executeAction, modelInfo, action, useReplayLayer, historyTool, brushOverride)
	cache:EndUse()
	if not success then
		error(result, 0)
	end
	return result
end

return Actions
