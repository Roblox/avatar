local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))

export type Action = {
	actionType: string,
	actionMetaData: {},
}

local Actions = {}

Actions.ActionTypes = {
	-- Image Edit Actions
	Recolor = "Recolor",
	RecolorRegion = "RecolorRegion",
	BrushStroke = "BrushStroke",
	ClearBrush = "ClearBrush",
	LinearBrush = "LinearBrush",
	Sticker = "Sticker",
	ProjectedSticker = "ProjectedSticker",
	TiledSticker = "TiledSticker",
	RemoveSticker = "RemoveSticker",
	Clear = "Clear",
	ClearRegion = "ClearRegion",
	ProjectionBrush = "ProjectionBrush",

	-- Mesh Edit Actions
	UpdateWidgetPosition = "UpdateWidgetPosition",
	UpdateAttachmentsPositions = "UpdateAttachmentsPositions",
}

local ActionProcessorMap = {
	-- Image Edit Actions
	[Actions.ActionTypes.Recolor] = ImageEditActions.RecolorAction,
	[Actions.ActionTypes.RecolorRegion] = ImageEditActions.RecolorRegionAction,
	[Actions.ActionTypes.BrushStroke] = ImageEditActions.BrushStrokeAction,
	[Actions.ActionTypes.ClearBrush] = ImageEditActions.ClearBrushAction,
	[Actions.ActionTypes.LinearBrush] = ImageEditActions.LinearBrushAction,
	[Actions.ActionTypes.Sticker] = ImageEditActions.StickerAction,
	[Actions.ActionTypes.ProjectedSticker] = ImageEditActions.ProjectedStickerAction,
	[Actions.ActionTypes.TiledSticker] = ImageEditActions.TiledStickerAction,
	[Actions.ActionTypes.RemoveSticker] = ImageEditActions.RemoveStickerAction,
	[Actions.ActionTypes.Clear] = ImageEditActions.ClearAction,
	[Actions.ActionTypes.ClearRegion] = ImageEditActions.ClearRegionAction,
	[Actions.ActionTypes.ProjectionBrush] = ImageEditActions.ProjectionBrushAction,

	-- Mesh Edit Actions
	[Actions.ActionTypes.UpdateWidgetPosition] = MeshEditActions.UpdateWidgetPositionAction,
	[Actions.ActionTypes.UpdateAttachmentsPositions] = MeshEditActions.UpdateAttachmentsPositionsAction,
}

function Actions.CreateNewAction(actionType, actionMetaData)
	local newAction: Action = {
		actionType = actionType,
		actionMetaData = actionMetaData,
	}

	return newAction
end

function Actions.IsKnownActionType(actionType: string)
	return ActionProcessorMap[actionType] ~= nil
end

function Actions.IsValidAction(modelInfo, action: Action)
	if not Actions.IsKnownActionType(action.actionType) then
		return false
	end

	if not ActionProcessorMap[action.actionType].IsValidAction(modelInfo, action.actionMetaData) then
		return false
	end

	return true
end

function Actions.ExecuteAction(modelInfo, action: Action)
	if not Actions.IsValidAction(modelInfo, action) then
		return false
	end

	ActionProcessorMap[action.actionType].ExecuteAction(modelInfo, action.actionMetaData)

	return true
end

return Actions
