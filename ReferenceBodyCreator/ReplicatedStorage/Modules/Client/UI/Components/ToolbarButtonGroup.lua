--[[
	A group of at least one button, used for the editing toolbar. Single button
	groups include the fill and kitbashing tool buttons; multiple button groups
	include the brush and sticker tool buttons.

	Includes methods for expanding and hiding the menu.

	Takes in a list of IconButton infos in the left to right ordering. Only the
	first one is visible when the group is not selected.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local Divider = require(Components:WaitForChild("ToolbarGroupDivider"))
local IconButton = require(Components:WaitForChild("IconButton"))

export type ToolbarButtonGroupInfo = { IconButton.IconButtonInfo }

local ToolbarButtonGroup = {}
ToolbarButtonGroup.__index = ToolbarButtonGroup

function ToolbarButtonGroup:HideExpanded()
	for i = 2, #self.children do
		Utils.AddStyleTag(self.children[i], StyleConsts.tags.Hidden)
	end
end

function ToolbarButtonGroup:UnhideAll()
	for _, child in self.children do
		Utils.RemoveStyleTag(child, StyleConsts.tags.Hidden)
	end
end

function ToolbarButtonGroup:GetFrame()
	return self.frame
end

function ToolbarButtonGroup.new(toolbarButtonGroupInfo: ToolbarButtonGroupInfo)
	local self = {}
	setmetatable(self, ToolbarButtonGroup)

	self.frame = Instance.new("Frame")
	self.frame.Name = "ToolbarButtonGroup"
	Utils.AddStyleTag(self.frame, StyleConsts.tags.ToolbarButtonGroup)

	self.children = {}

	-- Create buttons from button stack and add dividers
	for i, buttonInfo in toolbarButtonGroupInfo do
		local button
		if i == 1 then
			-- First button also must make other buttons visible
			local buttonFunc = function()
				self:UnhideAll()
				buttonInfo.callback()
			end
			button = IconButton.createComponentFrame(buttonInfo.iconId, buttonFunc)
		else
			-- Insert divider frame
			local divider = Divider.createComponentFrame()
			table.insert(self.children, divider)

			-- Create and insert button
			button = IconButton.createComponentFrame(buttonInfo.iconId, buttonInfo.callback)
		end

		table.insert(self.children, button)
		Utils.AddStyleTag(button, StyleConsts.tags.ToolbarButton)
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
