--[[
	Creates a panel with a scrollable list of meshes to kitbash with.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local KitbashData = require(Config:WaitForChild("KitbashData")) -- import for typechecking

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local ProgressBar = require(Components:WaitForChild("ProgressBar"))
local Panel = require(Components:WaitForChild("Panel"))
local TileGrid = require(Components:WaitForChild("TileGrid"))

local PIECE_VIEWPORT_OPTIONS = {
	fitPadding = 1.2,
}

local KitbashToolUI = {}
KitbashToolUI.__index = KitbashToolUI

function KitbashToolUI:createKitbashGridComponent()
	local tileInfos = {}
	for _, kitbashPiece: KitbashData.KitbashData in self.kitbashData.GetPieces(self.isMakeup) do
		local onClickCallback = function()
			self.kitbashTool:SelectPiece(kitbashPiece.sourcePart, kitbashPiece.minScale, kitbashPiece.maxScale)
			self:UpdateProgress()
		end

		table.insert(tileInfos, {
			previewInstance = kitbashPiece.sourcePart,
			viewportOptions = PIECE_VIEWPORT_OPTIONS,
			callback = onClickCallback,
		})
	end

	local grid = TileGrid.createComponentFrame(tileInfos)
	grid.Name = "KitbashGrid"

	return grid
end

function KitbashToolUI:SetKitbashTool(kitbashTool)
	self.kitbashTool = kitbashTool
	local editTarget = kitbashTool.modelInfo:GetServerEditTarget()
	local isMakeup = Constants.MAKEUP_ACCESSORY_ASSET_TYPES[editTarget] == true
	if self.isMakeup ~= isMakeup then
		if self.grid then
			self.grid:Destroy()
			self.grid = nil
		end
		self.isMakeup = isMakeup
		if self.panel and self.panel.Visible then
			self:Open()
		end
	end
	self:UpdateProgress()
end

function KitbashToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), kitbashData, kitbashTool)
	local self = {}
	setmetatable(self, KitbashToolUI)

	self.kitbashData = kitbashData

	self.pieceCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Kitbash, Constants.ATLAS_MAX_KITBASH_PIECES)
	local pieceCounterFrame = self.pieceCounter.frame

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)
	self.scrollingFrame = scrollingFrame
	self:SetKitbashTool(kitbashTool)

	self.panel = Panel.createComponentFrame(
		"Add-Ons",
		onClosePanelCallback,
		onDeleteCallback,
		{ pieceCounterFrame, scrollingFrame }
	)
	self.panel.Name = "KitbashToolPanel"

	self:Close()

	return self
end

function KitbashToolUI:UpdateProgress()
	self.pieceCounter:UpdateProgress(#self.kitbashTool.placedPieces)
end

function KitbashToolUI:Open()
	if not self.grid then
		self.grid = self:createKitbashGridComponent()
		self.grid.Parent = self.scrollingFrame
		self.scrollingFrame.CanvasPosition = Vector2.zero
	end
	self.panel.Visible = true
	self:UpdateProgress()
end

function KitbashToolUI:Close()
	self.panel.Visible = false
	if self.grid then
		self.grid:Destroy()
		self.grid = nil
	end
end

return KitbashToolUI
