local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local UIUtils = require(UI:WaitForChild("UIUtils"))
local MeshEditingUI = require(UI:WaitForChild("MeshEditingUI"))
local TextureEditingUI = require(UI:WaitForChild("TextureEditingUI"))
local UIConstants = require(UI:WaitForChild("UIConstants"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BaseUI = {}
BaseUI.__index = BaseUI

local TOP_PADDING = 20
local CORE_UI_PADDING = 12
local CORE_UI_VIEWPORT_HORIZONTAL_PADDING = 16
local TITLE_TEXT_SIZE = 20

function BaseUI.new(manager, fabricTool, stickerTool, brushTool)
	local self = {}
	setmetatable(self, BaseUI)

	self.manager = manager

	-- Force the PlayerGui into landscape mode
	self.prevScreenOrientation = PlayerGui.ScreenOrientation
	PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

	-- Hide the player list and jump button
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	self.prevCharacterJumpPower = StarterPlayer.CharacterJumpPower
	StarterPlayer.CharacterJumpPower = 0

	-- Get height of the core UI top bar
	local guiInset: Vector2 = GuiService:GetGuiInset()

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "BaseUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui

	local TitleText = Instance.new("TextLabel")
	TitleText.Name = "TitleText"
	TitleText.Text = "Body Mesh Editor"
	TitleText.AnchorPoint = Vector2.new(0.5, 0)
	TitleText.Position = UDim2.new(0.5, 0, 0, TOP_PADDING)
	TitleText.TextColor3 = Color3.new(1, 1, 1)
	TitleText.TextSize = TITLE_TEXT_SIZE
	TitleText.Font = Enum.Font.ArialBold
	TitleText.Parent = self.screenGui

	-- Every left bar should be a child of this element, so that we can easily hide/restore the left side of the UI if necessary.
	self.LeftBarsParent = Instance.new("Frame")
	self.LeftBarsParent.Name = "LeftBarsParent"
	self.LeftBarsParent.Size = UDim2.fromScale(1, 1)
	self.LeftBarsParent.BackgroundTransparency = 1
	self.LeftBarsParent.Parent = self.screenGui
	self.LeftBarsParent.Position = UDim2.fromOffset(0, 0)

	local LeftBarsPadding = Instance.new("UIPadding")
	LeftBarsPadding.PaddingLeft = UDim.new(0, CORE_UI_VIEWPORT_HORIZONTAL_PADDING)
	LeftBarsPadding.PaddingRight = UDim.new(0, CORE_UI_VIEWPORT_HORIZONTAL_PADDING)
	LeftBarsPadding.PaddingTop = UDim.new(0, guiInset.Y + CORE_UI_PADDING)
	LeftBarsPadding.PaddingBottom = UDim.new(0, CORE_UI_PADDING)
	LeftBarsPadding.Parent = self.LeftBarsParent

	self.LeftSideBar = self:SetupBaseToolbar()

	self.MeshEditingUI = MeshEditingUI.new(self, manager)
	self.TextureEditingUI = TextureEditingUI.new(self, manager, fabricTool, stickerTool, brushTool)

	-- "Buy" button. For when the user is finished editing their asset and wants to upload it.
	local onClickBuyButton = function()
		self:OnClickedBuyButton()
	end

	UIUtils.CreateBuyButton(onClickBuyButton, self.screenGui)

	return self
end

function BaseUI:OnClickedBuyButton()
	BuyRemoteEvent:FireServer()
	self.manager:Quit()
end

function BaseUI:SetupBaseToolbar()
	local leftSideBar = UIUtils.CreateLeftSideBar()
	leftSideBar.Parent = self.LeftBarsParent

	local CloseButton = UIUtils.CreateCloseButton(UIConstants.LeftBarButtonSize)
	CloseButton.Parent = leftSideBar
	CloseButton.LayoutOrder = 1
	CloseButton.Name = "CloseButton"
	CloseButton.MouseButton1Click:Connect(function()
		self.manager:Quit()
	end)

	local PaintButton = UIUtils.CreateSideBarButton("Paint", "rbxassetid://120516499663451")
	PaintButton.Parent = leftSideBar
	PaintButton.LayoutOrder = 3
	PaintButton.Activated:Connect(function()
		self:SetUIVisible(false)
		self.manager:SetEditMode(Constants.EDIT_MODE_PAINT)

		self.MeshEditingUI:SetUIVisible(false)
		self.TextureEditingUI:SetUIVisible(true)
	end)

	local MeshButton = UIUtils.CreateSideBarButton("Mesh", "rbxassetid://119065236297406")
	MeshButton.Parent = leftSideBar
	MeshButton.LayoutOrder = 4
	MeshButton.Activated:Connect(function()
		self:SetUIVisible(false)
		self.manager:SetEditMode(Constants.EDIT_MODE_MESH)

		self.TextureEditingUI:SetUIVisible(false)
		self.MeshEditingUI:SetUIVisible(true)
	end)

	local ResetButton = UIUtils.CreateSideBarButton("Reset", "rbxassetid://127065728325868")
	ResetButton.Parent = leftSideBar
	ResetButton.LayoutOrder = 5
	ResetButton.Activated:Connect(function()
		self.manager:ResetModelInfo()
	end)

	return leftSideBar
end

function BaseUI:SetUIVisible(visible)
	self.screenGui.Enabled = visible

	if visible == false then
		self.TextureEditingUI:SetUIVisible(false)
		self.MeshEditingUI:SetUIVisible(false)
	end
end

function BaseUI:Destroy()
	self.screenGui:Destroy()

	self.TextureEditingUI:Destroy()
	self.MeshEditingUI:Destroy()

	PlayerGui.ScreenOrientation = self.prevScreenOrientation
	StarterPlayer.CharacterJumpPower = self.prevCharacterJumpPower
end

return BaseUI
