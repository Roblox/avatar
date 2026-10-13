--!strict

--[[
    HistoryTool controls undo/redos. We save a copy of the layer from up to 10 actions ago.
    When the user clicks undo, we replay the last n - 1 actions onto our saved layer and
    restore that as the target layer. The undone action is moved to the redo stack, where
    the user can click redo to replay that action.

    Construct one per model with HistoryTool.new(modelInfo). All state is per-instance,
    so the same class can back a separate history per player on the server.
]]
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local UtilTypes = require(Modules:WaitForChild("UtilTypes"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local Actions = require(Modules:WaitForChild("Actions"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")

local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local MAX_UNDOS = 10

type UndoQueue = UtilTypes.Queue<ActionUtils.Action>

type RedoStack = UtilTypes.Stack<ActionUtils.Action>

local HistoryTool = {}
HistoryTool.__index = HistoryTool

type HistoryToolProps = {
	currentLayerInfo: GroupInfo.TargetLayerInfo?,
	currentMeshPartName: string?,
	currentModelInfo: any, -- we use any here because this class is not typed well and causes issues
	selectLayerCallback: (GroupInfo.TargetLayerInfo) -> (),
	undoQueue: UndoQueue,
	historyChangedCallback: () -> (),
	redoStack: RedoStack,
}

export type HistoryTool = typeof(setmetatable({} :: HistoryToolProps, HistoryTool))

-- Construct a history bound to a single model. Must exist before
-- addUndoAction/undo/redo are called.
function HistoryTool.new(modelInfo: any): HistoryTool
	local self = setmetatable({} :: HistoryToolProps, HistoryTool)
	self.currentLayerInfo = nil
	self.currentMeshPartName = nil
	self.currentModelInfo = modelInfo
	self.selectLayerCallback = function() end
	self.undoQueue = UtilTypes.newQueue()
	self.historyChangedCallback = function() end
	self.redoStack = UtilTypes.newStack()
	return self
end

local function getLayerSet(self: HistoryTool, layerInfo: GroupInfo.TargetLayerInfo): Constants.EditableImageSet
	assert(self.currentMeshPartName)
	local meshPart = assert(
		self.currentModelInfo:GetMeshPartByName(self.currentMeshPartName),
		"unknown mesh part: " .. self.currentMeshPartName
	)
	return (self.currentModelInfo:GetTextureInfo():GetOrCreateLayer(meshPart, layerInfo))
end

-- Per-channel pixel sizes of a layer set, matching the shape SetReplayBuffer expects.
local function getLayerSizes(
	layerSet: Constants.EditableImageSet
): { color: Vector2, metalness: Vector2, roughness: Vector2 }
	local sizes = {}
	for _, channel in Constants.CHANNEL_NAMES do
		sizes[channel] = layerSet[channel].Size
	end
	return sizes
end

local function applyAction(self: HistoryTool, action: ActionUtils.Action, useReplayLayer: boolean): ()
	if action.actionType ~= ActionUtils.ActionTypes.ImageProjectionBrush then
		Actions.ExecuteAction(self.currentModelInfo, action, useReplayLayer)
		return
	end

	local brush = self.currentModelInfo:GetBrushRegistry():GetBrush(action.actionMetaData.brushId)
	local replayBrush = brush:CloneForReplay()
	-- Drawing with a loaded brush is synchronous. Refresh static decals even on failure;
	-- random and sampling brushes regenerate theirs before the next live stamp.
	local success, result =
		pcall(Actions.ExecuteAction, self.currentModelInfo, action, useReplayLayer, nil, replayBrush)
	brush:UpdateTexture()
	if not success then
		error(result, 0)
	end
end

function HistoryTool.setSelectLayerCallback(self: HistoryTool, callback: (GroupInfo.TargetLayerInfo) -> ()): ()
	self.selectLayerCallback = callback
end

function HistoryTool.setHistoryChangedCallback(self: HistoryTool, callback: () -> ()): ()
	self.historyChangedCallback = callback
end

function HistoryTool.getUndoCount(self: HistoryTool): number
	return self.undoQueue.length
end

function HistoryTool.getRedoCount(self: HistoryTool): number
	return self.redoStack.length
end

-- Structural edits can destroy the layer that the pixel history replays onto.
-- Start a fresh history rather than retaining actions that can no longer be replayed safely.
function HistoryTool.clear(self: HistoryTool): ()
	self.currentLayerInfo = nil
	self.currentMeshPartName = nil
	self.undoQueue = UtilTypes.newQueue() :: UndoQueue
	self.redoStack = UtilTypes.newStack() :: RedoStack
	self.historyChangedCallback()
end

function HistoryTool.clearIfTrackingLayer(
	self: HistoryTool,
	meshPartName: string,
	layerInfo: GroupInfo.TargetLayerInfo
): ()
	local currentLayerInfo = self.currentLayerInfo
	if
		currentLayerInfo
		and self.currentMeshPartName == meshPartName
		and currentLayerInfo.groupId == layerInfo.groupId
		and currentLayerInfo.layerId == layerInfo.layerId
	then
		self:clear()
	end
end

function HistoryTool.clearIfTrackingGroup(self: HistoryTool, meshPartName: string, groupId: string): ()
	local currentLayerInfo = self.currentLayerInfo
	if currentLayerInfo and self.currentMeshPartName == meshPartName and currentLayerInfo.groupId == groupId then
		self:clear()
	end
end

function HistoryTool.addUndoAction(
	self: HistoryTool,
	meshPartName: string,
	layerInfo: GroupInfo.TargetLayerInfo,
	action: Actions.Action,
	preEditBuffers: Constants.BufferSet
): ()
	self.redoStack = UtilTypes.newStack() -- Performing another action resets the redos

	-- we are on a new layer, reset the undo queue
	if
		not self.currentLayerInfo
		or layerInfo.groupId ~= self.currentLayerInfo.groupId
		or layerInfo.layerId ~= self.currentLayerInfo.layerId
	then
		self.undoQueue = UtilTypes.newQueue() :: UndoQueue
		self.currentLayerInfo = layerInfo
		self.currentMeshPartName = meshPartName
		-- Seed the checkpoint with the layer's pre-edit pixels for every PBR channel (captured before
		-- this stroke).
		self.currentModelInfo
			:GetTextureInfo()
			:SetReplayBuffer(preEditBuffers, getLayerSizes(getLayerSet(self, layerInfo)))
	end

	if self.undoQueue.length >= MAX_UNDOS then
		local staleAction: ActionUtils.Action? = nil
		self.undoQueue, staleAction = UtilTypes.dequeue(self.undoQueue) -- bake least recent action into our saved checkpoint
		assert(staleAction)
		-- Advance the checkpoint
		applyAction(self, staleAction, true)
	end

	assert(self.undoQueue.length < MAX_UNDOS) -- if we still have too many undos, our invariant failed

	self.undoQueue = UtilTypes.enqueue(self.undoQueue, action)
	self.historyChangedCallback()
end

function HistoryTool.undo(self: HistoryTool): ()
	if self.undoQueue.length == 0 then
		warn("Attempt to call undo with no undos available")
		return
	end

	assert(self.currentLayerInfo)


	self.selectLayerCallback(self.currentLayerInfo)

	-- Rebuild from the checkpoint: restore the saved checkpoint pixels onto the live layer (per PBR
	-- channel), then replay the remaining actions onto it below.
	local targetImages = getLayerSet(self, self.currentLayerInfo)
	local replayBuffers, replaySizes = self.currentModelInfo:GetTextureInfo():GetReplayBuffer()
	assert(replayBuffers and replaySizes)

	for _, channel in Constants.CHANNEL_NAMES do
		local replayLayer = AssetService:CreateEditableImage({ Size = replaySizes[channel] })
		assert(replayLayer)
		replayLayer:WritePixelsBuffer(Vector2.zero, replaySizes[channel], replayBuffers[channel])
		targetImages[channel]:DrawImage(Vector2.zero, replayLayer, Enum.ImageCombineType.Overwrite)
		replayLayer:Destroy()
	end

	local tempQ: UndoQueue = self.undoQueue
	local newQ: UndoQueue = UtilTypes.newQueue() -- Add all but the most recent action
	while tempQ.length > 1 do
		local replayedAction: ActionUtils.Action? = nil
		tempQ, replayedAction = UtilTypes.dequeue(tempQ)
		assert(replayedAction)
		newQ = UtilTypes.enqueue(newQ, replayedAction)
		applyAction(self, replayedAction, false)
	end

	local undoneAction: ActionUtils.Action? = nil
	tempQ, undoneAction = UtilTypes.dequeue(tempQ)
	assert(undoneAction)
	self.redoStack = UtilTypes.push(self.redoStack, undoneAction)

	self.undoQueue = newQ
	self.historyChangedCallback()

	self.currentModelInfo:UpdateOutputColorMap()
end

function HistoryTool.redo(self: HistoryTool): ()
	local redoneAction: ActionUtils.Action? = nil
	self.redoStack, redoneAction = UtilTypes.pop(self.redoStack)

	if not redoneAction then
		warn("Attempt to call redo with no redos available")
		return
	end

	assert(self.currentLayerInfo)

	-- Update the active layer (UI highlight + tool target) before replaying, so the
	-- redone action resolves onto the correct layer.
	self.selectLayerCallback(self.currentLayerInfo)

	self.undoQueue = UtilTypes.enqueue(self.undoQueue, redoneAction) -- we will never exceed MAX_UNDOS here
	self.historyChangedCallback()

	-- Re-apply the redone action directly onto the live layer.
	applyAction(self, redoneAction, false)
	self.currentModelInfo:UpdateOutputColorMap()
end

return HistoryTool
