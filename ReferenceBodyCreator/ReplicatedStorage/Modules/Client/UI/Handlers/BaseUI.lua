local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type definitions

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
local StampBakeModalUI = require(Handlers.StampBakeModalUI)
local TopBarUI = require(Handlers.TopBarUI)
local PreviewUI = require(Handlers.PreviewUI)

local BaseUI = {}
BaseUI.__index = BaseUI

function BaseUI.new(manager, fabricTool, stickerTool, stampTool, brushTool, kitbashTool, previewTool, layerTool)
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

	if stickerTool then
		stickerTool:ConnectHandlesToStyle(self.style)
	end
	if stampTool then
		stampTool:ConnectHandlesToStyle(self.style)
	end
	kitbashTool:ConnectHandlesToStyle(self.style)

	self.TopBarUI = TopBarUI.new(self, manager)
	self.ResetEditsModalUI = ResetEditsModalUI.new(self, manager)
	self.AccessoryAdjustmentModalUI = AccessoryAdjustmentModalUI.new(self, manager)
	if stampTool then
		-- The stamp bake modal only exists during makeup, where the stamp tool is present.
		self.StampBakeModalUI = StampBakeModalUI.new(self, manager)
	end
	self.EditingUI = EditingUI.new(self, manager, fabricTool, stickerTool, stampTool, brushTool, kitbashTool, layerTool)
	self.PreviewUI = PreviewUI.new(self, manager, previewTool)

	return self
end

function BaseUI:OnClickedBuyButton()
	BuyRemoteEvent:FireServer()
	self.manager:Quit()
end

function BaseUI:HideCoreUIBehindPanel()
	self.TopBarUI:HideBehindPanel()
end

function BaseUI:UnhideCoreUIBehindPanel()
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

function BaseUI:SelectLayer(targetLayerInfo: GroupInfo.TargetLayerInfo)
	self.EditingUI:SelectLayer(targetLayerInfo)
end

function BaseUI:Destroy()
	self.screenGui:Destroy()

	self.ResetEditsModalUI:Destroy()
	self.AccessoryAdjustmentModalUI:Destroy()
	if self.StampBakeModalUI then
		self.StampBakeModalUI:Destroy()
	end
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
