--[[
	A group of at least one button, used for the editing toolbar. Single button
	groups include the fill and kitbashing tool buttons; multiple button groups
	include the brush and sticker tool buttons.

	Includes methods for expanding and hiding the menu. When an icon is
	reselected, executes a callback.

	Takes in a list of IconButton infos in the left to right ordering. Only the
	first one is visible when the group is not selected.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Divider = require(Components:WaitForChild("ToolbarGroupDivider"))
local TwoStateIconButton = require(Components:WaitForChild("TwoStateIconButton"))

export type ToolbarButtonGroupInfo = {
	{
		iconId: string,
		mutedIconId: string?,
		callback: () -> (),
	}
}

local ToolbarButtonGroup = {}
ToolbarButtonGroup.__index = ToolbarButtonGroup

function ToolbarButtonGroup:HideExpanded()
	for i = 2, #self.children do
		StyleUtils.AddStyleTag(self.children[i], StyleConsts.tags.Hidden)
	end
	-- Change primary icon back to default version
	self:ChangeSelection()
end

function ToolbarButtonGroup:UnhideAll()
	for _, child in self.children do
		StyleUtils.RemoveStyleTag(child, StyleConsts.tags.Hidden)
	end
end

function ToolbarButtonGroup:GetFrame()
	return self.frame
end

-- Enables or disables every button in the group. Disabled buttons stay visible but
-- faded and non-interactive.
function ToolbarButtonGroup:SetEnabled(isEnabled: boolean)
	for _, button in self.childButtons do
		button:SetEnabled(isEnabled)
	end
end

function ToolbarButtonGroup:ChangeSelection(i: number)
	if self.currentSelection and self.currentSelection ~= i then
		-- Deselect current and set icon to muted version, if it exists
		local currentButton = self.childButtons[self.currentSelection]
		currentButton:SetActive(false)

		local newButton = if i then self.childButtons[i] else self.childButtons[1]
		newButton:SetActive(true)
	end
	self.currentSelection = i
end

function ToolbarButtonGroup.new(toolbarButtonGroupInfo: ToolbarButtonGroupInfo, reselectCallback: () -> ())
	local self = {}
	setmetatable(self, ToolbarButtonGroup)

	self.frame = Instance.new("Frame")
	self.frame.Name = "ToolbarButtonGroup"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.ToolbarButtonGroup)

	-- Primary button selected by default
	self.currentSelection = nil
	self.children = {}
	self.childButtons = {}

	-- Create buttons from button stack and add dividers
	for i, buttonInfo in toolbarButtonGroupInfo do
		local button

		-- If no muted icon is specified, use the regular icon for both states
		if not buttonInfo.mutedIconId then
			buttonInfo.mutedIconId = buttonInfo.iconId
		end

		local buttonCallback = function()
			if self.currentSelection == i then
				reselectCallback()
			else
				self:ChangeSelection(i)
				buttonInfo.callback()
			end
		end

		if i == 1 then
			-- First button also must make other buttons visible
			local buttonFunc = function()
				if self.currentSelection ~= i then
					self:UnhideAll()
				end
				buttonCallback()
			end
			button = TwoStateIconButton.new(buttonInfo.iconId, buttonInfo.mutedIconId,buttonFunc)
			-- Set first button to active by default
			button:SetActive(true)
			table.insert(self.childButtons, button)
		else
			-- Insert divider frame
			local divider = Divider.createComponentFrame()
			table.insert(self.children, divider)

			-- Create and insert button, muted by default if possible
			button = TwoStateIconButton.new(buttonInfo.iconId, buttonInfo.mutedIconId,buttonCallback)
			button:SetActive(false)
			table.insert(self.childButtons, button)
		end

		table.insert(self.children, button:GetFrame())
		StyleUtils.AddStyleTag(button:GetFrame(), StyleConsts.tags.ToolbarButton)
	end

	-- Parent all children
	for i, child in self.children do
		child.LayoutOrder = i
		child.Parent = self.frame
	end

	self:HideExpanded()

	return self
end

return ToolbarButtonGroup
