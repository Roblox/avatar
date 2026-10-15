--[[
	Tool frame with a brush-size slider and a preview beside its title.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local Slider = require(Components:WaitForChild("Slider"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

local MIN_PREVIEW_SCALE = 0.2
local MAX_PREVIEW_SCALE = 0.85

local BrushSizeSliderTool = {}
BrushSizeSliderTool.__index = BrushSizeSliderTool

function BrushSizeSliderTool:SetPreviewCircleValue(value: number)
	local clampedValue = math.clamp(value, 0, 1)
	local previewScale = MIN_PREVIEW_SCALE + clampedValue * (MAX_PREVIEW_SCALE - MIN_PREVIEW_SCALE)
	self.previewCircle.Size = UDim2.fromScale(previewScale, previewScale)
end

function BrushSizeSliderTool:UpdateValue(value: number)
	self.slider:UpdateValue(value, true)
end

function BrushSizeSliderTool.new(
	defaultValue: number,
	onValueChangedCallback: (number, boolean) -> (),
	title: string
)
	local self = {}
	setmetatable(self, BrushSizeSliderTool)

	self.frame = Instance.new("Frame")
	self.frame.Name = "BrushSizeSliderTool"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.BrushSizeSliderTool)

	local previewFrame = Instance.new("Frame")
	previewFrame.Name = "BrushSizePreviewFrame"
	previewFrame.LayoutOrder = 1
	previewFrame.Parent = self.frame
	StyleUtils.AddStyleTag(previewFrame, StyleConsts.tags.BrushSizePreviewFrame)

	local previewTile = BaseTile.createComponentFrame() :: Frame
	previewTile.Name = "BrushSizePreviewBaseTile"
	previewTile.Parent = previewFrame
	StyleUtils.AddStyleTag(previewTile, StyleConsts.tags.BrushSizePreviewTile)

	self.previewCircle = Instance.new("Frame")
	self.previewCircle.Name = "BrushSizePreviewCircle"
	self.previewCircle.Parent = previewTile
	StyleUtils.AddStyleTag(self.previewCircle, StyleConsts.tags.BrushSizePreviewCircle)

	local previewCircleStroke = Instance.new("UIStroke")
	previewCircleStroke.Name = "BrushSizePreviewCircleStroke"
	previewCircleStroke.Parent = self.previewCircle
	StyleUtils.AddStyleTag(previewCircleStroke, StyleConsts.tags.BrushSizePreviewCircleStroke)

	self.slider = Slider.new(defaultValue, function(value, isFinalInput)
		self:SetPreviewCircleValue(value)
		onValueChangedCallback(value, isFinalInput)
	end)

	local sliderToolFrame = ToolFrame.createComponentFrame(self.slider:GetFrame(), title)
	sliderToolFrame.LayoutOrder = 2
	sliderToolFrame.Parent = self.frame

	self:SetPreviewCircleValue(defaultValue)

	return self
end

function BrushSizeSliderTool:GetFrame()
	return self.frame
end

return BrushSizeSliderTool
