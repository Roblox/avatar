--[[
	Confirmation modal shown before an in-progress stamp is merged (baked) into its layer.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent
local Components = UI:WaitForChild("Components")
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local Overlay = require(Components:WaitForChild("Overlay"))
local Modal = require(Components:WaitForChild("Modal"))
local TwoStateIconButton = require(Components:WaitForChild("TwoStateIconButton"))

local StampBakeModal = {}
StampBakeModal.__index = StampBakeModal

function StampBakeModal.new(baseUI, manager)
	local self = {}
	setmetatable(self, StampBakeModal)

	self.manager = manager

	self.doNotShowAgain = false

	-- Create screenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "StampBakeModalUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 100 -- Appear over all other Guis
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Enabled = false -- hidden by default

	baseUI.style:LinkGui(self.screenGui)

	-- Create overlay
	local overlay = Overlay.createComponentFrame()
	overlay.Parent = self.screenGui

	-- Create Modal
	local showOnce = false
	local showOnceContent = Instance.new("Frame")
	showOnceContent.Name = "ShowOnceContent"
	StyleUtils.AddStyleTag(showOnceContent, StyleConsts.tags.ModalMiddleContent)

	local showOnceButton
	local showOnceButtonFrame
	showOnceButton = TwoStateIconButton.new(StyleConsts.icons.Checkmark, "", function(isActive)
		showOnce = not isActive
		showOnceButton:SetActive(showOnce)
		StyleUtils.SetStyleTag(showOnceButtonFrame, StyleConsts.tags.ModalTwoStateIconButtonActive, showOnce)
	end)
	showOnceButton:SetActive(showOnce)
	showOnceButtonFrame = showOnceButton:GetFrame()
	showOnceButtonFrame.LayoutOrder = 1
	showOnceButtonFrame.Parent = showOnceContent
	StyleUtils.AddStyleTag(showOnceButtonFrame, StyleConsts.tags.ModalTwoStateIconButton)

	local showOnceLabel = Instance.new("TextLabel")
	showOnceLabel.Name = "ShowOnceLabel"
	showOnceLabel.Text = "Don't show again"
	showOnceLabel.LayoutOrder = 2
	showOnceLabel.Parent = showOnceContent

	local buttonInfos = {
		{
			text = "Merge Stamp",
			callback = function()
				self.doNotShowAgain = showOnce
				self.manager:BakeStamp()
				self:Close()
			end,
		},
		{
			text = "Cancel",
			callback = function()
				self.manager:CancelStampBake()
				self:Close()
			end,
		},
	}

	local modal = Modal.createComponentFrame(
		Constants.STAMP_BAKE_TITLE_STRING,
		Constants.STAMP_BAKE_BODY_STRING,
		buttonInfos,
		showOnceContent
	)
	modal.Parent = self.screenGui

	return self
end

function StampBakeModal:Open()
	if self.doNotShowAgain then
		self.manager:BakeStamp()
	else
		self.screenGui.Enabled = true
	end
end

function StampBakeModal:Close()
	self.screenGui.Enabled = false
end

function StampBakeModal:Destroy()
	self.screenGui:Destroy()
end

return StampBakeModal
