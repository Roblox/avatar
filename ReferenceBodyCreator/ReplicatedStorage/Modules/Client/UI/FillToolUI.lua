--[[
	Creates the UI used with the fill/fabric tool, for recoloring regions of the
	edited model. Contains a region selector and a color picker.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local Components = UI:WaitForChild("Components")

local RegionPicker = require(Components:WaitForChild("RegionPicker"))
local ColorPicker = require(Components:WaitForChild("ColorPicker"))
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
	onColorChangedCallback: (Color3, boolean) -> ()
)
	local self = {}
	setmetatable(self, FillToolUI)

	self.onRegionSelectedCallback = onRegionSelectedCallback
	self.onColorChangedCallback = onColorChangedCallback

	-- The "full model" region should be first
	local modelDisplayName = StyleConsts.modelDisplayName[regionParts[1]]

	local regionPillbar = RegionPicker.createComponentFrame(regionParts, onRegionSelectedCallback)
	local regionSelectTool = ToolFrame.createComponentFrame(regionPillbar, `{modelDisplayName} Section`)

	local colorPicker = ColorPicker.createComponentFrame(inputManager, onColorChangedCallback)
	local colorPickerTool = ToolFrame.createComponentFrame(colorPicker, "Color")

	self.panel = Panel.createComponentFrame(
		"Recolor",
		onClosePanelCallback,
		onDeleteCallback,
		{ regionSelectTool, colorPickerTool }
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
