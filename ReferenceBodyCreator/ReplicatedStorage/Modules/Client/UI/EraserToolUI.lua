--[[
	Creates the UI used with the eraser tool.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Slider = require(Components:WaitForChild("Slider"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))
local Panel = require(Components:WaitForChild("Panel"))

local EraserToolUI = {}
EraserToolUI.__index = EraserToolUI

function EraserToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	defaultSliderVal: number, -- between 0 and 1
	onSliderChangedCallback: (number, boolean) -> ()
)
	local self = {}
	setmetatable(self, EraserToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback

	local slider = Slider.createComponentFrame(inputManager, defaultSliderVal, onSliderChangedCallback)
	local sliderTool = ToolFrame.createComponentFrame(slider, "Brush Size")

	self.panel = Panel.createComponentFrame("Eraser", onClosePanelCallback, onDeleteCallback, { sliderTool })
	self.panel.Name = "EraserToolPanel"

	self:Close()

	return self
end

function EraserToolUI:Open()
	self.panel.Visible = true
end

function EraserToolUI:Close()
	self.panel.Visible = false
end

return EraserToolUI
