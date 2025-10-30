--[[
	Creates a panel with a scrollable list of stickers, along with an optional
	region selector and a padding slider. Used to add sticker patterns to the
	editable.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local UI = Client:WaitForChild("UI")
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local Utils = require(Modules:WaitForChild("Utils"))

local Components = UI:WaitForChild("Components")

local ProgressBar = require(Components:WaitForChild("ProgressBar"))
local Panel = require(Components:WaitForChild("Panel"))
local StickerGrid = require(Components:WaitForChild("StickerGrid"))
local RegionPicker = require(Components:WaitForChild("RegionPicker"))
local Slider = require(Components:WaitForChild("Slider"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

local StickerPatternToolUI = {}
StickerPatternToolUI.__index = StickerPatternToolUI

function StickerPatternToolUI.new(
	inputManager,
	onClosePanelCallback: () -> (),
	onDeleteCallback: () -> (),
	onRegionSelectedCallback: (string) -> (),
	onSliderChangedCallback: (number, boolean) -> (),
	defaultSliderVal: number, -- between 0 and 1
	regionParts: { string }?,
	stickerData,
	stickerTool
)
	local self = {}
	setmetatable(self, StickerPatternToolUI)

	self.stickerTool = stickerTool

	self.stickerCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Sticker, Constants.MAX_STICKER_LAYERS)
	local stickerCounterFrame = self.stickerCounter.frame

	local onAddSticker = function()
		self:UpdateProgress()
	end

	local componentsList = { stickerCounterFrame }

	local scrollingFrame = Instance.new("ScrollingFrame")
	Utils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local slider = Slider.createComponentFrame(inputManager, defaultSliderVal, onSliderChangedCallback)
	local sliderTool = ToolFrame.createComponentFrame(slider, "Padding")

	-- Regional patterning is only available on the body
	if regionParts then
		-- The "full model" region should be first
		local modelDisplayName = StyleConsts.modelDisplayName[regionParts[1]]

		local regionPillbar = RegionPicker.createComponentFrame(regionParts, onRegionSelectedCallback)
		local regionSelectTool = ToolFrame.createComponentFrame(regionPillbar, `{modelDisplayName} Section`)
		-- The region selector should be "sticky" and stay to the top of the panel
		table.insert(componentsList, regionSelectTool)

		sliderTool.Parent = scrollingFrame
	else
		-- If we don't have a region selector, the padding slider should be sticky instead.
		table.insert(componentsList, sliderTool)
	end

	local grid = StickerGrid.createComponentFrame(stickerData, stickerTool, onAddSticker, true)
	local gridTool = ToolFrame.createComponentFrame(grid, "Pattern")
	gridTool.Parent = scrollingFrame

	table.insert(componentsList, scrollingFrame)

	self.panel = Panel.createComponentFrame("Pattern", onClosePanelCallback, onDeleteCallback, componentsList)
	self.panel.Name = "PatternStickerToolPanel"

	self:Close()

	return self
end

function StickerPatternToolUI:UpdateProgress()
	self.stickerCounter:UpdateProgress(self.stickerTool.stickerCounter)
end

function StickerPatternToolUI:Open()
	self.panel.Visible = true
	self:UpdateProgress()
end

function StickerPatternToolUI:Close()
	self.panel.Visible = false
end

return StickerPatternToolUI
