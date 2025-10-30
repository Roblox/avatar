--[[
	Single-selection toolbar that displays button groups. Takes in a list of
	toolbar button group infos from left to right display order. No button is
	selected by default.

	Includes methods for making and removing selections.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local ToolbarButtonGroup = require(Components:WaitForChild("ToolbarButtonGroup"))

local Toolbar = {}
Toolbar.__index = Toolbar

function Toolbar:MakeSelection(i: number)
	if self.currentSelection and self.currentSelection ~= i then
		local currentButtonGroup = self.buttonGroups[self.currentSelection]
		currentButtonGroup:HideExpanded()
		Utils.RemoveStyleTag(currentButtonGroup:GetFrame(), StyleConsts.tags.ButtonSelected)
	end
	self.currentSelection = i
	Utils.AddStyleTag(self.buttonGroups[i]:GetFrame(), StyleConsts.tags.ButtonSelected)
end

function Toolbar:RemoveSelection()
	if self.currentSelection then
		local currentButtonGroup = self.buttonGroups[self.currentSelection]
		currentButtonGroup:HideExpanded()
		Utils.RemoveStyleTag(currentButtonGroup:GetFrame(), StyleConsts.tags.ButtonSelected)
		self.currentSelection = nil
	end
end

function Toolbar:GetFrame()
	return self.frame
end

function Toolbar.new(toolbarButtonGroupInfos: { ToolbarButtonGroup.ToolbarButtonGroupInfo })
	local self = {}
	setmetatable(self, Toolbar)

	self.frame = Instance.new("Frame")
	self.frame.Name = "Toolbar"
	Utils.AddStyleTag(self.frame, StyleConsts.tags.Toolbar)

	self.currentSelection = nil
	self.buttonGroups = {}

	-- Make toolbarButtonGroups
	for i, toolbarButtonGroupInfo in toolbarButtonGroupInfos do
		-- Wrap primary button in selection function
		local primaryButtonCallback = toolbarButtonGroupInfo[1].callback
		local newPrimaryButton = {
			iconId = toolbarButtonGroupInfo[1].iconId,
			callback = function()
				self:MakeSelection(i)
				primaryButtonCallback()
			end,
		}
		toolbarButtonGroupInfo[1] = newPrimaryButton

		-- Create and insert button group
		local toolbarButtonGroup = ToolbarButtonGroup.new(toolbarButtonGroupInfo)
		table.insert(self.buttonGroups, toolbarButtonGroup)
		local toolbarButtonGroupFrame = toolbarButtonGroup:GetFrame()
		toolbarButtonGroupFrame.Parent = self.frame
		toolbarButtonGroupFrame.LayoutOrder = i
	end

	return self
end

return Toolbar
