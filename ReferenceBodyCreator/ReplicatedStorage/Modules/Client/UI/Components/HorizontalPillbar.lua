--[[
	Creates a rounded pill button stack, with styling based on the currently
	selected item. Used for region selection in texture editing tools.

	Takes in a list of button infos, in order of appearance. Leftmost is
	selected by default.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")
local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local IconButton = require(Components:WaitForChild("IconButton"))

local HorizontalPillbarInternal = {}
HorizontalPillbarInternal.__index = HorizontalPillbarInternal

function HorizontalPillbarInternal:applySelection(newSelectionIndex)
	if newSelectionIndex ~= self.currentSelection then
		Utils.AddStyleTag(self.buttonList[newSelectionIndex], StyleConsts.tags.ButtonSelected)
		Utils.RemoveStyleTag(self.buttonList[self.currentSelection], StyleConsts.tags.ButtonSelected)
		self.currentSelection = newSelectionIndex
	end
end

function HorizontalPillbarInternal.new(pillbarButtonStack: { IconButton.IconButtonInfo })
	local self = {}
	setmetatable(self, HorizontalPillbarInternal)
	self.currentSelection = 1
	self.buttonList = {}

	self.frame = Instance.new("Frame")
	self.frame.Name = "HorizontalPillbar"

	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	Utils.AddStyleTag(self.frame, StyleConsts.tags.HorizontalPillbar)

	-- Create buttons from button stack
	for i, pillbarButtonInfo in pillbarButtonStack do
		local pillbarButton = IconButton.createComponentFrame(pillbarButtonInfo.iconId, function()
			pillbarButtonInfo.callback()
			self:applySelection(i)
		end)

		pillbarButton.Parent = self.frame
		pillbarButton.LayoutOrder = i
		if #pillbarButtonStack < StyleConsts.styleTokens.MaxLargePillbarButtons then
			Utils.AddStyleTag(pillbarButton, StyleConsts.tags.LargePillbarButton)
		else
			Utils.AddStyleTag(pillbarButton, StyleConsts.tags.SmallPillbarButton)
		end
		table.insert(self.buttonList, pillbarButton)
	end

	-- Make first button selected
	Utils.AddStyleTag(self.buttonList[1], StyleConsts.tags.ButtonSelected)

	return self
end

local HorizontalPillbarPublic = {}

function HorizontalPillbarPublic.createComponentFrame(pillbarButtonStack: { IconButton.IconButtonInfo })
	local pillBar = HorizontalPillbarInternal.new(pillbarButtonStack)

	return pillBar.frame
end

return HorizontalPillbarPublic
