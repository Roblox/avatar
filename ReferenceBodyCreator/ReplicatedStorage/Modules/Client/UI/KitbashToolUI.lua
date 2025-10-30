--[[
	Creates a panel with a scrollable list of meshes to kitbash with.
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
local KitbashGrid = require(Components:WaitForChild("KitbashGrid"))

local KitbashToolUI = {}
KitbashToolUI.__index = KitbashToolUI

function KitbashToolUI.new(onClosePanelCallback: () -> (), onDeleteCallback: () -> (), kitbashData, kitbashTool)
	local self = {}
	setmetatable(self, KitbashToolUI)

	self.kitbashTool = kitbashTool

	self.pieceCounter = ProgressBar.new(Constants.COUNTER_STRINGS.Kitbash, Constants.ATLAS_MAX_KITBASH_PIECES)
	local pieceCounterFrame = self.pieceCounter.frame

	local onAddPiece = function()
		self:UpdateProgress()
	end

	local scrollingFrame = Instance.new("ScrollingFrame")
	Utils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local grid = KitbashGrid.createComponentFrame(kitbashData, kitbashTool, onAddPiece)
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
