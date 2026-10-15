--[[
	Creates the UI used with the blend tool, for smudging/blurring the editable.
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
local Chip = require(Components:WaitForChild("Chip"))
local BrushPicker = require(Components:WaitForChild("BrushPicker"))
local Panel = require(Components:WaitForChild("Panel"))

local BlendToolUI = {}
BlendToolUI.__index = BlendToolUI

function BlendToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	defaultSliderVal: number, -- between 0 and 1
	onSliderChangedCallback: (number, boolean) -> (),
	onMirrorCallback: (boolean?) -> (),
	onMirrorGuideToggleCallback: (boolean?) -> (),
	onBrushSelectedCallback: (brushId: string) -> ()
)
	local self = {}
	setmetatable(self, BlendToolUI)

	self.onSliderChangedCallback = onSliderChangedCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local mirrorToggle =
		Chip.new("Mirror Brush", onMirrorCallback, true, StyleConsts.icons.MirrorPlane, onMirrorGuideToggleCallback)
	self.mirrorToggle = mirrorToggle

	local chipFrame = Instance.new("Frame")
	chipFrame.Parent = scrollingFrame
	StyleUtils.AddStyleTag(chipFrame, StyleConsts.tags.ChipFrame)
	chipFrame.LayoutOrder = 1
	mirrorToggle:GetFrame().Parent = chipFrame

	local brushInfos = {}
	for _, entry in BrushData.GetSortedBrushData(BrushData.BlendBrushData) do
		table.insert(brushInfos, {
			previewImageId = entry.previewImageId,
			name = entry.name,
			callback = function()
				onBrushSelectedCallback(entry.brushId)
			end,
			tinted = true,
		})
	end

	self.brushPicker = BrushPicker.new(brushInfos, "Blend Brushes")
	local brushPickerFrame = self.brushPicker:GetFrame()
	brushPickerFrame.Parent = scrollingFrame
	brushPickerFrame.LayoutOrder = 2
	-- The picker starts with nothing selected; highlight the default blend.
	self.brushPicker:UpdateSelection(1)

	self.sliderTool = BrushSizeSliderTool.new(defaultSliderVal, onSliderChangedCallback, "Brush Size")
	local sliderToolFrame = self.sliderTool:GetFrame()
	sliderToolFrame.Parent = scrollingFrame
	sliderToolFrame.LayoutOrder = 3

	self.panel = Panel.createComponentFrame("Blend", onClosePanelCallback, onDeleteCallback, { scrollingFrame })
	self.panel.Name = "BlendToolPanel"

	self:Close()

	return self
end

function BlendToolUI:Open(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.panel.Visible = true
	self:SyncMirrorChip(isMirrorEnabled, isMirrorGuideEnabled)
end

-- Reflects the shared mirror state (owned by BrushTool) onto this panel's chip.
-- Callbacks not called.
function BlendToolUI:SyncMirrorChip(isMirrorEnabled: boolean, isMirrorGuideEnabled: boolean)
	self.mirrorToggle:SetActive(isMirrorEnabled)
	self.mirrorToggle:SetSideChipActive(isMirrorGuideEnabled)
end

function BlendToolUI:Close()
	self.panel.Visible = false
end

function BlendToolUI:SetBrushSizeSliderValue(value: number)
	self.sliderTool:UpdateValue(value)
end

function BlendToolUI:Destroy()
	self.brushPicker:Destroy()
end

return BlendToolUI
