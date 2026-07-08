--[[
	Simple counter used with the item selector to track how many stickers/add-ons
	have been applied.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Counter = {}
Counter.__index = Counter

function Counter.new(maxValue: number)
	local self = {}
	setmetatable(self, Counter)

	self.maxValue = maxValue

	self.frame = Instance.new("Frame")
	self.frame.Name = "CounterFrame"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CounterFrame)

	self.label = Instance.new("TextLabel")
	self.label.Name = "CounterLabel"
	self.label.Text = `0/{maxValue} Applied`
	self.label.LayoutOrder = 2
	self.label.Parent = self.frame
	StyleUtils.AddStyleTag(self.label, StyleConsts.tags.CounterLabel)

	return self
end

function Counter:UpdateProgress(currentValue: number)
	self.label.Text = `{currentValue}/{self.maxValue}`
end

return Counter
