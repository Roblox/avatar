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

function MeshEditingUI:CreateVerticalSlider(minValue, maxValue, defaultValue, onValueChangedCallback, showElementOnDrag)
	local Frame = Instance.new("Frame")
	Frame.Name = "Slider"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.SliderLength)

	UIUtils.AddUICorner(Frame, UIConstants.BarCornerRadius)

	local Selector = Instance.new("Frame")
	Selector.Name = "Selector"
	Selector.BackgroundTransparency = 1
	Selector.Size = UDim2.new(0, 40, 0, UIConstants.SliderSelectorLength)
	Selector.Position = UDim2.fromScale(0.5, 0.5)
	Selector.AnchorPoint = Vector2.new(0.5, 0.5)
	Selector.Parent = Frame

	-- The vertical line is shaded differently above and below the pointer.
	local TopFillFrame = Instance.new("Frame")
	TopFillFrame.Name = "Selector"
	TopFillFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TopFillFrame.Size = UDim2.new(0, 5, 1, 0)
	TopFillFrame.Position = UDim2.fromScale(0.5, 0.5)
	TopFillFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	TopFillFrame.Parent = Selector

	local BottomFillFrame = Instance.new("Frame")
	BottomFillFrame.Name = "FillFrame"
	BottomFillFrame.BackgroundColor3 = Color3.fromRGB(31, 179, 115)
	BottomFillFrame.Active = false
	BottomFillFrame.Parent = TopFillFrame
	BottomFillFrame.AnchorPoint = Vector2.new(0.5, 1)
	BottomFillFrame.Position = UDim2.fromScale(0.5, 1)

	local Pointer = Instance.new("ImageLabel")
	Pointer.Name = "Pointer"
	Pointer.Image = "rbxassetid://10298652615"
	Pointer.BackgroundTransparency = 1
	Pointer.Size = UDim2.fromOffset(50, 50)
	Pointer.AnchorPoint = Vector2.new(0.5, 0.5)
	Pointer.Parent = Selector

	local function updateSliderPosFromValue(value)
		local valueAsPercentage = 1 - ((value - minValue) / (maxValue - minValue))
		local newPosition = valueAsPercentage * Selector.AbsoluteSize.Y
		Pointer.Position = UDim2.new(0.5, 0, 0, newPosition)
		BottomFillFrame.Size = UDim2.fromScale(1, 1 - valueAsPercentage)
	end

	local function updateValue(value, bIsFinalInput)
		updateSliderPosFromValue(value)

		onValueChangedCallback(value, bIsFinalInput)
	end

	updateValue(defaultValue)

	local function inputAt(position, bIsFinalInput)
		local adjusted = math.clamp(position.Y - Selector.AbsolutePosition.Y, 0, Selector.AbsoluteSize.Y)
			/ Selector.AbsoluteSize.Y

		updateValue(minValue + ((maxValue - minValue) * (1 - adjusted)), bIsFinalInput)
	end

	local mouseDown = false
	Selector.InputBegan:Connect(function(input, _gameProcessed)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if self.manager.InputManager:TryGrabLock(self) == false then
			return
		end

		mouseDown = true
		if showElementOnDrag then
			showElementOnDrag.Visible = true
		end

		inputAt(input.Position)
	end)
	Selector.InputChanged:Connect(function(input, _gameProcessed)
		if not mouseDown then
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		inputAt(input.Position)
	end)
	Selector.InputEnded:Connect(function(input, gameProcessed)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if not gameProcessed then
			inputAt(input.Position, true)
		end

		if showElementOnDrag then
			showElementOnDrag.Visible = false
		end

		mouseDown = false
	end)

	return { Frame, updateSliderPosFromValue }
end

function MeshEditingUI:CreateHorizontalSlider(
	minValue,
	maxValue,
	defaultValue,
	onValueChangedCallback,
	showElementOnDrag
)
	local Frame = Instance.new("Frame")
	Frame.Name = "Slider"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(0, UIConstants.SliderLength, 0, 70)

	UIUtils.AddUICorner(Frame, UIConstants.BarCornerRadius)

	local SelectorParent = Instance.new("Frame")
	SelectorParent.Name = "SelectorParent"
	SelectorParent.BackgroundTransparency = 1
	SelectorParent.Size = UDim2.new(0, UIConstants.SliderLength, 0, 40)
	SelectorParent.Position = UDim2.fromScale(0.5, 0.5)
	SelectorParent.AnchorPoint = Vector2.new(0.5, 0.5)
	SelectorParent.Parent = Frame

	local Selector = Instance.new("Frame")
	Selector.Name = "Selector"
	Selector.BackgroundTransparency = 1
	Selector.Size = UDim2.new(0, UIConstants.SliderSelectorLength, 0, 40)
	Selector.Position = UDim2.fromScale(0.5, 0.5)
	Selector.AnchorPoint = Vector2.new(0.5, 0.5)
	Selector.Parent = SelectorParent

	-- The vertical line is shaded differently on each side of the pointer.
	local LeftFillFrame = Instance.new("Frame")
	LeftFillFrame.Name = "Selector"
	LeftFillFrame.BackgroundColor3 = Color3.fromRGB(31, 179, 115)
	LeftFillFrame.Size = UDim2.new(1, 0, 0, 5)
	LeftFillFrame.Position = UDim2.fromScale(0.5, 0.5)
	LeftFillFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	LeftFillFrame.Parent = Selector

	local RightFillFrame = Instance.new("Frame")
	RightFillFrame.Name = "FillFrame"
	RightFillFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	RightFillFrame.Active = false
	RightFillFrame.Parent = LeftFillFrame
	RightFillFrame.AnchorPoint = Vector2.new(1, 0.5)
	RightFillFrame.Position = UDim2.fromScale(1, 0.5)

	local Pointer = Instance.new("ImageLabel")
	Pointer.Name = "Pointer"
	Pointer.Image = "rbxassetid://10298652615"
	Pointer.BackgroundTransparency = 1
	Pointer.Size = UDim2.fromOffset(50, 50)
	Pointer.AnchorPoint = Vector2.new(0.5, 0.5)
	Pointer.Parent = Selector

	local function updateSliderPosFromValue(value)
		local valueAsPercentage = ((value - minValue) / (maxValue - minValue))
		local newPosition = valueAsPercentage * Selector.AbsoluteSize.X
		Pointer.Position = UDim2.new(0, newPosition, 0.5, 0)
		RightFillFrame.Size = UDim2.fromScale(1 - valueAsPercentage, 1)
	end

	local function updateValue(value, bIsFinalInput)
		updateSliderPosFromValue(value)

		onValueChangedCallback(value, bIsFinalInput)
	end

	updateValue(defaultValue)

	local function inputAt(position, bIsFinalInput)
		local adjusted = math.clamp(position.X - Selector.AbsolutePosition.X, 0, Selector.AbsoluteSize.X)
			/ Selector.AbsoluteSize.X

		updateValue(minValue + ((maxValue - minValue) * adjusted), bIsFinalInput)
	end

	local mouseDown = false
	SelectorParent.InputBegan:Connect(function(input, _gameProcessed)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if self.manager:GetInputManager():TryGrabLock(self) == false then
			return
		end

		mouseDown = true
		if showElementOnDrag then
			showElementOnDrag.Visible = true
		end

		inputAt(input.Position)
	end)
	SelectorParent.InputChanged:Connect(function(input, _gameProcessed)
		if not mouseDown then
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		inputAt(input.Position)
	end)
	SelectorParent.InputEnded:Connect(function(input, gameProcessed)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if not gameProcessed then
			inputAt(input.Position, true)
		end

		if showElementOnDrag then
			showElementOnDrag.Visible = false
		end

		mouseDown = false
	end)

	return { Frame, updateSliderPosFromValue }
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
