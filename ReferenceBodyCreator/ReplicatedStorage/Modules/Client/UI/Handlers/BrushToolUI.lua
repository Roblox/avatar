--[[
	Creates the UI used with the brush tool, for free-drawing on the editable.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local BrushData = require(ReplicatedStorage.Modules.Config.BrushData)
local Constants = require(Config:WaitForChild("Constants"))

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BrushSizeSliderTool = require(Components:WaitForChild("BrushSizeSliderTool"))
local ColorPicker = require(Components:WaitForChild("ColorPicker"))
local Chip = require(Components:WaitForChild("Chip"))
local BrushPicker = require(Components:WaitForChild("BrushPicker"))
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
	onReflectiveModeChangedCallback: (boolean?) -> (),
	onMirrorCallback: (boolean?) -> (),
	onMirrorGuideToggleCallback: (boolean?) -> (),
	onTransparencyChangedCallback: (number) -> (),
	onBrushSelectedCallback: (brushId: string) -> ()
)
	local self = {}
	setmetatable(self, BrushToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback
	self.onColorChangedCallback = onColorChangedCallback
	self.onReflectiveModeChangedCallback = onReflectiveModeChangedCallback
	self.onTransparencyChangedCallback = onTransparencyChangedCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local reflectivityToggle = Chip.new("Metallic Effect", onReflectiveModeChangedCallback)
	local mirrorToggle =
		Chip.new("Mirror Brush", onMirrorCallback, true, StyleConsts.icons.MirrorPlane, onMirrorGuideToggleCallback)
	self.mirrorToggle = mirrorToggle

	local chipFrame = Instance.new("Frame", scrollingFrame)
	StyleUtils.AddStyleTag(chipFrame, StyleConsts.tags.ChipFrame)
	chipFrame.LayoutOrder = 1
	reflectivityToggle:GetFrame().Parent = chipFrame
	mirrorToggle:GetFrame().Parent = chipFrame

	local brushInfos = {}
	for _, entry in BrushData.GetSortedBrushData(BrushData.PaintBrushData) do
		table.insert(brushInfos, {
			previewImageId = entry.previewImageId,
			name = entry.name,
			callback = function()
				onBrushSelectedCallback(entry.brushId)
			end,
		})
	end

	self.brushPicker = BrushPicker.new(brushInfos, "Brushes")
	local brushPickerFrame = self.brushPicker:GetFrame()
	brushPickerFrame.Parent = scrollingFrame
	brushPickerFrame.LayoutOrder = 2
	-- The picker starts with nothing selected; highlight the default brush.
	self.brushPicker:UpdateSelection(1)

	self.sliderTool = BrushSizeSliderTool.new(defaultSliderVal, onSliderChangedCallback, "Brush Size")
	local sliderToolFrame = self.sliderTool:GetFrame()
	sliderToolFrame.Parent = scrollingFrame
	sliderToolFrame.LayoutOrder = 3

	local colorPicker = ColorPicker.createComponentFrame(onColorChangedCallback, onTransparencyChangedCallback, true)
	local colorPickerTool = ToolFrame.createComponentFrame(colorPicker, "Color")
	colorPickerTool.Parent = scrollingFrame
	colorPickerTool.LayoutOrder = 4

	self.panel = Panel.createComponentFrame("Paintbrush", onClosePanelCallback, onDeleteCallback, { scrollingFrame })
	self.panel.Name = "BrushToolPanel"

	self:Close()

	return self
end

function BrushToolUI:Open(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.panel.Visible = true
	self:SyncMirrorChip(isMirrorEnabled, isMirrorGuideEnabled)
end

-- Reflects the shared mirror state (owned by BrushTool) onto this panel's chip.
-- Callbacks not called.
function BrushToolUI:SyncMirrorChip(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.mirrorToggle:SetActive(isMirrorEnabled)
	self.mirrorToggle:SetSideChipActive(isMirrorGuideEnabled)
end

function BrushToolUI:SetBrushSizeSliderValue(value: number)
	self.sliderTool:UpdateValue(value)
end

function BrushToolUI:Close()
	self.panel.Visible = false
end

function BrushToolUI:Destroy()
	self.brushPicker:Destroy()
end

return BrushToolUI
