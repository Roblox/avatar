--[[
	This file is a simple example of how to create a UI handler using the Style
	system and component structure. It is not meant to be a full-featured
	example, but rather a starting point for building out your own UI handlers!

	To use, try creating a LocalScript in StarterPlayerScripts, include the UI
	module, and call ExampleUI.new().
]]

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleSheet = require(Style:WaitForChild("StyleSheet"))
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Toolbar = require(Components:WaitForChild("Toolbar"))
local HorizontalPillbar = require(Components:WaitForChild("HorizontalPillbar"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))
local Panel = require(Components:WaitForChild("Panel"))

local ExampleUI = {}
ExampleUI.__index = ExampleUI

function ExampleUI.new()
	local self = {}
	setmetatable(self, ExampleUI)

	-- Force the PlayerGui into landscape mode
	-- This is optional, but can be useful if your UI is designed for a specific
	-- orientation.
	self.prevScreenOrientation = PlayerGui.ScreenOrientation
	PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight

	-- Setup screen gui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "EditingUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Parent = PlayerGui

	-- Create and link styleSheet
	self.style = StyleSheet.new()
	self.style:LinkGui(self.screenGui)

	--[[
		Setup partition frames for toolbar and panel.
		These styled frames will ensure that the toolbar and panel are
		positioned correctly and adapt to different screen sizes.

		If you want to position the components yourself, you may choose to
		create your own tags and rules for frames like these.
	]]
	local frame = Instance.new("Frame")
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.UIParent)
	frame.Parent = self.screenGui
	frame.Name = "UIParent"

	local toolbarParent = Instance.new("Frame")
	StyleUtils.AddStyleTag(toolbarParent, StyleConsts.tags.ToolbarParent)
	toolbarParent.Parent = frame
	toolbarParent.Name = "ToolbarParent"

	local panelParent = Instance.new("Frame")
	StyleUtils.AddStyleTag(panelParent, StyleConsts.tags.PanelParent)
	panelParent.Parent = frame
	panelParent.Name = "PanelParent"

	-- Add components
	self:SetupToolbar(toolbarParent)
	self:SetupPanel(panelParent)

	return self
end

-- This function sets up our toolbar at the bottom/side of the screen.
-- A more complex UI might set up the toolbar as its own handler, or it can
-- remain a method in a parent handler.
function ExampleUI:SetupToolbar(toolbarParent: Frame)
	-- For grouped buttons, it is good to specify a muted/unselected icon for
	-- visual clarity, but it is not required.
	local Group1 = {
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 1 button 1 clicked")
			end,
		},
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 1 button 2 clicked")
			end,
		},
	}
	local Group2 = {
		{
			iconId = StyleConsts.icons.Pattern,
			callback = function()
				print("Toolbar group 2 button 1 clicked")
			end,
		},
	}
	local Group3 = {
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 3 button 1 clicked")
			end,
		},
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 3 button 2 clicked")
			end,
		},
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 3 button 3 clicked")
			end,
		},
		{
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				print("Toolbar group 3 button 4 clicked")
			end,
		},
	}

	-- Create toolbar
	local toolbarGroups = {
		Group1,
		Group2,
		Group3,
	}

	self.toolbar = Toolbar.new(toolbarGroups, function()
		-- If you click the same button twice, remove the selection.
		self.toolbar:RemoveSelection()
	end)

	-- Since toolbar component has a state tracking the selected button, it has
	-- a method to get the frame. This is typical of components with a .new()
	-- method instead of a .createComponentFrame() method.
	self.toolbar:GetFrame().Parent = toolbarParent
end

function ExampleUI:SetupPanel(panelParent: Frame)
	-- First, we create the components we want to put in our panel.
	-- This one just has a pillbar.
	local pillbarButtonStack = {
		{
			iconId = StyleConsts.icons.Pattern,
			callback = function()
				print("Pillbar button 1 clicked")
			end,
		},
		{
			iconId = StyleConsts.icons.Pattern,
			callback = function()
				print("Pillbar button 2 clicked")
			end,
		},
	}
	local pillbar = HorizontalPillbar.createComponentFrame(pillbarButtonStack)

	-- Components are often housed in a tool frame, but this isn't required.
	-- The tool frame adds a title and padding, but you can create your own
	-- styled frame if you want different aesthetics.
	local pillbarToolFrame = ToolFrame.createComponentFrame(pillbar, "Pillbar Tool")

	-- We want to set up the callbacks for the close and delete buttons.
	local onClosePanelCallback = function()
		print("Panel Close button clicked")
	end
	local onDeleteCallback = function()
		print("Panel Delete button clicked")
	end

	-- Then we create the panel, passing in the components.
	self.panel =
		Panel.createComponentFrame("Example Panel", onClosePanelCallback, onDeleteCallback, { pillbarToolFrame })
	-- The panel component doesn't have any internal state, so the component
	-- frame is the same as the panel itself. You can tell because the component
	-- is called with a `.createComponentFrame()` method instead of `.new()`.
	self.panel.Parent = panelParent
	self.panel.Name = "ExamplePanel"
end

--[[
	If you might be destroying and recreating this UI handler multiple times in
	a session, you'll want to make sure to destroy any instances so that copies
	don't stack up in the PlayerGui. This is also a good place to disconnect any
	events and restore any changed properties (like ScreenOrientation).
]]
function ExampleUI:Destroy()
	self.screenGui:Destroy()
	self.style:Destroy()

	-- Restore orientation
	PlayerGui.ScreenOrientation = self.prevScreenOrientation
end

return ExampleUI
