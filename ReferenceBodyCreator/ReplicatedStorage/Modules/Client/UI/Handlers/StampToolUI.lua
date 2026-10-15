--[[
	UI panel for the stamp tool. Extends the sticker tool UI; behaves identically for now.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Style = UI:WaitForChild("Style")
local Handlers = UI:WaitForChild("Handlers")
local StickerToolUI = require(Handlers:WaitForChild("StickerToolUI"))
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Panel = require(Components:WaitForChild("Panel"))


local StampToolUI = setmetatable({}, { __index = StickerToolUI })
StampToolUI.__index = StampToolUI

function StampToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), stickerData, stampTool, showActionBarCallback: (boolean) -> ())
	local self = {}
	setmetatable(self, StampToolUI)

	self.stickerData = stickerData
	self.stickerTool = stampTool -- we must call this sticker tool so the parent class can still access it
	self.showActionBarCallback = showActionBarCallback

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local grid = self:createStickerGridComponent()
	grid.Parent = scrollingFrame

	self.panel = Panel.createComponentFrame(
		"Stamps",
		onClosePanelCallback,
		nil, -- stamp panel has no trash/delete icon
		{ scrollingFrame }
	)
	self.panel.Name = "StampToolPanel"

	self:Close()

	return self
end

function StampToolUI:UpdateProgress()
	-- currentlySelectedSticker is 0 when no stamp is being placed
	local isPlacingStamp = self.stickerTool.currentlySelectedSticker ~= 0
	self.showActionBarCallback(isPlacingStamp)
end

return StampToolUI
