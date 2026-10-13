--[[
	Creates the UI used with the eraser tool.
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
local Slider = require(Components:WaitForChild("Slider"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))
local Chip = require(Components:WaitForChild("Chip"))
local BrushPicker = require(Components:WaitForChild("BrushPicker"))
local Panel = require(Components:WaitForChild("Panel"))

local EraserToolUI = {}
EraserToolUI.__index = EraserToolUI

function EraserToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	defaultSliderVal: number, -- between 0 and 1
	onSliderChangedCallback: (number, boolean) -> (),
	onOpacitySliderChangedCallback: (number, boolean) -> (),
	onMirrorCallback: (boolean?) -> (),
	onMirrorGuideToggleCallback: (boolean?) -> (),
	onBrushSelectedCallback: (brushId: string) -> ()
)
	local self = {}
	setmetatable(self, EraserToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local mirrorToggle =
		Chip.new("Mirror Eraser", onMirrorCallback, true, StyleConsts.icons.MirrorPlane, onMirrorGuideToggleCallback)
	self.mirrorToggle = mirrorToggle

	local chipFrame = Instance.new("Frame", scrollingFrame)
	StyleUtils.AddStyleTag(chipFrame, StyleConsts.tags.ChipFrame)
	chipFrame.LayoutOrder = 1
	mirrorToggle:GetFrame().Parent = chipFrame

	local brushInfos = {}
	for _, entry in BrushData.GetSortedBrushData(BrushData.EraserBrushData) do
		table.insert(brushInfos, {
			previewImageId = entry.previewImageId,
			name = entry.name,
			callback = function()
				onBrushSelectedCallback(entry.brushId)
			end,
			tinted = true,
		})
	end

	self.brushPicker = BrushPicker.new(brushInfos, "Erasers")
	local brushPickerFrame = self.brushPicker:GetFrame()
	brushPickerFrame.Parent = scrollingFrame
	brushPickerFrame.LayoutOrder = 2
	-- The picker starts with nothing selected; highlight the default eraser.
	self.brushPicker:UpdateSelection(1)

	self.sliderTool = BrushSizeSliderTool.new(defaultSliderVal, onSliderChangedCallback, "Brush Size")
	local sliderToolFrame = self.sliderTool:GetFrame()
	sliderToolFrame.Parent = scrollingFrame
	sliderToolFrame.LayoutOrder = 3

	local opacitySlider = Slider.new(1, onOpacitySliderChangedCallback):GetFrame()
	local opacitySliderTool = ToolFrame.createComponentFrame(opacitySlider, "Opacity")
	opacitySliderTool.Parent = scrollingFrame
	opacitySliderTool.LayoutOrder = 4

	self.panel = Panel.createComponentFrame("Eraser", onClosePanelCallback, onDeleteCallback, { scrollingFrame })
	self.panel.Name = "EraserToolPanel"

	self:Close()

	return self
end

function EraserToolUI:Open(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.panel.Visible = true
	self:SyncMirrorChip(isMirrorEnabled, isMirrorGuideEnabled)
end

-- Reflects the shared mirror state (owned by BrushTool) onto this panel's chip.
-- Callbacks not called.
function EraserToolUI:SyncMirrorChip(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.mirrorToggle:SetActive(isMirrorEnabled)
	self.mirrorToggle:SetSideChipActive(isMirrorGuideEnabled)
end

function EraserToolUI:Close()
	self.panel.Visible = false
end

function EraserToolUI:SetBrushSizeSliderValue(value: number)
	self.sliderTool:UpdateValue(value)
end

function EraserToolUI:Destroy()
	self.brushPicker:Destroy()
end

return EraserToolUI
