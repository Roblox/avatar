--[[
	Creates the UI used with the fill/fabric tool, for recoloring regions of the
	edited model. Contains a region selector and a color picker.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local RegionPicker = require(Components:WaitForChild("RegionPicker"))
local ColorPicker = require(Components:WaitForChild("ColorPicker"))
local ReflectivityToggle = require(Components:WaitForChild("ReflectivityToggle"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))
local Panel = require(Components:WaitForChild("Panel"))

local FillToolUI = {}
FillToolUI.__index = FillToolUI

function FillToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	regionParts: { string },
	onRegionSelectedCallback: (string) -> (),
	onColorChangedCallback: (Color3, boolean) -> (),
	onReflectiveModeChangedCallback: (boolean) -> (),
	onOpacityChangedCallback: (number) -> ()
)
	local self = {}
	setmetatable(self, FillToolUI)

	self.onRegionSelectedCallback = onRegionSelectedCallback
	self.onColorChangedCallback = onColorChangedCallback
	self.onReflectiveModeChangedCallback = onReflectiveModeChangedCallback
	self.onOpacityChangedCallback = onOpacityChangedCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	-- The "full model" region should be first
	local modelDisplayName = StyleConsts.modelDisplayName[regionParts[1]]

	local regionPillbar = RegionPicker.createComponentFrame(regionParts, onRegionSelectedCallback)
	local regionSelectTool = ToolFrame.createComponentFrame(regionPillbar, `{modelDisplayName} Section`)
	regionSelectTool.Parent = scrollingFrame
	regionSelectTool.LayoutOrder = 1

	local colorPicker = ColorPicker.createComponentFrame(onColorChangedCallback, onOpacityChangedCallback)
	local reflectivityToggle = ReflectivityToggle.createComponentFrame(onReflectiveModeChangedCallback, false)
	local colorPickerTool = ToolFrame.createComponentFrame(colorPicker, "Color", reflectivityToggle)
	colorPickerTool.Parent = scrollingFrame
	colorPickerTool.LayoutOrder = 2

	self.panel = Panel.createComponentFrame(
		"Recolor",
		onClosePanelCallback,
		onDeleteCallback,
		{ scrollingFrame }
	)
	self.panel.Name = "FillToolPanel"

	self:Close()

	return self
end

function FillToolUI:Open()
	self.panel.Visible = true
end

function FillToolUI:Close()
	self.panel.Visible = false
end

return FillToolUI
