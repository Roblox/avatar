--[[
	ActionsUtils defines the types of actions and how to create one. This is outside Actions.lua to allow
	for actions to create other actions (avoiding any circular dependencies).
]]

export type Action = {
	actionType: string,
	actionMetaData: {},
	serverEditTarget: string?,
	serverEditRevision: string?,
}

local ActionUtils = {}

ActionUtils.ActionTypes = {
	-- Image Edit Actions
	Recolor = "Recolor",
	RecolorRegion = "RecolorRegion",
	ApplyPBRToRegion = "ApplyPBRToRegion",
	ClearBrush = "ClearBrush",
	Sticker = "Sticker",
	ProjectedSticker = "ProjectedSticker",
	TiledSticker = "TiledSticker",
	RemoveSticker = "RemoveSticker",
	Clear = "Clear",
	ClearRegion = "ClearRegion",
	ImageProjectionBrush = "ImageProjectionBrush",
	BakeStamp = "BakeStamp",
	-- Local-only replay action for undoing a baked stamp; never sent over the network.
	StampMerge = "StampMerge",

	-- Layer Edit Actions
	AddLayer = "AddLayer",
	DeleteLayer = "DeleteLayer",
	SetTargetLayer = "SetTargetLayer",
	MoveLayer = "MoveLayer",
	SetLayerOpacity = "SetLayerOpacity",
	SetLayerVisibility = "SetLayerVisibility",
	AddGroup = "AddGroup",
	DeleteGroup = "DeleteGroup",
	SetTargetGroup = "SetTargetGroup",
	MoveGroup = "MoveGroup",
	SetGroupVisibility = "SetGroupVisibility",

	-- Mesh Edit Actions
	UpdateWidgetPosition = "UpdateWidgetPosition",
	UpdateAttachmentsPositions = "UpdateAttachmentsPositions",
	MergeKitbashPiece = "MergeKitbashPiece",
	UpdateKitbashPiece = "UpdateKitbashPiece",
	UnmergeKitbashPiece = "UnmergeKitbashPiece",
	UpdateDeformedEditableMeshes = "UpdateDeformedEditableMeshes",
	SetMakeupHead = "SetMakeupHead",
	SetAccessoryShapeControl = "SetAccessoryShapeControl",

	-- History Actions
	Undo = "Undo",
	Redo = "Redo",
	ImageProjectionStrokeCompleted = "ImageProjectionStrokeCompleted",
}

function ActionUtils.CreateNewAction(actionType, actionMetaData, modelInfo: any?)
	local newAction: Action = {
		actionType = actionType,
		actionMetaData = actionMetaData,
		serverEditTarget = if modelInfo then modelInfo:GetServerEditTarget() else nil,
		serverEditRevision = if modelInfo then modelInfo:GetServerEditRevision() else nil,
	}

	return newAction
end

return ActionUtils
