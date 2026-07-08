local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utils = require(Modules:WaitForChild("Utils"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleSheet = require(Style:WaitForChild("StyleSheet"))
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Handlers = UI:WaitForChild("Handlers")
local EditingUI = require(Handlers.EditingUI)
local ResetEditsModalUI = require(Handlers.ResetEditsModalUI)
local AccessoryAdjustmentModalUI = require(Handlers.AccessoryAdjustmentModalUI)
local TopBarUI = require(Handlers.TopBarUI)
local PreviewUI = require(Handlers.PreviewUI)

local Components = UI:WaitForChild("Components")
local TextButton = require(Components:WaitForChild("TextButton"))

local BaseUI = {}
BaseUI.__index = BaseUI

function BaseUI.new(manager, modelInfo, fabricTool, stickerTool, brushTool, kitbashTool, previewTool)
	local self = {}
	setmetatable(self, BaseUI)

	self.manager = manager

	-- Force the PlayerGui into landscape mode
	self.prevScreenOrientation = PlayerGui.ScreenOrientation
	PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight

	-- Hide the player list, chat, and other core UI
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	-- Disable jump, hiding jump button on mobile
	local character = LocalPlayer.Character
	if not character or character.Parent == nil then
		character = LocalPlayer.CharacterAdded:Wait()
	end
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "BaseUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = PlayerGui
	self.screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	StyleUtils.AddStyleTag(self.screenGui, StyleConsts.tags.BaseUI)

	-- Create and link styleSheet
	self.style = StyleSheet.new()
	self.style:LinkGui(self.screenGui)

	self.creationPrice = modelInfo:GetCreationPrice()

	stickerTool:ConnectHandlesToStyle(self.style)
	kitbashTool:ConnectHandlesToStyle(self.style)

	self.TopBarUI = TopBarUI.new(self, manager)
	self.ResetEditsModalUI = ResetEditsModalUI.new(self, manager)
	self.AccessoryAdjustmentModalUI = AccessoryAdjustmentModalUI.new(self, manager)
	self.EditingUI = EditingUI.new(self, manager, fabricTool, stickerTool, brushTool, kitbashTool)
	self.PreviewUI = PreviewUI.new(self, manager, previewTool)

	self:CreateBuyButton()

	return self
end

function BaseUI:OnClickedBuyButton()
	BuyRemoteEvent:FireServer()
	self.manager:Quit()
end

function BaseUI:CreateBuyButton()
	self.buyButton = TextButton.createComponentFrame({
		text = Utils.getBuyButtonString(self.creationPrice),
		callback = function()
			self:OnClickedBuyButton()
		end,
	})
	self.buyButton.Name = "BuyButton"

	self.buyButton.Parent = self.screenGui
	StyleUtils.AddStyleTag(self.buyButton, StyleConsts.tags.BuyButton)
	StyleUtils.AddStyleTag(self.buyButton, StyleConsts.tags.EmphasisButton)
end

function BaseUI:HideCoreUIBehindPanel()
	StyleUtils.AddStyleTag(self.buyButton, StyleConsts.tags.CoreUIWithOpenPanel)
	self.TopBarUI:HideBehindPanel()
end

function BaseUI:UnhideCoreUIBehindPanel()
	StyleUtils.RemoveStyleTag(self.buyButton, StyleConsts.tags.CoreUIWithOpenPanel)
	self.TopBarUI:UnhideBehindPanel()
end

function BaseUI:SetUIVisible(visible)
	self.screenGui.Enabled = visible

	if visible == false then
		self.TextureEditingUI:SetUIVisible(false)
		self.MeshEditingUI:SetUIVisible(false)
	end
end

function BaseUI:OpenAvatarPreview()
	self.PreviewUI:Show()
	self.EditingUI:Hide()
end

function BaseUI:ReturnToEditor()
	self.PreviewUI:Hide()
	self.EditingUI:Show()
end

function BaseUI:Destroy()
	self.screenGui:Destroy()

	self.ResetEditsModalUI:Destroy()
	self.AccessoryAdjustmentModalUI:Destroy()
	self.TopBarUI:Destroy()
	self.EditingUI:Destroy()
	self.PreviewUI:Destroy()
	self.style:Destroy()

	-- Restore default UI and orientation
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

	PlayerGui.ScreenOrientation = self.prevScreenOrientation

	local character = LocalPlayer.Character
	if character and character.Humanoid then
		character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

return BaseUI
