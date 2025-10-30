--[[
	Creates a panel with a scrollable list of stickers, used to interact with
	stickers. Does not include patterning.
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

local StickerToolUI = {}
StickerToolUI.__index = StickerToolUI

function StickerToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), stickerData, stickerTool)
	local self = {}
	setmetatable(self, StickerToolUI)

	self.stickerTool = stickerTool

	self.stickerCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Sticker, Constants.MAX_STICKER_LAYERS)
	local stickerCounterFrame = self.stickerCounter.frame

	local onAddSticker = function()
		self:UpdateProgress()
	end

	local scrollingFrame = Instance.new("ScrollingFrame")
	Utils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local grid = StickerGrid.createComponentFrame(stickerData, stickerTool, onAddSticker)
	grid.Parent = scrollingFrame

	self.panel = Panel.createComponentFrame(
		"Stickers",
		onClosePanelCallback,
		onDeleteCallback,
		{ stickerCounterFrame, scrollingFrame }
	)
	self.panel.Name = "StickerToolPanel"

	self:Close()

	return self
end

function StickerToolUI:UpdateProgress()
	self.stickerCounter:UpdateProgress(self.stickerTool.stickerCounter)
end

function StickerToolUI:Open()
	self.panel.Visible = true
	self:UpdateProgress()
end

function StickerToolUI:Close()
	self.panel.Visible = false
end

return StickerToolUI
