--[[
	Creates a panel with a scrollable list of stickers, used to interact with
	stickers. Does not include patterning.
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
local Panel = require(Components:WaitForChild("Panel"))
local TileGrid = require(Components:WaitForChild("TileGrid"))
local ItemSelector = require(Components:WaitForChild("ItemSelector"))

local StickerToolUI = {}
StickerToolUI.__index = StickerToolUI

function StickerToolUI:createStickerGridComponent()
	local tileInfos = {}

	for _, sticker: StickerData.StickerData in pairs(self.stickerData) do
		local onClickCallback = function()
			self.stickerTool:ApplySticker(sticker.textureId)
			self:UpdateProgress()
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

function StickerToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), stickerData, stickerTool)
	local self = {}
	setmetatable(self, StickerToolUI)

	self.stickerData = stickerData
	self.stickerTool = stickerTool

	self.itemSelector = ItemSelector.new(Constants.MAX_STICKER_LAYERS, function(index: number)
		self.stickerTool:SelectSticker(index)
	end)
	local itemSelectorFrame = self.itemSelector.frame

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local grid = self:createStickerGridComponent()
	grid.Parent = scrollingFrame

	self.panel = Panel.createComponentFrame(
		"Stickers",
		onClosePanelCallback,
		onDeleteCallback,
		{ itemSelectorFrame, scrollingFrame }
	)
	self.panel.Name = "StickerToolPanel"

	self:Close()

	return self
end

function StickerToolUI:UpdateProgress()
	self.itemSelector:UpdateProgress(self.stickerTool.appliedStickers, self.stickerTool.currentlySelectedSticker)
end

function StickerToolUI:Open()
	self.panel.Visible = true
	self:UpdateProgress()
end

function StickerToolUI:Close()
	self.panel.Visible = false
end

return StickerToolUI
