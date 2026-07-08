--[[
	Creates the UI used to switch between the user avatar and a provided
	avatar in the avatar preview feature.
]]

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local SegmentedControl = require(Components:WaitForChild("SegmentedControl"))

local PreviewUI = {}
PreviewUI.__index = PreviewUI

function PreviewUI.new(baseUI, manager, previewTool)
	local self = {}
	setmetatable(self, PreviewUI)

	self.baseUI = baseUI
	self.manager = manager
	self.previewTool = previewTool
	self.style = baseUI.style
	self.hasSeenAccessoryAdjustmentModal = false

	-- Setup screen gui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "PreviewUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	if GuiService:IsTenFootInterface() then
		self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	else
		self.screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	end
	self.screenGui.Parent = PlayerGui

	self.style:LinkGui(self.screenGui)

	-- Preview UI parent frame
	self.frame = Instance.new("Frame")
	self.frame.Parent = self.screenGui
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.PreviewUIParent)

	-- Create switcher
	self.switcher = SegmentedControl.createComponentFrame({
		-- Default avatar
		{
			text = "Default",
			callback = function()
				self:PreviewOnDefault()
			end,
		},
		-- Player avatar
		{
			text = "My Avatar",
			callback = function()
				self:PreviewOnAvatar()
			end,
		},
	})
	self.switcher.Parent = self.frame
	StyleUtils.AddStyleTag(self.switcher, StyleConsts.tags.AvatarPreviewSwitcher)

	-- Track currently selected previewer
	self.currentSelection = 1

	-- Not open by default
	self.screenGui.Enabled = false

	return self
end

function PreviewUI:PreviewCurrentSelection()
	if self.currentSelection == 1 then
		self.previewTool:MoveCameraToRoxy()
	else
		self.previewTool:MoveCameraToPlayerAvatar()
	end
end

function PreviewUI:PreviewOnDefault()
	self.currentSelection = 1
	self:PreviewCurrentSelection()
end

function PreviewUI:GetShouldSeeAdjustmentModal()
	local avatarAssetType = self.manager.modelInfo:GetAvatarAssetType()

	if avatarAssetType then
		return Constants.ADJUSTABLE_RIGID_ACCESSORIES[avatarAssetType]
	else
		return false
	end
end

function PreviewUI:PreviewOnAvatar()
	if not self.hasSeenAccessoryAdjustmentModal and self:GetShouldSeeAdjustmentModal() then
		self.hasSeenAccessoryAdjustmentModal = true
		self.baseUI.AccessoryAdjustmentModalUI:Open()
	end
	self.currentSelection = 2
	self:PreviewCurrentSelection()
end

function PreviewUI:Hide()
	self.screenGui.Enabled = false

	self.previewTool:EndPreview()
end

function PreviewUI:Show()
	self.screenGui.Enabled = true

	self.previewTool:ApplyAccessoryToBodies()
	self:PreviewCurrentSelection()
end

function PreviewUI:Destroy()
	self.screenGui:Destroy()
end

return PreviewUI
