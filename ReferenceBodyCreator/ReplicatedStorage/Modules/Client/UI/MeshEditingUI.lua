-- This is the UI for the body mesh editing tool, a subsection of the body creation tool.
-- It includes some sliders for adjusting blend shape values of the body overall (skinny/large/muscular/etc)
-- as well as buttons for entering the widget-based editing mode for the face, head, and body (ShowMeshEditControls).
-- MeshEditingWidgetManager handles editing the mesh via these widgets.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local UIUtils = require(UI:WaitForChild("UIUtils"))
local UIConstants = require(UI:WaitForChild("UIConstants"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MeshEditingUI = {}
MeshEditingUI.__index = MeshEditingUI

local TOP_PADDING = 20
local CORE_UI_PADDING = 12
local CORE_UI_VIEWPORT_HORIZONTAL_PADDING = 16

function MeshEditingUI.new(baseUI, manager)
	local self = {}
	setmetatable(self, MeshEditingUI)

	self.baseUI = baseUI
	self.manager = manager

	-- Hide the player list
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	-- Get height of the core UI top bar
	local guiInset: Vector2 = GuiService:GetGuiInset()

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "MeshEditingUI"
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
	TitleText.TextSize = 20
	TitleText.FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Bold)
	TitleText.Parent = self.screenGui

	-- Every left bar should be a child of this element, so that we can easily hide/restore the left side of the UI if necessary.
	self.LeftBarsParent = Instance.new("Frame")
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
	self.ScaleToolBar = self:SetupScaleToolbar()

	-- "Buy" button. For when the user is finished editing their asset and wants to upload it.
	local onClickBuyButton = function()
		self:OnClickedBuyButton()
	end
	UIUtils.CreateBuyButton(onClickBuyButton, self.screenGui)

	self:SetUIVisible(false)

	return self
end

-- Create the toolbar on the left side of the screen, which contains buttons for
-- entering the widget-based mesh editing mode for the face, head, and body.
function MeshEditingUI:SetupBaseToolbar()
	local leftSideBar = UIUtils.CreateLeftSideBar()
	leftSideBar.Parent = self.LeftBarsParent

	local BackButton = UIUtils.CreateBackButton()
	BackButton.Parent = leftSideBar
	BackButton.LayoutOrder = 1
	BackButton.Activated:Connect(function()
		-- If we're showing the mesh edit controls, simply hide them. Otherwise, exit the edit mode.
		if self.manager:IsShowingMeshEditControls() then
			UIUtils.SetButtonState(self.headButton, false)
			UIUtils.SetButtonState(self.bodyButton, false)
			self.manager:HideMeshEditControls()
			self.manager:ResetCamera()
		else
			self:SetUIVisible(false)
			self.manager:HideMeshEditControls()
			self.manager:ExitEditMode()

			-- Return to main UI
			self.baseUI:SetUIVisible(true)
		end
	end)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.Parent = BackButton

	self.headButton = UIUtils.CreateSideBarButton("Head", "rbxassetid://89986272144373", "rbxassetid://87307863095623")
	UIUtils.AddButtonBackground(self.headButton, nil, nil, false)
	self.headButton.Parent = leftSideBar
	self.headButton.LayoutOrder = 3

	self.bodyButton =
		UIUtils.CreateSideBarButton("Body", "rbxassetid://119065236297406", "rbxassetid://109277319091198")
	UIUtils.AddButtonBackground(self.bodyButton, UDim.new(0, UIConstants.BarCornerRadius), true, false)
	self.bodyButton.Parent = leftSideBar
	self.bodyButton.LayoutOrder = 4

	self.headButton.Activated:Connect(function()
		-- Enable UI widgets for deforming broad head features (head shape/size)
		self.manager:ShowMeshEditControls("Head")
		UIUtils.SetButtonState(self.headButton, true)
		UIUtils.SetButtonState(self.bodyButton, false)
	end)
	self.bodyButton.Activated:Connect(function()
		-- Enable UI widgets for deforming all other limbs
		self.manager:ShowMeshEditControls("Body")
		UIUtils.SetButtonState(self.headButton, false)
		UIUtils.SetButtonState(self.bodyButton, true)
	end)

	return leftSideBar
end

function MeshEditingUI:SetupScaleToolbar()
	local scaleToolBar = UIUtils.CreateLeftSideBar()
	scaleToolBar.Parent = self.LeftBarsParent

	local BackButton = UIUtils.CreateBackButton()
	BackButton.Parent = scaleToolBar
	BackButton.LayoutOrder = 1
	BackButton.Activated:Connect(function()
		self.ScaleToolBar.Visible = false

		-- Return to base toolbar
		self:SetUIVisible(true)
	end)

	local SizeButton = UIUtils.CreateSideBarButton("Face", "rbxassetid://10535998674")
	SizeButton.Parent = scaleToolBar
	SizeButton.LayoutOrder = 2
	SizeButton.Activated:Connect(function() end)

	scaleToolBar.Visible = false

	return scaleToolBar
end

function MeshEditingUI:HideSideBar()
	self.LeftSideBar.Active = false
	self.LeftSideBar.Visible = false
end

function MeshEditingUI:SetUIVisible(visible)
	self.screenGui.Enabled = visible
end

function MeshEditingUI:OnClickedBuyButton()
	-- When publishing, hide mesh edit controls, tell the server to publish,
	-- and quit out of the editing mode
	self.manager:HideMeshEditControls()
	BuyRemoteEvent:FireServer()
	self.manager:Quit()
end

function MeshEditingUI:Destroy()
	self.screenGui:Destroy()
end

return MeshEditingUI
