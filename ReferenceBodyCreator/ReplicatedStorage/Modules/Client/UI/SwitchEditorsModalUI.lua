--[[
	Surfaces the modal that appears when switching between different creation items. Since this
	surfaces before the baseUI is created (and it should appear above any other
	UI), it has its own screenGui and is passed in style from the parent.
	Called directly from BodyCreationClient.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local Utils = require(Modules:WaitForChild("Utils"))
local UI = Client:WaitForChild("UI")

local Components = UI:WaitForChild("Components")

local Overlay = require(Components:WaitForChild("Overlay"))
local Modal = require(Components:WaitForChild("Modal"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SwitchEditorsModal = {}
SwitchEditorsModal.__index = SwitchEditorsModal

function SwitchEditorsModal.new(style, creationPrice: number, onBuy: () -> (), onContinue: () -> (), onCancel: () -> ())
	local self = {}
	setmetatable(self, SwitchEditorsModal)

	-- Create screenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "ModalUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 100 -- Appear over all other Guis
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None

	style:LinkGui(self.screenGui)

	-- Create overlay
	local overlay = Overlay.createComponentFrame()
	overlay.Parent = self.screenGui

	-- Create modal
	local buttonInfos = {
		-- Buy button
		{
			text = Utils.getBuyButtonString(creationPrice),
			callback = function()
				self:Destroy()
				onBuy()
			end,
		},
		-- Cancel button
		{
			text = "Continue",
			callback = function()
				self:Destroy()
				onContinue()
			end,
		},
		-- Cancel button
		{
			text = "Cancel",
			callback = function()
				self:Destroy()
				onCancel()
			end,
		},
	}

	local modal = Modal.createComponentFrame(
		Constants.EDITOR_SWITCH_TITLE_STRING,
		Constants.EDITOR_SWITCH_BODY_STRING,
		buttonInfos
	)
	modal.Parent = self.screenGui

	return self
end

function SwitchEditorsModal:Destroy()
	-- We only need this to exist when it is first created, so we destroy it
	-- immediately rather than hiding it. Additionally, this should be called
	-- before our callbacks, in case the callbacks take time to execute.
	self.screenGui:Destroy()
end

return SwitchEditorsModal
