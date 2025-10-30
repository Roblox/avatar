--[[
	Bar for displaying progress or count of items. Used to track number of
	applied stickers and kitbash pieces.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(labelText: string, maxValue: number)
	local self = {}
	setmetatable(self, ProgressBar)

	self.maxValue = maxValue
	self.labelText = labelText

	self.frame = Instance.new("Frame")
	self.frame.Name = "ProgressBarFrame"
	Utils.AddStyleTag(self.frame, StyleConsts.tags.ProgressBarFrame)

	self.label = Instance.new("TextLabel")
	self.label.Name = "Label"
	self.label.Text = `0/{maxValue} {labelText}`
	self.label.LayoutOrder = 2
	self.label.Parent = self.frame
	Utils.AddStyleTag(self.label, StyleConsts.tags.ProgressBarLabel)

	local progressBarBackground = Instance.new("Frame")
	progressBarBackground.Name = "BarBackground"
	progressBarBackground.Parent = self.frame
	progressBarBackground.LayoutOrder = 1
	Utils.AddStyleTag(progressBarBackground, StyleConsts.tags.ProgressBarBackground)

	self.progressFrame = Instance.new("Frame")
	self.progressFrame.Name = "Progress"
	self.progressFrame.Parent = progressBarBackground
	Utils.AddStyleTag(self.progressFrame, StyleConsts.tags.ProgressBarProgress)
	self.progressFrame.Size = UDim2.fromScale(0, 1)

	return self
end

function ProgressBar:UpdateProgress(currentValue: number)
	assert(currentValue <= self.maxValue, "Cannot have above 100% progress")
	self.progressFrame.Size = UDim2.fromScale(currentValue / self.maxValue, 1)

	self.label.Text = `{currentValue}/{self.maxValue} {self.labelText}`
end

return ProgressBar
