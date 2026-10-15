--[[
	Warning shown before switching makeup editing to an alternate head.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Constants = require(Modules:WaitForChild("Config"):WaitForChild("Constants"))
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent
local Components = UI:WaitForChild("Components")
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local Overlay = require(Components:WaitForChild("Overlay"))
local Modal = require(Components:WaitForChild("Modal"))
local TwoStateIconButton = require(Components:WaitForChild("TwoStateIconButton"))

-- Remember the choice across editor recreation for this play session.
local doNotShowAgain = false

local MakeupHeadSwapModalUI = {}
MakeupHeadSwapModalUI.__index = MakeupHeadSwapModalUI

function MakeupHeadSwapModalUI.new(style)
	local self = setmetatable({}, MakeupHeadSwapModalUI)
	self.destroyed = false

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "MakeupHeadSwapModalUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 100
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Enabled = false
	self.screenGui.Parent = PlayerGui
	style:LinkGui(self.screenGui)

	local overlay = Overlay.createComponentFrame()
	overlay.Parent = self.screenGui

	local showOnceContent = Instance.new("Frame")
	showOnceContent.Name = "ShowOnceContent"
	StyleUtils.AddStyleTag(showOnceContent, StyleConsts.tags.ModalMiddleContent)

	self.showOnceButton = TwoStateIconButton.new(StyleConsts.icons.Checkmark, "", function(isActive)
		self:SetShowOnce(not isActive)
	end)
	local showOnceButtonFrame = self.showOnceButton:GetFrame()
	showOnceButtonFrame.LayoutOrder = 1
	showOnceButtonFrame.Parent = showOnceContent
	StyleUtils.AddStyleTag(showOnceButtonFrame, StyleConsts.tags.ModalTwoStateIconButton)
	self:SetShowOnce(false)

	local showOnceLabel = Instance.new("TextLabel")
	showOnceLabel.Name = "ShowOnceLabel"
	showOnceLabel.Text = "Don't show again"
	showOnceLabel.LayoutOrder = 2
	showOnceLabel.Parent = showOnceContent

	local modal =
		Modal.createComponentFrame(Constants.MAKEUP_HEAD_SWAP_TITLE_STRING, Constants.MAKEUP_HEAD_SWAP_BODY_STRING, {
			{
				text = "Switch Head",
				callback = function()
					local onConfirm = self.onConfirm
					if not onConfirm then
						return
					end
					doNotShowAgain = self.showOnce
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
		}, showOnceContent)
	modal.Parent = self.screenGui

	return self
end

function MakeupHeadSwapModalUI:SetShowOnce(isSelected: boolean)
	self.showOnce = isSelected
	self.showOnceButton:SetActive(isSelected)
	StyleUtils.SetStyleTag(self.showOnceButton:GetFrame(), StyleConsts.tags.ModalTwoStateIconButtonActive, isSelected)
end

function MakeupHeadSwapModalUI:Open(onConfirm: () -> ())
	if self.destroyed or self.screenGui.Enabled then
		return
	end
	if doNotShowAgain then
		onConfirm()
		return
	end
	self.onConfirm = onConfirm
	self:SetShowOnce(false)
	self.screenGui.Enabled = true
end

function MakeupHeadSwapModalUI:Close()
	self.onConfirm = nil
	self.screenGui.Enabled = false
end

function MakeupHeadSwapModalUI:Destroy()
	self.destroyed = true
	self:Close()
	self.screenGui:Destroy()
end

return MakeupHeadSwapModalUI
