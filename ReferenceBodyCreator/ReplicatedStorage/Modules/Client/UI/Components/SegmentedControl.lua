--[[
	Horizontal bar allowing the user to switch between different options.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")
local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

-- We only import this for the type
local TextButton = require(Components:WaitForChild("TextButton"))

local SegmentedControlInternal = {}
SegmentedControlInternal.__index = SegmentedControlInternal

function SegmentedControlInternal:applySelection(newSelectionIndex)
	if newSelectionIndex ~= self.currentSelection then
		Utils.AddStyleTag(self.buttonList[newSelectionIndex], StyleConsts.tags.ButtonSelected)
		Utils.RemoveStyleTag(self.buttonList[self.currentSelection], StyleConsts.tags.ButtonSelected)
		self.currentSelection = newSelectionIndex
	end
end

function SegmentedControlInternal.new(buttonInfos: {TextButton.ButtonInfo})
	local self = {}
	setmetatable(self, SegmentedControlInternal)
	self.currentSelection = 1
	self.buttonList = {}

	self.frame = Instance.new("Frame")
	self.frame.Name = "SegmentedControl"

	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	Utils.AddStyleTag(self.frame, StyleConsts.tags.SegmentedControl)

	-- Create buttons from button stack
	for i, buttonInfo in buttonInfos do
		local button = Instance.new("TextButton")
		button.LayoutOrder = i
		button.Text = buttonInfo.text
		button.Activated:Connect(function()
			buttonInfo.callback()
			self:applySelection(i)
		end)
		button.Parent = self.frame
		Utils.AddStyleTag(button, StyleConsts.tags.SegmentedControlButton)

		table.insert(self.buttonList, button)
	end

	-- Make first button selected
	Utils.AddStyleTag(self.buttonList[1], StyleConsts.tags.ButtonSelected)

	return self
end

local SegmentedControlPublic = {}

function SegmentedControlPublic.createComponentFrame(buttonInfos: {TextButton.ButtonInfo})
	local segmentedControl = SegmentedControlInternal.new(buttonInfos)

	return segmentedControl.frame
end

return SegmentedControlPublic
