local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local HistoryTool = require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("HistoryTool"))
local HistoryEditActions =
	require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("HistoryEditActions"))

local ActionQueue = {}
ActionQueue.__index = ActionQueue

function ActionQueue.new(player: Player)
	local self = setmetatable({}, ActionQueue)

	self.queue = {} :: { ActionUtils.Action }
	self.actionInProgress = false
	self.destroyed = false

	self.gotTargetModelInfo = Instance.new("BindableEvent")
	self.processingFinished = Instance.new("BindableEvent")

	self.targetModelInfo = nil
	self.historyTool = nil
	self.player = player

	return self
end

function ActionQueue:ProcessQueue()
	if self.destroyed or self.actionInProgress then
		return
	end

	if not self.targetModelInfo then
		return
	end

	if #self.queue == 0 then
		return
	end

	self.actionInProgress = true

	while #self.queue > 0 do
		local action = self.queue[1]
		table.remove(self.queue, 1)
		assert(self.historyTool)
		if not Actions.IsValidAction(self.targetModelInfo, action, nil, self.historyTool) then
			warn(
				"Invalid action found in queue for player "
					.. self.player.Name
					.. " with actionType "
					.. action.actionType
			)
			warn("Action Metadata:", HttpService:JSONEncode(action.actionMetaData))
			continue
		end

		Actions.ExecuteAction(self.targetModelInfo, action, nil, self.historyTool)
	end

	self.processingFinished:Fire()

	self.actionInProgress = false
end

function ActionQueue:SetTargetModelInfo(targetModelInfo)
	self.targetModelInfo = targetModelInfo
	self.historyTool = HistoryTool.new(targetModelInfo)
	self.gotTargetModelInfo:Fire()

	self:ProcessQueue()
end

function ActionQueue:GetPlayerModelInfo()
	return self.targetModelInfo
end

function ActionQueue:AddAction(action: ActionUtils.Action)
	if self.destroyed then
		return
	end
	table.insert(self.queue, action)

	self:ProcessQueue()
end

-- Flush the queue and wait for all actions to finish processing
function ActionQueue:FlushQueue()
	if self.destroyed then
		return
	end
	if not self.targetModelInfo then
		self.gotTargetModelInfo.Event:Wait()
	end

	if self.actionInProgress then
		self.processingFinished.Event:Wait()
	end

	if #self.queue > 0 then
		self:ProcessQueue()
	end
end

function ActionQueue:Destroy()
	if self.destroyed then
		return
	end
	self.destroyed = true
	table.clear(self.queue)
	if self.actionInProgress then
		self.processingFinished.Event:Wait()
	end
	self.targetModelInfo = nil
	self.historyTool = nil
	self.gotTargetModelInfo:Destroy()
	self.processingFinished:Destroy()
end

return ActionQueue
