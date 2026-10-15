--!strict

--[[
	HistoryTool actions for undo/redo replication on the server
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local ImageEditActions = require(Modules:WaitForChild("TextureManipulation"):WaitForChild("ImageEditActions"))

type HistoryTool = any

local HistoryEditActions = {}

HistoryEditActions.UndoAction = {
	IsValidAction = function(_, _, _, historyTool: HistoryTool): boolean
		return historyTool and historyTool:getUndoCount() > 0
	end,
	ExecuteAction = function(_, _, _, historyTool: HistoryTool)
		historyTool:undo()
	end,
}

HistoryEditActions.RedoAction = {
	IsValidAction = function(_, _, _, historyTool: HistoryTool): boolean
		return historyTool and historyTool:getRedoCount() > 0
	end,
	ExecuteAction = function(_, _, _, historyTool: HistoryTool)
		historyTool:redo()
	end,
}

-- Record a completed stroke as an undo step. It is draw via the ImageProjectionBrush actions.
HistoryEditActions.AddStrokeAction = {
	IsValidAction = function(_, _, _, historyTool: HistoryTool): boolean
		return historyTool
	end,
	ExecuteAction = function(modelInfo, strokeMetaData, _, historyTool): ()
		local meshPart = modelInfo:GetMeshPartByName(strokeMetaData.referenceMeshPartName)
		if not meshPart then
			return
		end

		local textureInfo = modelInfo:GetTextureInfo()
		local targetLayerInfo = textureInfo:GetTargetLayerInfo()

		local targetLayer = textureInfo:GetOrCreateLayer(meshPart, targetLayerInfo)
		local preEditBuffers = ImageEditActions.GetStrokePreEdit(targetLayer)

		local newAction: ActionUtils.Action =
			ActionUtils.CreateNewAction(ActionUtils.ActionTypes.ImageProjectionBrush, strokeMetaData)

		historyTool:addUndoAction(strokeMetaData.referenceMeshPartName, targetLayerInfo, newAction, preEditBuffers)
	end,
}

return HistoryEditActions
