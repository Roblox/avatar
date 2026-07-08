--[[
	Creates the UI used with the brush tool, for free-drawing on the editable.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Slider = require(Components:WaitForChild("Slider"))
local ColorPicker = require(Components:WaitForChild("ColorPicker"))
local ReflectivityToggle = require(Components:WaitForChild("ReflectivityToggle"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))
local Panel = require(Components:WaitForChild("Panel"))

local BrushToolUI = {}
BrushToolUI.__index = BrushToolUI

function BrushToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	defaultSliderVal: number, -- between 0 and 1
	onSliderChangedCallback: (number, boolean) -> (),
	onColorChangedCallback: (Color3, boolean) -> (),
	onReflectiveModeChangedCallback: (boolean) -> (),
	onTransparencyChangedCallback: (number) -> ()
)
	local self = {}
	setmetatable(self, BrushToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback
	self.onColorChangedCallback = onColorChangedCallback
	self.onReflectiveModeChangedCallback = onReflectiveModeChangedCallback
	self.onTransparencyChangedCallback = onTransparencyChangedCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local slider = Slider.createComponentFrame(defaultSliderVal, onSliderChangedCallback)
	local sliderTool = ToolFrame.createComponentFrame(slider, "Brush Size")
	sliderTool.Parent = scrollingFrame
	sliderTool.LayoutOrder = 1

	local colorPicker =
		ColorPicker.createComponentFrame(onColorChangedCallback, onTransparencyChangedCallback)
	local reflectivityToggle = ReflectivityToggle.createComponentFrame(onReflectiveModeChangedCallback, false)
	local colorPickerTool = ToolFrame.createComponentFrame(colorPicker, "Color", reflectivityToggle)
	colorPickerTool.Parent = scrollingFrame
	colorPickerTool.LayoutOrder = 2

	self.panel = Panel.createComponentFrame(
		"Paintbrush",
		onClosePanelCallback,
		onDeleteCallback,
		{ scrollingFrame }
	)
	self.panel.Name = "BrushToolPanel"

	self:Close()

	return self
end

function BrushToolUI:Open()
	self.panel.Visible = true
end

function BrushToolUI:Close()
	self.panel.Visible = false
end

return BrushToolUI
