--[[
	Creates the UI used with the brush tool, for free-drawing on the editable.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Slider = require(Components:WaitForChild("Slider"))
local ColorPicker = require(Components:WaitForChild("ColorPicker"))
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
	onColorChangedCallback: (Color3, boolean) -> ()
)
	local self = {}
	setmetatable(self, BrushToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback
	self.onColorChangedCallback = onColorChangedCallback

	local slider = Slider.createComponentFrame(inputManager, defaultSliderVal, onSliderChangedCallback)
	local sliderTool = ToolFrame.createComponentFrame(slider, "Brush Size")

	local colorPicker = ColorPicker.createComponentFrame(inputManager, onColorChangedCallback)
	local colorPickerTool = ToolFrame.createComponentFrame(colorPicker, "Color")

	self.panel = Panel.createComponentFrame(
		"Paintbrush",
		onClosePanelCallback,
		onDeleteCallback,
		{ sliderTool, colorPickerTool }
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
