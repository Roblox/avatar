local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Actions = require(Modules:WaitForChild("Actions"))

local ActionQueue = {}
ActionQueue.__index = ActionQueue

function ActionQueue.new(player: Player)
	local self = setmetatable({}, ActionQueue)

	self.queue = {} :: { Actions.Action }
	self.actionInProgress = false

	self.gotTargetModelInfo = Instance.new("BindableEvent")
	self.processingFinished = Instance.new("BindableEvent")

	self.targetModelInfo = nil
	self.player = player

	return self
end

function ActionQueue:ProcessQueue()
	if self.actionInProgress then
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

		if not Actions.IsValidAction(self.targetModelInfo, action) then
			warn(
				"Invalid action found in queue for player "
					.. self.player.Name
					.. " with actionType "
					.. action.actionType
			)
			warn("Action Metadata:", HttpService:JSONEncode(action.actionMetaData))
			continue
		end

		Actions.ExecuteAction(self.targetModelInfo, action)
	end

	self.processingFinished:Fire()

	self.actionInProgress = false
end

function ActionQueue:SetTargetModelInfo(targetModelInfo)
	self.targetModelInfo = targetModelInfo
	self.gotTargetModelInfo:Fire()

	self:ProcessQueue()
end

function ActionQueue:GetPlayerModelInfo()
	return self.targetModelInfo
end

function ActionQueue:AddAction(action: Actions.Action)
	table.insert(self.queue, action)

	self:ProcessQueue()
end

-- Flush the queue and wait for all actions to finish processing
function ActionQueue:FlushQueue()
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

return ActionQueue
