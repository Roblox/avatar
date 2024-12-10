local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utils = require(Modules:WaitForChild("Utils"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local SidePanelUI = require(UI:WaitForChild("SidePanelUI"))
local ColorPicker = require(UI:WaitForChild("ColorPicker"))
local UIUtils = require(UI:WaitForChild("UIUtils"))
local UIConstants = require(UI:WaitForChild("UIConstants"))
local RegionSelection = require(UI:WaitForChild("RegionSelection"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local StickerData = require(Config:WaitForChild("StickerData"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TextureEditingUI = {}
TextureEditingUI.__index = TextureEditingUI

local TOOLTIP_VERTICAL_PADDING = 4
local TOOLTIP_HORIZONTAL_PADDING = 4
local TOOLTIP_INTERNAL_PADDING = 2
local TOOLTIP_CLOSE_BUTTON_HEIGHT = 20
local TOOLTIP_FONT_SIZE = 18

local BUTTON_HEIGHT = 40
local FRAME_MARGIN = 4
local RIGHT_BAR_WIDTH = 140
local TOP_PADDING = 20
local STICKER_BUTTON_STROKE_SIZE = 1.5
local STICKER_ICON_SIZE = 120
local STICKER_PANEL_HEADER_HEIGHT = 10 -- 110

local BRUSH_TOOLTIP_SIZE = 50
local ACTION_BUTTON_SIZE = 32 -- Buttons like preview
local CORE_UI_PADDING = 12
local CORE_UI_VIEWPORT_HORIZONTAL_PADDING = 16
local STICKERS_PER_ROW = 3

local BUTTON_ACTIVE_BG = Color3.new(0.1, 0.1, 0.1)
local SLIDER_BACKGROUND_COLOR = Color3.fromRGB(70, 73, 83)

function TextureEditingUI.new(baseUI, manager, fabricTool, stickerTool, brushTool)
	local self = {}
	setmetatable(self, TextureEditingUI)

	self.baseUI = baseUI
	self.manager = manager

	self.fabricTool = fabricTool
	self.stickerTool = stickerTool
	self.brushTool = brushTool

	-- Hide the player list
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	-- Get height of the core UI top bar
	local guiInset: Vector2 = GuiService:GetGuiInset()

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "TextureEditingUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui

	local TitleText = Instance.new("TextLabel")
	TitleText.Name = "TitleText"
	TitleText.Text = "Body Part Painter"
	TitleText.AnchorPoint = Vector2.new(0.5, 0)
	TitleText.Position = UDim2.new(0.5, 0, 0, TOP_PADDING)
	TitleText.TextColor3 = Color3.new(1, 1, 1)
	TitleText.TextSize = 20
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

	self.regionSelection = RegionSelection.new(function(selectedRegion)
		self.fabricTool:SetSelectedRegion(selectedRegion)
		self.stickerTool:SetSelectedRegion(selectedRegion)
	end)

	self.LeftSideBar = UIUtils.CreateLeftSideBar()
	self.LeftSideBar.Parent = self.LeftBarsParent

	self.DecalCustomizationBar = self:CreateDecalCustomizationBar()
	self.DecalCustomizationBar.Parent = self.LeftBarsParent

	self.BrushToolBar = self:CreateBrushToolBar()
	self.BrushToolBar.Parent = self.LeftBarsParent

	self.BrushOptionsBar = self:CreateBrushOptionsBar()
	self.BrushOptionsBar.Parent = self.LeftBarsParent

	self.StickerPatternOptionsBar = self:CreateStickerPatternOptionsBar()
	self.StickerPatternOptionsBar.Parent = self.LeftBarsParent

	self.StickerPaddingSlider = self:CreateStickerPatternSlider()
	self.StickerPaddingSlider.Parent = self.LeftBarsParent

	self.StickerWarningTooltip = self:CreateTooManyStickersTooltip()
	self.StickerWarningTooltip.Parent = self.LeftBarsParent

	self.NewStickerPanel = self:CreateNewStickerPanel()
	self.NewStickerPanel.Parent = self.LeftBarsParent

	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.FillDirection = Enum.FillDirection.Vertical
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, UIConstants.LeftBarButtonPadding)
	ButtonLayout.Parent = self.LeftSideBar
	ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local BackButton = UIUtils.CreateBackButton()
	BackButton.Parent = self.LeftSideBar
	BackButton.LayoutOrder = 1
	BackButton.Activated:Connect(function()
		self:SetUIVisible(false)

		self.manager:ExitEditMode()

		-- Return to main UI
		self.baseUI:SetUIVisible(true)
	end)

	local FabricButton = UIUtils.CreateSideBarButton("Material", "rbxassetid://77437962300061")
	FabricButton.Parent = self.LeftSideBar
	FabricButton.LayoutOrder = 3
	FabricButton.Activated:Connect(function()
		-- Open the fabric+color selection panel
		self:HideSideBar()
		self.FabricListBar.Visible = true
		self.colorPicker:Open(function(color, isFinalInput)
			fabricTool:ApplyColor(color, isFinalInput)
		end)
		-- set all parts to be selected when closing the region selection
		self.regionSelection:Open()
	end)

	local PaintingButton = UIUtils.CreateSideBarButton("Painting", "rbxassetid://120516499663451")
	PaintingButton.Parent = self.LeftSideBar
	PaintingButton.LayoutOrder = 4
	PaintingButton.Activated:Connect(function()
		self:HideSideBar()
		self.BrushToolBar.Visible = true
		self.BrushOptionsBar.Visible = true
		self.manager:PanToRight()
		-- init with the color picker's color
		self.brushTool:OnColorChanged(self.colorPicker:GetColor())
		self.colorPicker:Open(function(color)
			self.brushTool:OnColorChanged(color)
		end)
		self.brushTool:Enable()
	end)

	local DecalsButton = UIUtils.CreateSideBarButton("Decals", "rbxassetid://97614725352180")
	DecalsButton.Parent = self.LeftSideBar
	DecalsButton.LayoutOrder = 5
	DecalsButton.Activated:Connect(function()
		if self:StickerLimitReached() then
			self:EnableTooManyStickersToolTip()
			return
		end
		self:HideSideBar()
		self.NewStickerPanel.Visible = true
		self:UpdateDecalButtonVisibility()
		self.DecalCustomizationBar.Visible = true
		self.stickerTool:Enable()
	end)

	self:CreateFabricSideBar()
	self:CreateRightSidePanel()

	self.regionSelection.Frame.Parent = self.LeftBarsParent
	self.regionSelection.Frame.Position = UDim2.fromOffset(FRAME_MARGIN + UIConstants.LeftBarButtonSize, 0)
	self.regionSelection.Frame.Visible = false

	local position = self.regionSelection.Frame.Position
	self.StickerPaddingSlider.Position = UDim2.fromOffset(
		position.X.Offset + self.regionSelection.Frame.AbsoluteSize.X + FRAME_MARGIN,
		position.Y.Offset
	)

	self.colorPicker = ColorPicker.new()
	self.colorPicker.Frame.Parent = self.LeftBarsParent
	self.colorPicker.Frame.Position = UDim2.fromOffset(
		FRAME_MARGIN + UIConstants.LeftBarButtonSize + UIConstants.LeftBarButtonSize + UIConstants.LeftBarButtonPadding,
		0
	)
	self.colorPicker.Frame.Visible = false

	local UserInputService = game:GetService("UserInputService")
	UserInputService.ModalEnabled = not UserInputService.ModalEnabled

	self.currentStickerPreview = ""

	self:SetUIVisible(false)

	-- "Buy" button. For when the user is finished editing their asset and wants to upload it.
	local onClickBuyButton = function()
		self:OnClickedBuyButton()
	end

	UIUtils.CreateBuyButton(onClickBuyButton, self.screenGui)

	return self
end

function TextureEditingUI:CreateTooManyStickersTooltip()
	local tooManyStickersFrame = Instance.new("Frame")
	tooManyStickersFrame.Name = "TooManyStickersToolTipFrame"
	tooManyStickersFrame.Visible = false
	tooManyStickersFrame.AutomaticSize = Enum.AutomaticSize.XY
	tooManyStickersFrame.Position = UDim2.fromOffset(UIConstants.LeftBarButtonSize + FRAME_MARGIN, 0)
	tooManyStickersFrame.BackgroundColor3 = Color3.new(0, 0, 0)

	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = tooManyStickersFrame

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, TOOLTIP_VERTICAL_PADDING)
	uiPadding.PaddingBottom = UDim.new(0, TOOLTIP_VERTICAL_PADDING)
	uiPadding.PaddingLeft = UDim.new(0, TOOLTIP_HORIZONTAL_PADDING)
	uiPadding.PaddingRight = UDim.new(0, TOOLTIP_HORIZONTAL_PADDING)

	uiPadding.Parent = tooManyStickersFrame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, TOOLTIP_INTERNAL_PADDING)
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = tooManyStickersFrame

	local closeImageButton = Instance.new("ImageButton")
	closeImageButton.LayoutOrder = 1
	closeImageButton.Image = "rbxassetid://72013784847925"
	closeImageButton.BackgroundTransparency = 1
	closeImageButton.Size = UDim2.new(0, TOOLTIP_CLOSE_BUTTON_HEIGHT, 0, TOOLTIP_CLOSE_BUTTON_HEIGHT)
	closeImageButton.Parent = tooManyStickersFrame
	closeImageButton.Activated:Connect(function()
		self:DisableTooManyStickersToolTip()
	end)

	local textLabel = Instance.new("TextLabel")
	textLabel.LayoutOrder = 2
	textLabel.Name = "TooManyStickersToolTipTextLabel"
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "Too many stickers. Please remove a sticker before adding one."
	textLabel.TextSize = TOOLTIP_FONT_SIZE
	textLabel.Font = Enum.Font.ArialBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Parent = tooManyStickersFrame

	return tooManyStickersFrame
end

function TextureEditingUI:EnableTooManyStickersToolTip()
	self.StickerWarningTooltip.Visible = true
end

function TextureEditingUI:DisableTooManyStickersToolTip()
	self.StickerWarningTooltip.Visible = false
end

function TextureEditingUI:StickerLimitReached()
	return self.stickerTool.stickerCounter > Constants.MAX_STICKER_LAYERS
end

function TextureEditingUI:CreateBrushToolBar()
	local BrushToolBar = UIUtils.CreateLeftSideBar()
	BrushToolBar.Name = "BrushToolBar"
	BrushToolBar.Visible = false

	local backButton = UIUtils.CreateBackButton()
	backButton.Parent = BrushToolBar
	backButton.Activated:Connect(function()
		self.BrushToolBar.Visible = false
		self.BrushOptionsBar.Visible = false
		self.LeftSideBar.Visible = true
		self.colorPicker:Close()
		self.manager:ResetCamera()
		-- Disable the brush tool
		self.brushTool:Disable()
	end)

	local brushButton =
		UIUtils.CreateSideBarButton("Brush", "rbxassetid://120516499663451", "rbxassetid://97768519026130")
	brushButton.Parent = BrushToolBar
	brushButton.BackgroundColor3 = BUTTON_ACTIVE_BG
	brushButton.LayoutOrder = 3
	UIUtils.AddButtonBackground(brushButton, nil, nil, true)
	UIUtils.SetButtonState(brushButton, true)
	brushButton.Activated:Connect(function()
		-- Show brush customization bar
		self.brushTool:SetStatePainting()
		self.BrushOptionsBar.Visible = true
		self.setBrushSliderValue(self.brushTool:GetBrushSize())
		self:OnBrushSizeChanged(self.brushTool:GetBrushSize(), true)
		UIUtils.SetButtonState(self.BrushButton, true)
		UIUtils.SetButtonState(self.EraserButton, false)
	end)
	self.BrushButton = brushButton

	local eraserButton =
		UIUtils.CreateSideBarButton("Eraser", "rbxassetid://100477136990217", "rbxassetid://83966601462758")
	eraserButton.Parent = BrushToolBar
	eraserButton.BackgroundColor3 = BUTTON_ACTIVE_BG
	eraserButton.LayoutOrder = 4
	UIUtils.AddButtonBackground(eraserButton, nil, nil, false)
	eraserButton.Activated:Connect(function()
		-- Set state to erasing
		self.brushTool:SetStateErasing()
		self.BrushOptionsBar.Visible = true
		self.setBrushSliderValue(self.brushTool:GetEraserSize())
		self:OnBrushSizeChanged(self.brushTool:GetEraserSize(), true)
		UIUtils.SetButtonState(self.BrushButton, false)
		UIUtils.SetButtonState(self.EraserButton, true)
	end)
	self.EraserButton = eraserButton

	local clearButton = UIUtils.CreateSideBarButton("Clear", "rbxassetid://127065728325868")
	clearButton.Parent = BrushToolBar
	clearButton.LayoutOrder = 5
	clearButton.Activated:Connect(function()
		self.brushTool:ClearAll()
	end)

	self.brushTool.UseProjectionBrush = Utils.GetIsProjectionActivated()
	if self.brushTool.UseProjectionBrush == true then
		local BrushToggleButton = Instance.new("ImageButton")
		self.BrushToggleButton = BrushToggleButton
		BrushToggleButton.Size =
			UDim2.new(0, UIConstants.LeftBarButtonSize - UIConstants.LeftBarButtonPadding * 2, 0, BUTTON_HEIGHT)
		BrushToggleButton.Image = "rbxassetid://15610976092" -- Disabled by default
		BrushToggleButton.Parent = BrushToolBar
		BrushToggleButton.BackgroundTransparency = 1
		BrushToggleButton.LayoutOrder = 5
		BrushToggleButton.Activated:Connect(function()
			self.brushTool.UseProjectionBrush = not self.brushTool.UseProjectionBrush
			if self.brushTool.UseProjectionBrush then
				BrushToggleButton.Image = "rbxassetid://15610976092"
			else
				BrushToggleButton.Image = "rbxassetid://15610974290"
			end
		end)
	end

	return BrushToolBar
end

function TextureEditingUI:CreateBrushOptionsBar()
	local BrushOptionsBar = SidePanelUI.CreateSidePanel()
	BrushOptionsBar.Name = "BrushOptionsBar"
	BrushOptionsBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	BrushOptionsBar.Position = UDim2.fromOffset(UIConstants.LeftBarButtonSize + FRAME_MARGIN, 0)
	BrushOptionsBar.Visible = false
	BrushOptionsBar.ZIndex = 3

	local BrushSizeTooltip = Instance.new("Frame")

	-- Slider for adjusting brush size
	local BrushSizeSliderPair = self:CreateVerticalSlider(
		Constants.MIN_BRUSH_SIZE,
		Constants.MAX_BRUSH_SIZE,
		10,
		function(newValue, bIsFinalInput)
			-- When slider value changes, we want to change the brush size.
			self:OnBrushSizeChanged(newValue, bIsFinalInput)
		end,
		BrushSizeTooltip
	)
	local BrushSizeSlider = BrushSizeSliderPair[1]
	self.setBrushSliderValue = BrushSizeSliderPair[2] -- We need this function to manually set the slider value when switching between brush/eraser.
	BrushSizeSlider.LayoutOrder = 3
	BrushSizeSlider.Parent = BrushOptionsBar
	local optionsPosition = BrushOptionsBar.AbsolutePosition
	BrushSizeSlider.Position =
		UDim2.fromOffset(optionsPosition.X + BrushOptionsBar.AbsoluteSize.X + 10, optionsPosition.Y)

	-- Tooltip UI for displaying brush size to the side of the slider while user is sliding up and down
	BrushSizeTooltip.Size = UDim2.fromOffset(BRUSH_TOOLTIP_SIZE, BRUSH_TOOLTIP_SIZE)
	BrushSizeTooltip.AnchorPoint = Vector2.new(0, 0.5)
	BrushSizeTooltip.Position = UDim2.fromOffset(60, 30)
	BrushSizeTooltip.Parent = BrushSizeSlider:FindFirstChild("Pointer", true)
	BrushSizeTooltip.BackgroundColor3 = UIConstants.BGColor
	BrushSizeTooltip.BackgroundTransparency = 0
	BrushSizeTooltip.ZIndex = 2
	BrushSizeTooltip.Visible = false

	UIUtils.AddUICorner(BrushSizeTooltip, UIConstants.PanelCornerRadius)

	local BrushSizeIcon = Instance.new("Frame")
	BrushSizeIcon.BackgroundColor3 = Color3.new(1, 1, 1)
	BrushSizeIcon.BackgroundTransparency = 0
	BrushSizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	BrushSizeIcon.Position = UDim2.fromScale(0.5, 0.5)
	BrushSizeIcon.Size = UDim2.fromOffset(20, 20)
	BrushSizeIcon.Parent = BrushSizeTooltip
	self.BrushSizeIcon = BrushSizeIcon -- We need to modify the size of this later on when brush size changes.

	UIUtils.AddUICorner(BrushSizeIcon, 0, 0.5)

	return BrushOptionsBar
end

function TextureEditingUI:RefreshBrushSizeIndicator(brushSizeValue)
	if self.BrushSizeIcon ~= nil then
		-- Scale the brush size indicator, but make sure to keep it in the bounds of the indicator frame.
		local minIndicatorSize = 2
		local maxIndicatorSize = BRUSH_TOOLTIP_SIZE - 10
		local t = (brushSizeValue - Constants.MIN_BRUSH_SIZE) / (Constants.MAX_BRUSH_SIZE - Constants.MIN_BRUSH_SIZE)
		local tooltipIndicatorSize = t * (maxIndicatorSize - minIndicatorSize) + minIndicatorSize
		self.BrushSizeIcon.Size = UDim2.fromOffset(tooltipIndicatorSize, tooltipIndicatorSize)
	end
end

function TextureEditingUI:OnBrushSizeChanged(newValue, bIsFinalInput)
	self.brushTool:OnBrushSizeChanged(newValue, bIsFinalInput)
	self:RefreshBrushSizeIndicator(newValue)
end

function TextureEditingUI:CreateNewStickerPanel()
	local NewStickerPanel = Instance.new("Frame")
	NewStickerPanel.Name = "NewStickerPanel"
	NewStickerPanel.Size = UDim2.new(0, STICKER_ICON_SIZE * STICKERS_PER_ROW + 10 + 2 * FRAME_MARGIN, 1, 0)
	NewStickerPanel.BackgroundTransparency = 0
	NewStickerPanel.BackgroundColor3 = UIConstants.BGColor
	NewStickerPanel.Position = UDim2.new(0, UIConstants.LeftBarButtonSize + FRAME_MARGIN, 0, 0)
	NewStickerPanel.Visible = false
	UIUtils.AddUICorner(NewStickerPanel, UIConstants.PanelCornerRadius)

	local ScrollingGridFrame = Instance.new("ScrollingFrame")
	ScrollingGridFrame.Size =
		UDim2.new(0, STICKER_ICON_SIZE * STICKERS_PER_ROW + 10, 1, -STICKER_PANEL_HEADER_HEIGHT - 70)
	ScrollingGridFrame.Position = UDim2.new(0, FRAME_MARGIN, 0, STICKER_PANEL_HEADER_HEIGHT)
	ScrollingGridFrame.BackgroundTransparency = 1
	local numStickerRows = math.ceil(#StickerData / STICKERS_PER_ROW)
	ScrollingGridFrame.CanvasSize = UDim2.new(1, 0, 0, (STICKER_ICON_SIZE + 5) * numStickerRows)
	ScrollingGridFrame.ScrollBarImageTransparency = 1
	ScrollingGridFrame.ScrollBarThickness = 0
	ScrollingGridFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	ScrollingGridFrame.Parent = NewStickerPanel

	local GridViewFrame = Instance.new("Frame")
	GridViewFrame.Name = "GridViewFrame"
	GridViewFrame.Size = UDim2.new(0, STICKER_ICON_SIZE * STICKERS_PER_ROW + 10, 1, -STICKER_PANEL_HEADER_HEIGHT)
	GridViewFrame.BackgroundTransparency = 1
	GridViewFrame.Parent = ScrollingGridFrame
	self.StickerGrid = GridViewFrame

	local StickerGridLayout = Instance.new("UIGridLayout")
	StickerGridLayout.Parent = GridViewFrame
	StickerGridLayout.FillDirection = Enum.FillDirection.Horizontal
	StickerGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	StickerGridLayout.FillDirectionMaxCells = STICKERS_PER_ROW
	StickerGridLayout.CellSize = UDim2.fromOffset(STICKER_ICON_SIZE, STICKER_ICON_SIZE)
	StickerGridLayout.CellPadding = UDim2.fromOffset(5, 5)

	self:RefreshStickerGrid(StickerData)

	-- Bottom bar
	local BottomBarFrame = Instance.new("Frame")
	BottomBarFrame.Name = "BottomBarFrame"
	BottomBarFrame.Size = UDim2.new(1, 0, 0, 64)
	BottomBarFrame.AnchorPoint = Vector2.new(0, 1)
	BottomBarFrame.Position = UDim2.new(0, 0, 1, 0)
	BottomBarFrame.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
	BottomBarFrame.BackgroundTransparency = 0
	BottomBarFrame.BorderSizePixel = 0
	BottomBarFrame.Parent = NewStickerPanel
	UIUtils.AddUICorner(BottomBarFrame, UIConstants.PanelCornerRadius)

	local BottomBarPadding = Instance.new("UIPadding")
	BottomBarPadding.PaddingTop = UDim.new(0, FRAME_MARGIN)
	BottomBarPadding.PaddingRight = UDim.new(0, FRAME_MARGIN)
	BottomBarPadding.PaddingBottom = UDim.new(0, FRAME_MARGIN)
	BottomBarPadding.PaddingLeft = UDim.new(0, FRAME_MARGIN)
	BottomBarPadding.Parent = BottomBarFrame

	-- HACK: Hides the top left & right corner radius of the bottom bar
	-- Would better be handled by a 9-slice image
	local BottomBarCornerFix = Instance.new("Frame")
	BottomBarCornerFix.Size = UDim2.new(1, FRAME_MARGIN * 2, 0.5, FRAME_MARGIN)
	BottomBarCornerFix.AnchorPoint = Vector2.new(0.5, 0)
	BottomBarCornerFix.Position = UDim2.new(0.5, 0, 0, 0 - FRAME_MARGIN)
	BottomBarCornerFix.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
	BottomBarCornerFix.BackgroundTransparency = 0
	BottomBarCornerFix.BorderSizePixel = 0
	BottomBarCornerFix.ZIndex = -1
	BottomBarCornerFix.Parent = BottomBarFrame

	return NewStickerPanel
end

function TextureEditingUI:RefreshStickerGrid(stickerList)
	-- Remove all children from the grid
	for _, child in pairs(self.StickerGrid:GetChildren()) do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end

	for _, sticker: StickerData.StickerData in pairs(stickerList) do
		local gridButton = Instance.new("ImageButton")
		gridButton.Name = `Sticker-{sticker.name}`
		gridButton.BackgroundColor3 = UIConstants.BGColor
		UIUtils.AddUICorner(gridButton, 4)

		-- Use an intermediary frame to prevent grid sizing from having to account for the stroke size
		local gridButtonStrokeFrame = Instance.new("Frame")
		gridButtonStrokeFrame.Size = UDim2.new(1, -5, 1, -5)
		gridButtonStrokeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		gridButtonStrokeFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		gridButtonStrokeFrame.BackgroundTransparency = 1
		gridButtonStrokeFrame.Parent = gridButton
		UIUtils.AddUICorner(gridButtonStrokeFrame, 4)

		-- Apply a UIStroke border, enable when the sticker is selected
		local gridButtonStroke = Instance.new("UIStroke")
		gridButtonStroke.Thickness = STICKER_BUTTON_STROKE_SIZE
		gridButtonStroke.Color = Color3.fromRGB(255, 255, 255)
		gridButtonStroke.Enabled = sticker.textureId == self.currentStickerPreview
		gridButtonStroke.Parent = gridButtonStrokeFrame

		gridButton.Parent = self.StickerGrid
		gridButton.Activated:Connect(function()
			self.currentStickerPreview = sticker.textureId

			self:RefreshStickerGrid(stickerList)

			self.DecalCustomizationBar.Visible = true
			self:HideNewStickerPanel()
			self.LeftSideBar.Visible = false

			self.stickerTool:ApplySticker(self.currentStickerPreview)

			self.StickerPatternButton.Visible = true
			self.StickerDeleteButton.Visible = true
		end)

		local buttonImage = Instance.new("ImageLabel")
		buttonImage.Size = UDim2.new(1, -20, 1, -20)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		buttonImage.Image = sticker.textureId
		buttonImage.BackgroundTransparency = 1
		buttonImage.Parent = gridButton
	end
end

function TextureEditingUI:CreateStickerPatternOptionsBar()
	local PatternOptionsBar = SidePanelUI.CreateSidePanel()
	PatternOptionsBar.Name = "PatternOptionsBar"
	PatternOptionsBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	PatternOptionsBar.Visible = false

	local BackButton = UIUtils.CreateBackButton()
	BackButton.Parent = PatternOptionsBar
	BackButton.Activated:Connect(function()
		self.StickerPatternOptionsBar.Visible = false
		self.regionSelection:Close()
		self.StickerPaddingSlider.Visible = false
		self.DecalCustomizationBar.Visible = true
		self.colorPicker:Close()

		self.DecalCustomizationBar.Visible = true
		self.regionSelection:Close()
	end)

	-- Toggle for making sticker a repeated pattern
	local PatternToggleButton = Instance.new("ImageButton")
	self.PatternToggleButton = PatternToggleButton
	PatternToggleButton.Name = "PatternToggleButton"
	PatternToggleButton.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.LeftBarButtonSize)
	PatternToggleButton.BackgroundTransparency = 1
	PatternToggleButton.LayoutOrder = 5
	PatternToggleButton.Parent = PatternOptionsBar

	local PatternToggleImage = Instance.new("ImageLabel")
	PatternToggleImage.Size = UDim2.new(
		0,
		UIConstants.LeftBarButtonSize - UIConstants.LeftBarButtonPadding * 2,
		0,
		UIConstants.ToggleButtonHeight
	)
	PatternToggleImage.Image = "rbxassetid://111003482690827" -- Enable by default
	PatternToggleImage.Parent = PatternToggleButton
	PatternToggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
	PatternToggleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	PatternToggleImage.BackgroundTransparency = 1

	PatternToggleButton.Activated:Connect(function()
		self.stickerTool:SetPatterned(not self.stickerTool:IsPatterned())
		local isPatterned = self.stickerTool:IsPatterned()
		if isPatterned then
			PatternToggleImage.Image = "rbxassetid://111003482690827"
		else
			PatternToggleImage.Image = "rbxassetid://109637331807480"
		end
	end)

	return PatternOptionsBar
end

function TextureEditingUI:CreateStickerPatternSlider()
	local SliderBar = SidePanelUI.CreateSidePanel()
	SliderBar.Name = "PatternSliderBar"
	SliderBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	SliderBar.Visible = false
	SliderBar.ZIndex = 3

	local SliderPair = self:CreateVerticalSlider(0, 100, 0, function(newValue, bIsFinalInput)
		self.stickerTool:OnPatternPaddingChanged(newValue, bIsFinalInput)
	end)
	local Slider = SliderPair[1]
	Slider.Name = "PaddingSliderBar"
	Slider.AnchorPoint = Vector2.new(0.5, 0.5)
	Slider.Position = UDim2.fromScale(0.5, 0.5)
	Slider.Parent = SliderBar
	return SliderBar
end

function TextureEditingUI:CreateDecalCustomizationBar()
	local DecalCustomizationBar = SidePanelUI.CreateSidePanel()
	DecalCustomizationBar.Size = UDim2.fromOffset(UIConstants.LeftBarButtonSize, 0)
	DecalCustomizationBar.AutomaticSize = Enum.AutomaticSize.Y
	DecalCustomizationBar.Name = "DecalCustomizationBar"
	DecalCustomizationBar.Visible = false
	DecalCustomizationBar.Parent = self.screenGui

	local backButton = UIUtils.CreateBackButton()
	backButton.Parent = DecalCustomizationBar
	backButton.Activated:Connect(function()
		self.DecalCustomizationBar.Visible = false
		self.StickerPatternOptionsBar.Visible = false
		self.regionSelection:Close()
		self.StickerPaddingSlider.Visible = false
		self:HideNewStickerPanel()
		self.LeftSideBar.Visible = true
		self.colorPicker:Close()

		self.stickerTool:Disable()
	end)

	self.DecalsButton =
		UIUtils.CreateSideBarButton("Decals", "rbxassetid://97614725352180", "rbxassetid://80847637983108")
	UIUtils.AddButtonBackground(self.DecalsButton, UDim.new(0, UIConstants.BarCornerRadius), true, true)
	UIUtils.SetButtonState(self.DecalsButton, true)
	self.DecalsButton.Parent = DecalCustomizationBar
	self.DecalsButton.LayoutOrder = 3
	self.DecalsButton.Activated:Connect(function()
		if self:StickerLimitReached() then
			self:EnableTooManyStickersToolTip()
			return
		end
		self.LeftSideBar.Visible = false
		self.NewStickerPanel.Visible = true
		self:UpdateDecalButtonVisibility()
	end)

	self.StickerPatternButton = UIUtils.CreateSideBarButton("Pattern", "rbxassetid://74206426520414")
	self.StickerPatternButton.Parent = DecalCustomizationBar
	self.StickerPatternButton.LayoutOrder = 4
	self.StickerPatternButton.Visible = false -- show after selecting decal
	self.StickerPatternButton.Activated:Connect(function()
		self.LeftSideBar.Visible = false
		self:HideNewStickerPanel()
		self.regionSelection:Open()
		self.StickerPaddingSlider.Visible = true
		-- Show the pattern options bar
		self.StickerPatternOptionsBar.Visible = true
		self.regionSelection:Open()

		-- Hide the decal customization bar
		self.DecalCustomizationBar.Visible = false

		-- enable patterning
		self.stickerTool:SetPatterned(true)
	end)

	self.StickerDeleteButton = UIUtils.CreateSideBarButton("Delete", "rbxassetid://127065728325868")
	self.StickerDeleteButton.Parent = DecalCustomizationBar
	self.StickerDeleteButton.LayoutOrder = 5
	self.StickerDeleteButton.Visible = false
	self.StickerDeleteButton.Activated:Connect(function()
		-- Delete the current sticker
		self.stickerTool:DeleteCurrentSticker()
		self.StickerPatternOptionsBar.Visible = false
		self.regionSelection:Close()
		self.StickerPaddingSlider.Visible = false

		-- If there are no other stickers, exit the sticker UI
		if not self.stickerTool:HasAppliedStickers() then
			self.DecalCustomizationBar.Visible = false
			self.LeftSideBar.Visible = true
		end

		self:UpdateDecalButtonVisibility()
	end)

	self.stickerTool.UseProjectionSticker = Utils.GetIsProjectionActivated()
	if self.stickerTool.UseProjectionSticker == true then
		local StickerToggleButton = Instance.new("ImageButton")
		self.StickerToggleButton = StickerToggleButton
		StickerToggleButton.Name = "StickerToggleButton"
		StickerToggleButton.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.LeftBarButtonSize)
		StickerToggleButton.BackgroundTransparency = 1
		StickerToggleButton.LayoutOrder = 5
		StickerToggleButton.Parent = DecalCustomizationBar

		local StickerToggleImage = Instance.new("ImageLabel")
		StickerToggleImage.Size = UDim2.new(
			0,
			UIConstants.LeftBarButtonSize - UIConstants.LeftBarButtonPadding * 2,
			0,
			UIConstants.ToggleButtonHeight
		)
		StickerToggleImage.Image = "rbxassetid://rbxassetid://109637331807480" -- Disabled by default
		StickerToggleImage.Parent = StickerToggleButton
		StickerToggleImage.BackgroundTransparency = 1

		StickerToggleButton.Activated:Connect(function()
			self.stickerTool.UseProjectionSticker = not self.stickerTool.UseProjectionSticker
			if self.stickerTool.UseProjectionSticker then
				StickerToggleImage.Image = "rbxassetid://109637331807480"
			else
				StickerToggleImage.Image = "rbxassetid://111003482690827"
			end
			self.stickerTool:SafelyRedrawSticker()
		end)
	end

	return DecalCustomizationBar
end

function TextureEditingUI:HideNewStickerPanel()
	if self.NewStickerPanel.Visible == false then
		return
	end

	self.NewStickerPanel.Visible = false
	if self.currentStickerPreview ~= "" then
		self.StickerPatternButton.Visible = true
		self.StickerDeleteButton.Visible = true
		UIUtils.ChangeButtonBackgroundCorner(self.DecalsButton, UDim.new(0, 0))
	end
end

function TextureEditingUI:UpdateDecalButtonVisibility()
	if self.stickerTool:HasAppliedStickers() then
		self.StickerPatternButton.Visible = true
		self.StickerDeleteButton.Visible = true
		UIUtils.ChangeButtonBackgroundCorner(self.DecalsButton, UDim.new(0, 0), true --[[hideTopCornersVisible]])
	else
		self.StickerPatternButton.Visible = false
		self.StickerDeleteButton.Visible = false
		UIUtils.ChangeButtonBackgroundCorner(
			self.DecalsButton,
			UDim.new(0, UIConstants.BarCornerRadius),
			true --[[hideTopCornersVisible]]
		)
	end
end

function TextureEditingUI:CreateRightSidePanel()
	local RightSidePanel = Instance.new("Frame")
	RightSidePanel.Name = "RightSidePanel"
	RightSidePanel.Size = UDim2.new(0, RIGHT_BAR_WIDTH, 1, 0 - (FRAME_MARGIN * 2))
	RightSidePanel.AnchorPoint = Vector2.new(1, 0)
	RightSidePanel.Position = UDim2.new(1, -FRAME_MARGIN, 0, FRAME_MARGIN)
	RightSidePanel.BackgroundTransparency = 1
	RightSidePanel.Parent = self.screenGui

	local ActionButtons = Instance.new("Frame")
	ActionButtons.BackgroundTransparency = 1
	ActionButtons.Size = UDim2.new(0, ACTION_BUTTON_SIZE, 0, ACTION_BUTTON_SIZE * 4 + 10 * 3)
	ActionButtons.AnchorPoint = Vector2.new(1, 0.5)
	ActionButtons.Position = UDim2.new(1, 0, 0.5, 0)
	ActionButtons.Parent = RightSidePanel

	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ButtonLayout.FillDirection = Enum.FillDirection.Vertical
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ButtonLayout.Padding = UDim.new(0, 10)
	ButtonLayout.Parent = ActionButtons

	local BrushToolBar = Instance.new("ScrollingFrame")
	BrushToolBar.Name = "BrushToolBar"
	BrushToolBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 1, -36)
	BrushToolBar.CanvasSize = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.LeftBarButtonSize * 7)
	BrushToolBar.ScrollBarImageTransparency = 1
	BrushToolBar.ScrollBarThickness = 0
	BrushToolBar.ScrollingDirection = Enum.ScrollingDirection.Y
	BrushToolBar.Position = UDim2.fromOffset(10, 0)
	BrushToolBar.BackgroundTransparency = 1
	BrushToolBar.BackgroundColor3 = UIConstants.BGColor
	BrushToolBar.Visible = false

	-- We add an internal normal frame because ScrollingFrame doesn't support UICorner
	local InternalFrame = Instance.new("Frame")
	InternalFrame.BackgroundTransparency = 0
	InternalFrame.BackgroundColor3 = UIConstants.BGColor
	InternalFrame.Size = UDim2.fromScale(1, 1)
	InternalFrame.Parent = BrushToolBar
end

function TextureEditingUI:CreateFabricSideBar()
	local ScrollingSideBar = Instance.new("ScrollingFrame")
	ScrollingSideBar.Name = "ScrollingFabricList"
	ScrollingSideBar.AutomaticSize = Enum.AutomaticSize.Y
	ScrollingSideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingSideBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	ScrollingSideBar.CanvasSize = UDim2.new(0, UIConstants.LeftBarButtonSize, 0)
	ScrollingSideBar.ScrollBarImageTransparency = 1
	ScrollingSideBar.ScrollBarThickness = 0
	ScrollingSideBar.ScrollingDirection = Enum.ScrollingDirection.Y
	ScrollingSideBar.Position = UDim2.fromOffset(0, 0)
	ScrollingSideBar.BackgroundTransparency = 1
	ScrollingSideBar.BackgroundColor3 = UIConstants.BGColor
	ScrollingSideBar.Parent = self.LeftBarsParent
	ScrollingSideBar.Visible = false
	self.FabricListBar = ScrollingSideBar

	-- Bar of the side buttons when using the fabric tool
	local FabricList = SidePanelUI.CreateSidePanel()
	FabricList.Position = UDim2.fromOffset(0, 0)
	FabricList.Name = "FabricListBar"
	FabricList.Parent = ScrollingSideBar

	local FabricListPadding = Instance.new("UIPadding")
	FabricListPadding.PaddingBottom = UDim.new(0, UIConstants.LeftBarButtonPadding)
	FabricListPadding.Parent = FabricList

	local backButton = UIUtils.CreateBackButton()
	backButton.Parent = FabricList
	backButton.Activated:Connect(function()
		self.FabricListBar.Visible = false
		self.colorPicker:Close()
		self.regionSelection:Close()
		self.LeftSideBar.Visible = true
		self.manager:ResetCamera()
	end)

	-- Add "clear" button to remove base color
	local clearButton = UIUtils.CreateSideBarButton("Clear", "rbxassetid://127065728325868")
	clearButton.Parent = FabricList
	clearButton.LayoutOrder = 3
	clearButton.Activated:Connect(function()
		self.fabricTool:ClearAll()
	end)
end

function TextureEditingUI:HideSideBar()
	self.LeftSideBar.Active = false
	self.LeftSideBar.Visible = false
end

function TextureEditingUI:CreateVerticalSlider(
	minValue,
	maxValue,
	defaultValue,
	onValueChangedCallback,
	showElementOnDrag
)
	local Frame = Instance.new("Frame")
	Frame.Name = "Slider"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.SliderLength)

	UIUtils.AddUICorner(Frame, UIConstants.BarCornerRadius)

	local Selector = Instance.new("Frame")
	Selector.Name = "Selector"
	Selector.BackgroundTransparency = 1
	Selector.Size = UDim2.new(0, UIConstants.SliderSelectorWidth, 0, UIConstants.SliderSelectorLength)
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
	BottomFillFrame.BackgroundColor3 = SLIDER_BACKGROUND_COLOR
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
	Selector.InputBegan:Connect(function(input, gameProcessed)
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
	Selector.InputChanged:Connect(function(input, gameProcessed)
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

function TextureEditingUI:SetUIVisible(visible)
	self.screenGui.Enabled = visible
end

function TextureEditingUI:OnClickedBuyButton()
	BuyRemoteEvent:FireServer()
	self.manager:Quit(true)
end

function TextureEditingUI:Destroy()
	self.screenGui:Destroy()
end

return TextureEditingUI
