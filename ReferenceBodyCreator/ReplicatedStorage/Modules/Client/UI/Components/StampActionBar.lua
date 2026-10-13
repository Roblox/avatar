--[[
	Bottom action bar with custom left controls, Delete, and Apply.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local TextButton = require(Components:WaitForChild("TextButton"))

local StampActionBar = {}
StampActionBar.__index = StampActionBar

function StampActionBar.new(leftControl: GuiObject, onDelete: () -> (), onApply: () -> (), applyButtonText: string?)
	local self = {}
	setmetatable(self, StampActionBar)

	self.frame = Instance.new("Frame")
	self.frame.Name = "StampActionBar"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.StampActionBar)

	local leftButtons = Instance.new("Frame")
	leftButtons.Name = "LeftButtons"
	leftButtons.LayoutOrder = 1
	leftButtons.Parent = self.frame

	leftControl.LayoutOrder = 1
	leftControl.Parent = leftButtons

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.LayoutOrder = 2
	actions.Parent = self.frame

	local deleteButton = TextButton.createComponentFrame({
		text = "Delete",
		callback = onDelete,
	})
	deleteButton.Name = "Delete Button"
	deleteButton.LayoutOrder = 1
	deleteButton.Parent = actions
	StyleUtils.RemoveStyleTag(deleteButton, StyleConsts.tags.DefaultButton)
	StyleUtils.AddStyleTag(deleteButton, StyleConsts.tags.StampActionBarButton)

	local applyButton = TextButton.createComponentFrame({
		text = applyButtonText or "Apply",
		callback = onApply,
	})
	applyButton.Name = "Apply Button"
	applyButton.LayoutOrder = 2
	applyButton.Parent = actions
	StyleUtils.RemoveStyleTag(applyButton, StyleConsts.tags.DefaultButton)
	StyleUtils.AddStyleTag(applyButton, StyleConsts.tags.StampActionBarButton)
	StyleUtils.AddStyleTag(applyButton, StyleConsts.tags.EmphasisButton)

	self:Close()
	return self
end

function StampActionBar:GetFrame(): Frame
	return self.frame
end

function StampActionBar:Open()
	self.frame.Visible = true
end

function StampActionBar:Close()
	self.frame.Visible = false
end

return StampActionBar
