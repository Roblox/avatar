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

local KitbashToolUI = {}
KitbashToolUI.__index = KitbashToolUI

function KitbashToolUI:createKitbashGridComponent()
	local tileInfos = {}

	-- We expect kitbashData.pieces to contain a name and thumbnail, and
	-- possibly minScale and maxScale.
	for _, kitbashPiece: KitbashData.KitbashData in pairs(self.kitbashData.pieces) do
		local onClickCallback = function()
			local minScale = kitbashPiece.minScale
			local maxScale = kitbashPiece.maxScale
			self.kitbashTool:SelectPiece(kitbashPiece.name, minScale, maxScale)
			self:UpdateProgress()
		end

		local info = {
			iconId = kitbashPiece.thumbnail,
			callback = onClickCallback,
		}
		table.insert(tileInfos, info)
	end

	local grid = TileGrid.createComponentFrame(tileInfos)
	grid.Name = "KitbashGrid"

	return grid
end

function KitbashToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), kitbashData, kitbashTool)
	local self = {}
	setmetatable(self, KitbashToolUI)

	self.kitbashData = kitbashData
	self.kitbashTool = kitbashTool

	self.pieceCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Kitbash, Constants.ATLAS_MAX_KITBASH_PIECES)
	local pieceCounterFrame = self.pieceCounter.frame

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local grid = self:createKitbashGridComponent()
	grid.Parent = scrollingFrame

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
	self.panel.Visible = true
	self:UpdateProgress()
end

function KitbashToolUI:Close()
	self.panel.Visible = false
end

return KitbashToolUI
