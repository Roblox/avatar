--[[
	Warning shown before replacing the selected eyebrow or eyelash accessory.
]]
local Players = game:GetService("Players")

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

local AccessorySwapModalUI = {}
AccessorySwapModalUI.__index = AccessorySwapModalUI

function AccessorySwapModalUI.new(style)
	local self = {}
	setmetatable(self, AccessorySwapModalUI)

	self.doNotShowAgain = false

	-- Create screenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "AccessorySwapModalUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 100 -- Appear over all other Guis
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Enabled = false -- hidden by default

	style:LinkGui(self.screenGui)

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
			text = "Confirm",
			callback = function()
				local onConfirm = self.onConfirm
				if not onConfirm then
					return
				end
				self.doNotShowAgain = showOnce
				self:Close()
				onConfirm()
			end,
		},
		{
			text = "Cancel",
			callback = function()
				self:Close()
			end,
		},
	}

	local modal = Modal.createComponentFrame("", "", buttonInfos, showOnceContent)
	self.titleLabel = modal.TextContainer.TitleText
	self.bodyLabel = modal.TextContainer.BodyText
	modal.Parent = self.screenGui

	return self
end

function AccessorySwapModalUI:Open(category: string, onConfirm: () -> ())
	self:Close()
	if self.doNotShowAgain then
		onConfirm()
	else
		local categoryName = string.lower(category)
		self.titleLabel.Text = "Restart " .. category .. "?"
		self.bodyLabel.Text = "Swapping "
			.. categoryName
			.. " will delete any customization made on your current "
			.. categoryName
		self.onConfirm = onConfirm
		self.screenGui.Enabled = true
	end
end

function AccessorySwapModalUI:Close()
	self.screenGui.Enabled = false
	self.onConfirm = nil
end

function AccessorySwapModalUI:Destroy()
	self:Close()
	self.screenGui:Destroy()
end

return AccessorySwapModalUI
