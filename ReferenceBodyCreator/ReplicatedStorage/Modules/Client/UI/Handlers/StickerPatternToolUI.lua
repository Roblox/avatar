--[[
	Creates a panel with a scrollable list of stickers, along with an optional
	region selector and a padding slider. Used to add sticker patterns to the
	editable.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local StickerData = require(Config:WaitForChild("StickerData")) -- import for typechecking

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local ProgressBar = require(Components:WaitForChild("ProgressBar"))
local Panel = require(Components:WaitForChild("Panel"))
local TileGrid = require(Components:WaitForChild("TileGrid"))
local RegionPicker = require(Components:WaitForChild("RegionPicker"))
local Slider = require(Components:WaitForChild("Slider"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

local StickerPatternToolUI = {}
StickerPatternToolUI.__index = StickerPatternToolUI

function StickerPatternToolUI:createStickerGridComponent()
	local tileInfos = {}

	for _, sticker: StickerData.StickerData in pairs(self.stickerData) do
		local onClickCallback = function()
			self.stickerTool:ApplySticker(sticker.textureId)
			self:UpdateProgress()
			self.stickerTool:SetPatterned(true)
		end

		local info = {
			iconId = sticker.textureId,
			callback = onClickCallback,
		}
		table.insert(tileInfos, info)
	end

	local grid = TileGrid.createComponentFrame(tileInfos)
	grid.Name = "StickerGrid"

	return grid
end

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

	self.stickerData = stickerData
	self.stickerTool = stickerTool

	self.stickerCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Sticker, Constants.MAX_STICKER_LAYERS)
	local stickerCounterFrame = self.stickerCounter.frame

	local componentsList = { stickerCounterFrame }

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local slider = Slider.createComponentFrame(defaultSliderVal, onSliderChangedCallback)
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

	local grid = self:createStickerGridComponent()
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
