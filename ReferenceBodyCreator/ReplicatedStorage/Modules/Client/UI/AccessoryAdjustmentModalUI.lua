--[[
	Surfaces the modal that appears on clicking the reset button. Since we want
	this to appear over any existing UI, it has its own screenGui.
	Called from BaseUI
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Components = UI:WaitForChild("Components")

local Overlay = require(Components:WaitForChild("Overlay"))
local Modal = require(Components:WaitForChild("Modal"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AccessoryAdjustmentModal = {}
AccessoryAdjustmentModal.__index = AccessoryAdjustmentModal

function AccessoryAdjustmentModal.new(baseUI, manager)
	local self = {}
	setmetatable(self, AccessoryAdjustmentModal)

	self.baseUI = baseUI
	self.manager = manager

	-- Create screenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "AccessoryAdjustmentModalUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 100 -- Appear over all other Guis
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Enabled = false -- hidden by default

	self.baseUI.style:LinkGui(self.screenGui)

	-- Create overlay
	local overlay = Overlay.createComponentFrame()
	overlay.Parent = self.screenGui

	-- Create Modal
	local buttonInfos = {
		{
			text = "Ok",
			callback = function()
				self:Close()
			end,
		},
	}

	local modal = Modal.createComponentFrame(
		Constants.ACCESSORY_ADJUSTMENT_TITLE_STRING,
		Constants.ACCESSORY_ADJUSTMENT_BODY_STRING,
		buttonInfos
	)
	modal.Parent = self.screenGui

	return self
end

function AccessoryAdjustmentModal:Open()
	self.screenGui.Enabled = true
end

function AccessoryAdjustmentModal:Close()
	self.screenGui.Enabled = false
end

function AccessoryAdjustmentModal:Destroy()
	self.screenGui:Destroy()
end

return AccessoryAdjustmentModal
