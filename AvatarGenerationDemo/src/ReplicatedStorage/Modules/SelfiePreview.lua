-- The UI for this demo place should consist of:
--  - A scrolling grid of photos that the user can click on
--  - An editable text field that gets auto-populated with the photo's prompt when the user clicks on a photo
--  - A button that the user can click to generate a 2d image from the photo and prompt
--  - A frame to display the generated image
--  - A button that the user can click to generate a 3d model from the 2d image and prompt

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local guiInset = GuiService:GetGuiInset().Y + 10

local Modules = ReplicatedStorage:WaitForChild("Modules")
local UIUtils = require(Modules:WaitForChild("UIUtils"))
local ProgressUI = require(Modules:WaitForChild("ProgressUI"))
local EndSessionReason = require(Modules:WaitForChild("EndSessionReason"))

local Events = ReplicatedStorage:WaitForChild("Events")
local EquipModelEvent = Events:WaitForChild("EquipModelEvent")
local ImageFailedEvent = Events:WaitForChild("ImageFailedEvent")

local BUTTON_GREEN_COLOR = Color3.fromRGB(0, 180, 109)
local COLOR_ACTION = Color3.fromHex("#335FFF")
local COLOR_DIALOG_BG = Color3.fromRGB(57, 59, 61)
local COLOR_DIALOG_DIVIDER = Color3.fromRGB(101, 102, 104)
local COLOR_DIALOG_TEXT = Color3.fromRGB(189, 190, 190)
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local DARK_COLOR_1 = Color3.fromRGB(18, 18, 21)
local DARK_COLOR_2 = Color3.fromRGB(25, 26, 31)
local ERROR_COLOR = Color3.fromRGB(200, 0, 0)
local ERROR_TEXT = "Image generation failed. Please try again."
local HINT_COLOR = Color3.fromRGB(140, 140, 140)
local HINT_TEXT = "Click a photo and enter a prompt to generate a 2D face!"
local NUM_COLUMNS = 5
local PROMPT_TEXTBOX_HEIGHT = 80
local TEXT_FONT = Enum.Font.GothamSemibold
local TOP_BOTTOM_MARGIN = 50

local SelfiePreview = {}
SelfiePreview.__index = SelfiePreview

function SelfiePreview.new(creationManager)
	local self = {}
	setmetatable(self, SelfiePreview)

	self.CreationManager = creationManager

	-- Force the PlayerGui into landscape mode. TODO: support portrait?
	self.prevScreenOrientation = PlayerGui.ScreenOrientation
	PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

	-- Hide the player list and jump button
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	if Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TouchGui") then
		Players.LocalPlayer:WaitForChild("PlayerGui").TouchGui.TouchControlFrame.JumpButton:Destroy()
	end

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "SelfiePreview"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.Parent = PlayerGui

	self.selectedPhotoData = {}

	self.genEndTime = tick() + 300
	self.totalNumGenerations = 0

	self:SetupUI()

	-- Disable buttons
	self:DisableGenerate3DButton()

	self:Setup3dTimeExpiredAlert()

	self:SetupEventListeners()

	RunService.RenderStepped:Connect(function(step)
		-- If the window size changes, update the layout of the UI
		if self.gridLayout ~= nil then
			if self.screenGui.AbsoluteSize ~= self.prevScreenSize then
				self.prevScreenSize = self.screenGui.AbsoluteSize

				local tileWidthPixels = (self.photoGrid.AbsoluteSize.X - 10) / NUM_COLUMNS - 5
				self.gridLayout.CellSize = UDim2.new(0, tileWidthPixels, 0, tileWidthPixels)
			end
		end
	end)

	return self
end

function SelfiePreview:IsMobile()
	return UserInputService:GetLastInputType() == Enum.UserInputType.Touch
end

function SelfiePreview:ReopenUI()
	-- Reset timers and counters
	self.genEndTime = tick() + 300
	self.genTimeTextBgHighlighted = false
	self.genTimeTextBgRed = false
	self.gen2dTimeExpired = false
	self.gen3dTimeExpired = false

	self.genRemainingText.Visible = false

	self:HideGeneratedImage()

	-- Remove all generated images
	for _, child in pairs(self.generatedImagesListFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	self:CenterGeneratedImageParent()

	self.promptField.Text = ""

	self.generate3DButton.Visible = false
	-- reset 2d button to primary button
	self.generate2DButton.Text = "Take a Selfie"
	self.generate2DButton.BackgroundColor3 = COLOR_ACTION
	self.generate2DButton.BackgroundTransparency = 0
	self.generate2DButton.TextColor3 = COLOR_WHITE

	-- Reset the layout orders of the buttons
	self.generate2DButton.LayoutOrder = 2
	self.generate3DButton.LayoutOrder = 3

	self.genHelpText.Visible = true
	self.genHelpText.Text = HINT_TEXT
	self.genHelpText.TextColor3 = HINT_COLOR
	self.blockerPanel.Visible = false
	self.gen3DAlertScreenGui.Enabled = false
	self.promptField.Text = ""
	self.screenGui.Enabled = true

	-- Reset timer background color
	self.genTimeTextBg.BackgroundColor3 = DARK_COLOR_1

	self:DisableGenerate3DButton()

	self:EnableGenerate2DButton()
	self:Enable2DInput()
end

-- Center the generated image frame initially on mobile
function SelfiePreview:CenterGeneratedImageParent()
	-- generatedImageParent exists only on mobile
	if self.generatedImageParent then
		self.generatedImageParent.Position = UDim2.new(0, 40, 0, 0)
	end
end

-- Push the generated image frame to the right on mobile once
-- we have a list of generated images to show on the left
function SelfiePreview:RightAlignGeneratedImageParent()
	-- generatedImageParent exists only on mobile
	if self.generatedImageParent then
		self.generatedImageParent.Position = UDim2.new(0, 80, 0, 0)
	end
end

function SelfiePreview:SetupUI()
	-- Semi-transparent background frame
	-- NOTE: Using TextButton to sink input and prevent zooming in and out on scroll
	self.backgroundFrame = Instance.new("TextButton")
	self.backgroundFrame.Name = "BackgroundFrame"
	self.backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	self.backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
	self.backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.backgroundFrame.BackgroundTransparency = 0.5
	self.backgroundFrame.BorderSizePixel = 0
	self.backgroundFrame.Text = ""
	self.backgroundFrame.AutoButtonColor = false
	self.backgroundFrame.Parent = self.screenGui

	self.insetFrame = Instance.new("Frame")
	self.insetFrame.Name = "InsetFrame"
	self.insetFrame.Active = true
	self.insetFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.insetFrame.Size = UDim2.new(0.85, 0, 0.85, 0)
	self.insetFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.insetFrame.BackgroundColor3 = DARK_COLOR_1
	self.insetFrame.BackgroundTransparency = 0
	self.insetFrame.BorderSizePixel = 0
	self.insetFrame.Parent = self.backgroundFrame
	UIUtils.AddUICorner(self.insetFrame, 10)

	self.parentFrame = Instance.new("Frame")
	self.parentFrame.Name = "ParentFrame"
	self.parentFrame.Active = true
	self.parentFrame.Size = UDim2.new(1, 0, 1, -TOP_BOTTOM_MARGIN)
	self.parentFrame.Position = UDim2.new(0.5, 0, 0, TOP_BOTTOM_MARGIN)
	self.parentFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.parentFrame.BackgroundColor3 = DARK_COLOR_2
	self.parentFrame.BorderSizePixel = 0
	self.parentFrame.Parent = self.insetFrame
	UIUtils.AddUICorner(self.parentFrame, 10)

	-- "Quick tip" text
	-- Setup right side:
	--  - List of generated 2d images
	--  - Non-editable total prompt field
	--  - Frame to display a generated image
	self.rightFrame = Instance.new("Frame")
	self.rightFrame.Name = "RightFrame"
	self.rightFrame.Size = UDim2.new(1, 0, 1, 0)
	self.rightFrame.Position = UDim2.new(0, 0, 0, 0)
	self.rightFrame.BorderSizePixel = 0
	self.rightFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	self.rightFrame.Parent = self.parentFrame

	-- Frame that contains a list of generated 2d images
	self.generatedImagesListFrame = Instance.new("Frame")
	self.generatedImagesListFrame.Name = "GeneratedImagesListFrame"
	self.generatedImagesListFrame.Size = UDim2.new(1, 0, 0.25, 0)
	self.generatedImagesListFrame.Position = UDim2.new(0, 0, 0, 0)
	self.generatedImagesListFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
	self.generatedImagesListFrame.BorderSizePixel = 0
	self.generatedImagesListFrame.Parent = self.rightFrame

	-- Add list layout
	self.generatedImagesLayout = Instance.new("UIListLayout")
	self.generatedImagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.generatedImagesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	self.generatedImagesLayout.FillDirection = Enum.FillDirection.Horizontal
	self.generatedImagesLayout.Padding = UDim.new(0, 5)
	self.generatedImagesLayout.Parent = self.generatedImagesListFrame

	-- Frame that includes the prompt text and the prompt image
	self.finalPromptFrame = Instance.new("Frame")
	self.finalPromptFrame.Name = "FinalPromptFrame"
	self.finalPromptFrame.Size = UDim2.new(1, 0, 0.25, 0)
	self.finalPromptFrame.AnchorPoint = Vector2.new(0, 1)
	self.finalPromptFrame.Position = UDim2.new(0, 0, 1, 0)
	self.finalPromptFrame.BackgroundColor3 = Color3.fromRGB(37, 39, 46)
	self.finalPromptFrame.BorderSizePixel = 0
	self.finalPromptFrame.Parent = self.rightFrame

	-- Parent that holds the prompt text field, a plus sign, an image to the left of the prompt
	self.promptParent, self.promptField = self:CreatePromptParent()
	self.promptParent.Size = UDim2.new(1, -40, 0, PROMPT_TEXTBOX_HEIGHT + 10)
	self.promptParent.Position = UDim2.new(0, 20, 0, 15)
	self.promptParent.Parent = self.finalPromptFrame

	local bottomBarRight = Instance.new("Frame")
	bottomBarRight.Name = "BottomBarRight"
	bottomBarRight.Size = UDim2.fromOffset(0, 30)
	bottomBarRight.Position = UDim2.new(1, 0, 1, -12)
	bottomBarRight.AnchorPoint = Vector2.new(1, 1)
	bottomBarRight.AutomaticSize = Enum.AutomaticSize.X
	bottomBarRight.BackgroundTransparency = 1
	bottomBarRight.Parent = self.finalPromptFrame
	local bottomBarRightLayout = UIUtils.AddListLayout(bottomBarRight, 12)
	bottomBarRightLayout.FillDirection = Enum.FillDirection.Horizontal
	bottomBarRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	local bottomBarRightPadding = UIUtils.AddUIPadding(bottomBarRight, 0)
	bottomBarRightPadding.PaddingRight = UDim.new(0, 24)

	-- "N Generations Remaining" text
	self.genRemainingText = Instance.new("TextLabel")
	self.genRemainingText.Name = "GenRemainingText"
	self.genRemainingText.LayoutOrder = 1
	self.genRemainingText.Size = UDim2.fromOffset(150, 30)
	self.genRemainingText.BackgroundTransparency = 1
	self.genRemainingText.Font = TEXT_FONT
	self.genRemainingText.TextSize = 10
	self.genRemainingText.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.genRemainingText.TextXAlignment = Enum.TextXAlignment.Right
	self.genRemainingText.Visible = false
	self.genRemainingText.Parent = bottomBarRight

	-- Generate2dButton goes under the prompt field
	self.generate2DButton = self:CreateGenerate2DButton()
	self.generate2DButton.Size = UDim2.new(0, 160, 0, 40)
	self.generate2DButton.LayoutOrder = 2
	self.generate2DButton.Parent = bottomBarRight

	-- A button that the user can click to generate a 3D model from the last generated 2D image
	self.generate3DButton = Instance.new("TextButton")
	self.generate3DButton.Name = "Generate3DButton"
	self.generate3DButton.LayoutOrder = 3
	self.generate3DButton.Size = UDim2.new(0, 150, 0, 40)
	self.generate3DButton.Text = "Create Avatar"
	self.generate3DButton.Font = TEXT_FONT
	self.generate3DButton.TextSize = 14
	self.generate3DButton.TextColor3 = COLOR_WHITE
	self.generate3DButton.BackgroundColor3 = COLOR_ACTION
	self.generate3DButton.Parent = bottomBarRight
	self.generate3DButton.Visible = false
	-- Add corner
	UIUtils.AddUICorner(self.generate3DButton, 10)

	-- A parent for the loading animation and generated image
	self.rightBottomFrame = Instance.new("Frame")
	self.rightBottomFrame.Name = "RightBottomFrame"
	self.rightBottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
	self.rightBottomFrame.Position = UDim2.new(0, 0, 0.25, 0)
	self.rightBottomFrame.BackgroundColor3 = Color3.fromRGB(6, 7, 8)
	self.rightBottomFrame.BorderSizePixel = 0
	self.rightBottomFrame.Parent = self.rightFrame

	self:CreateGeneratedImagePanel(self.rightBottomFrame)

	-- Separate ScreenGui so that input doesn't fall through to the main UI
	self.gen3DAlertScreenGui = Instance.new("ScreenGui")
	self.gen3DAlertScreenGui.Name = "Gen3DAlertScreenGui"
	self.gen3DAlertScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.gen3DAlertScreenGui.ResetOnSpawn = false
	self.gen3DAlertScreenGui.Parent = PlayerGui
	self.gen3DAlertScreenGui.Enabled = false
	self.gen3DAlertScreenGui.DisplayOrder = 6

	-- A panel that covers the entire screen and is used to block input while the 3D model is being generated
	self.blockerPanel = Instance.new("Frame")
	self.blockerPanel.Name = "BlockerPanel"
	self.blockerPanel.Size = UDim2.new(1, 0, 1, guiInset)
	self.blockerPanel.Position = UDim2.new(0, 0, 0, -guiInset)
	self.blockerPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.blockerPanel.BackgroundTransparency = 0.5
	self.blockerPanel.BorderSizePixel = 0
	self.blockerPanel.Parent = self.gen3DAlertScreenGui

	self:CreateGen3dWaitPanel()

	-- Progress UI
	self.progressUI = ProgressUI.new()

	self:SetupConfirmLeaveDialog()
	-- A background and text field that shows how much time the user has in the generation process
	self.genTimeTextBg, self.genTimeText = self:CreateGenTimeText()
	self.genTimeTextBg.Parent = self.insetFrame
	self.genTimeTextBg.Size = UDim2.new(0, 160, 0, TOP_BOTTOM_MARGIN - 20)
	self.genTimeTextBg.Position = UDim2.new(1, -170, 0, 10)

	-- A button to close this UI
	self.exitButton = self:CreateExitButton()
	self.exitButton.Parent = self.insetFrame

	-- When clicked, close the UI
	self.exitButton.Activated:Connect(function()
		self:ShowConfirmLeaveDialog()
	end)

	-- Start with the buttons disabled
	self:DisableGenerate3DButton()
end

function SelfiePreview:Setup3dTimeExpiredAlert()
	-- A separate ScreenGui so that input doesn't fall through to the main UI
	self.timeExpired3DAlertScreenGui = Instance.new("ScreenGui")
	self.timeExpired3DAlertScreenGui.Name = "TimeExpired3DAlertScreenGui"
	self.timeExpired3DAlertScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.timeExpired3DAlertScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	self.timeExpired3DAlertScreenGui.ScreenInsets = Enum.ScreenInsets.None
	self.timeExpired3DAlertScreenGui.ResetOnSpawn = false
	self.timeExpired3DAlertScreenGui.Parent = PlayerGui
	self.timeExpired3DAlertScreenGui.Enabled = false

	-- A panel that covers the entire screen and is used to block input
	local blockerPanel = Instance.new("TextButton")
	blockerPanel.Name = "BlockerPanel"
	blockerPanel.AutoButtonColor = false
	blockerPanel.Text = ""
	blockerPanel.Size = UDim2.new(1, 0, 1, 0)
	blockerPanel.Position = UDim2.new(0, 0, 0, 0)
	blockerPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blockerPanel.BackgroundTransparency = 0.5
	blockerPanel.Active = true
	blockerPanel.ZIndex = 1
	blockerPanel.Parent = self.timeExpired3DAlertScreenGui

	-- A panel that displays a message to the user when the 3D model generation time has expired
	self.gen3DTimeExpiredPanel = Instance.new("Frame")
	self.gen3DTimeExpiredPanel.Name = "Gen3DTimeExpiredPanel"
	self.gen3DTimeExpiredPanel.Size = UDim2.fromOffset(400, 0)
	self.gen3DTimeExpiredPanel.AutomaticSize = Enum.AutomaticSize.Y
	self.gen3DTimeExpiredPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.gen3DTimeExpiredPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	self.gen3DTimeExpiredPanel.BackgroundColor3 = COLOR_DIALOG_BG
	self.gen3DTimeExpiredPanel.ZIndex = 2
	self.gen3DTimeExpiredPanel.Parent = self.timeExpired3DAlertScreenGui
	UIUtils.AddUICorner(self.gen3DTimeExpiredPanel)

	local panelPadding = Instance.new("UIPadding")
	panelPadding.PaddingBottom = UDim.new(0, 24)
	panelPadding.PaddingTop = UDim.new(0, 10)
	panelPadding.PaddingLeft = UDim.new(0, 24)
	panelPadding.PaddingRight = UDim.new(0, 24)
	panelPadding.Parent = self.gen3DTimeExpiredPanel

	local listLayout = UIUtils.AddListLayout(self.gen3DTimeExpiredPanel, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "Gen3DTimeExpiredTitleFrame"
	titleFrame.BackgroundTransparency = 1
	titleFrame.Size = UDim2.new(1, 0, 0, 38)
	titleFrame.Parent = self.gen3DTimeExpiredPanel

	local title = Instance.new("TextLabel")
	title.Name = "Gen3DTimeExpiredTitle"
	title.Text = "Session Expired"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = TEXT_FONT
	title.TextSize = 28
	title.TextColor3 = COLOR_WHITE
	title.BorderSizePixel = 0
	title.LayoutOrder = 1
	title.Parent = titleFrame

	local divider = Instance.new("Frame")
	divider.BackgroundColor3 = COLOR_DIALOG_DIVIDER
	divider.BorderSizePixel = 0
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.LayoutOrder = 2
	divider.Parent = titleFrame

	-- A text field that tells the user that the 3D model generation time has expired
	self.gen3DTimeExpiredText = Instance.new("TextLabel")
	self.gen3DTimeExpiredText.Name = "Gen3DTimeExpiredText"
	self.gen3DTimeExpiredText.Size = UDim2.new(1, 0, 0, 0)
	self.gen3DTimeExpiredText.AutomaticSize = Enum.AutomaticSize.Y
	self.gen3DTimeExpiredText.Position = UDim2.new(0, 0, 0, 0)
	self.gen3DTimeExpiredText.Text =
		"The session has expired. If you'd like to try again, please start a new generation session."
	self.gen3DTimeExpiredText.Font = TEXT_FONT
	self.gen3DTimeExpiredText.TextSize = 20
	self.gen3DTimeExpiredText.TextColor3 = COLOR_DIALOG_TEXT
	self.gen3DTimeExpiredText.TextWrapped = true
	self.gen3DTimeExpiredText.TextXAlignment = Enum.TextXAlignment.Left
	self.gen3DTimeExpiredText.TextYAlignment = Enum.TextYAlignment.Top
	self.gen3DTimeExpiredText.BackgroundTransparency = 1
	self.gen3DTimeExpiredText.BorderSizePixel = 0
	self.gen3DTimeExpiredText.LayoutOrder = 3
	self.gen3DTimeExpiredText.Parent = self.gen3DTimeExpiredPanel

	local buttonPanel = Instance.new("Frame")
	buttonPanel.Name = "ButtonPanel"
	buttonPanel.Size = UDim2.new(1, 0, 0, 40)
	buttonPanel.BackgroundTransparency = 1
	buttonPanel.LayoutOrder = 4
	buttonPanel.Parent = self.gen3DTimeExpiredPanel

	-- A button that the user can click to close the gen3DTimeExpiredPanel
	self.closeGen3DTimeExpiredButton = Instance.new("TextButton")
	self.closeGen3DTimeExpiredButton.Name = "CloseGen3DTimeExpiredButton"
	self.closeGen3DTimeExpiredButton.Size = UDim2.new(0.5, -8, 0, 40)
	self.closeGen3DTimeExpiredButton.Position = UDim2.new(0.5, 0, 0, 0)
	self.closeGen3DTimeExpiredButton.AnchorPoint = Vector2.new(0.5, 0)
	self.closeGen3DTimeExpiredButton.BackgroundColor3 = COLOR_ACTION
	self.closeGen3DTimeExpiredButton.Text = "OK"
	self.closeGen3DTimeExpiredButton.Font = TEXT_FONT
	self.closeGen3DTimeExpiredButton.TextSize = 16
	self.closeGen3DTimeExpiredButton.TextColor3 = COLOR_WHITE
	self.closeGen3DTimeExpiredButton.Parent = buttonPanel
	UIUtils.AddUICorner(self.closeGen3DTimeExpiredButton, 10)

	self.closeGen3DTimeExpiredButton.Activated:Connect(function()
		self.timeExpired3DAlertScreenGui.Enabled = false
	end)
end

function SelfiePreview:CreateGeneratedImagePanel(parent)
	-- A helpful text label that explains how to generate an image
	self.genHelpText = Instance.new("TextLabel")
	self.genHelpText.Name = "GenHelpText"
	self.genHelpText.Size = UDim2.new(1, -40, 0, 50)
	self.genHelpText.AnchorPoint = Vector2.new(0.5, 0.5)
	self.genHelpText.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.genHelpText.BackgroundTransparency = 1
	self.genHelpText.Text = HINT_TEXT
	self.genHelpText.Font = TEXT_FONT
	self.genHelpText.TextSize = 16
	self.genHelpText.TextColor3 = HINT_COLOR
	self.genHelpText.TextWrapped = true
	self.genHelpText.TextXAlignment = Enum.TextXAlignment.Center
	self.genHelpText.TextYAlignment = Enum.TextYAlignment.Top
	self.genHelpText.BorderSizePixel = 0
	self.genHelpText.ZIndex = 2
	self.genHelpText.Parent = parent

	self.generatedImage = Instance.new("ImageLabel")
	self.generatedImage.Name = "GeneratedImage"
	self.generatedImage.AnchorPoint = Vector2.new(0.5, 0)
	self.generatedImage.Size = UDim2.new(1, -10, 1, -10)
	self.generatedImage.Position = UDim2.new(0.5, 0, 0, 5)
	self.generatedImage.BackgroundTransparency = 1
	self.generatedImage.BorderSizePixel = 0
	self.generatedImage.ScaleType = Enum.ScaleType.Fit
	self.generatedImage.Parent = parent
	UIUtils.AddUICorner(self.generatedImage, 10)

	-- A parent for the loading animation and progress text
	self.loadingImageFrame = Instance.new("Frame")
	self.loadingImageFrame.Name = "LoadingImageFrame"
	self.loadingImageFrame.Size = UDim2.new(1, 0, 1, 0)
	self.loadingImageFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.loadingImageFrame.Position = UDim2.new(0.5, 0, 0, 0)
	self.loadingImageFrame.BackgroundTransparency = 1
	self.loadingImageFrame.BorderSizePixel = 0
	self.loadingImageFrame.Parent = parent
	self.loadingImageFrame.Visible = false
	-- Aspect ratio constraint
	local aspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	aspectRatioConstraint.AspectRatio = 1
	aspectRatioConstraint.Parent = self.loadingImageFrame

	-- A text field that displays the progress of the 2D image generation
	self.genProgressText = Instance.new("TextLabel")
	self.genProgressText.Name = "GenProgressText"
	self.genProgressText.Size = UDim2.new(1, 0, 0, 50)
	self.genProgressText.AnchorPoint = Vector2.new(0, 0.5)
	self.genProgressText.Position = UDim2.new(0, 0, 0.5, -50)
	self.genProgressText.Text = "Creating your preview image"
	self.genProgressText.Font = TEXT_FONT
	self.genProgressText.TextSize = 16
	self.genProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.genProgressText.BackgroundTransparency = 1
	self.genProgressText.ZIndex = 2
	self.genProgressText.Parent = self.loadingImageFrame

	-- Smaller text field
	self.genProgressTextSmall = Instance.new("TextLabel")
	self.genProgressTextSmall.Name = "GenProgressTextSmall"
	self.genProgressTextSmall.Size = UDim2.new(1, 0, 0, 30)
	self.genProgressTextSmall.AnchorPoint = Vector2.new(0, 0.5)
	self.genProgressTextSmall.Position = UDim2.new(0, 0, 0.5, -20)
	self.genProgressTextSmall.Text = "This can take up to one minute"
	self.genProgressTextSmall.Font = TEXT_FONT
	self.genProgressTextSmall.TextSize = 14
	self.genProgressTextSmall.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.genProgressTextSmall.BackgroundTransparency = 1
	self.genProgressTextSmall.ZIndex = 2
	self.genProgressTextSmall.Parent = self.loadingImageFrame

	-- A rotating loading spinner that is displayed while the 2D image is being generated
	self.loadingSpinner = Instance.new("ImageLabel")
	self.loadingSpinner.Name = "LoadingSpinner"
	self.loadingSpinner.Size = UDim2.new(0, 80, 0, 80)
	self.loadingSpinner.Position = UDim2.new(0.5, 0, 0.5, 40)
	self.loadingSpinner.AnchorPoint = Vector2.new(0.5, 0.5)
	self.loadingSpinner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.loadingSpinner.Image = "rbxassetid://16630744538"
	self.loadingSpinner.ImageColor3 = Color3.fromRGB(100, 100, 100)
	self.loadingSpinner.BackgroundTransparency = 1
	self.loadingSpinner.Parent = self.loadingImageFrame

	-- The loading spinner is always running, so we can just start it here
	self.loadingSpinner.Rotation = 0
	RunService.Heartbeat:Connect(function()
		self.loadingSpinner.Rotation = self.loadingSpinner.Rotation + 1
	end)
end

function SelfiePreview:CreateGen3dWaitPanel()
	-- A panel that appears after the user clicks the "Generate 3D Model" button and the 3D model is being generated
	-- It tells the user that the 3D model is being generated and to wait
	self.gen3DWaitPanel = Instance.new("Frame")
	self.gen3DWaitPanel.Name = "Gen3DWaitPanel"
	self.gen3DWaitPanel.Size = UDim2.fromOffset(480, 0)
	self.gen3DWaitPanel.AutomaticSize = Enum.AutomaticSize.Y
	self.gen3DWaitPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.gen3DWaitPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	self.gen3DWaitPanel.BackgroundColor3 = COLOR_DIALOG_BG
	self.gen3DWaitPanel.ZIndex = 2
	self.gen3DWaitPanel.Parent = self.gen3DAlertScreenGui
	UIUtils.AddUICorner(self.gen3DWaitPanel)

	local panelPadding = Instance.new("UIPadding")
	panelPadding.PaddingBottom = UDim.new(0, 24)
	panelPadding.PaddingTop = UDim.new(0, 10)
	panelPadding.PaddingLeft = UDim.new(0, 24)
	panelPadding.PaddingRight = UDim.new(0, 24)
	panelPadding.Parent = self.gen3DWaitPanel

	local listLayout = UIUtils.AddListLayout(self.gen3DWaitPanel, 24)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "Gen3DWaitTitleFrame"
	titleFrame.BackgroundTransparency = 1
	titleFrame.Size = UDim2.new(1, 0, 0, 38)
	titleFrame.Parent = self.gen3DWaitPanel

	local title = Instance.new("TextLabel")
	title.Name = "Gen3DWaitTitle"
	title.Text = "Wait for Generation"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = TEXT_FONT
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextSize = 28
	title.TextColor3 = COLOR_WHITE
	title.BorderSizePixel = 0
	title.LayoutOrder = 1
	title.Parent = titleFrame

	local divider = Instance.new("Frame")
	divider.BackgroundColor3 = COLOR_DIALOG_DIVIDER
	divider.BorderSizePixel = 0
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.LayoutOrder = 2
	divider.Parent = titleFrame

	-- A text field that tells the user to wait while the 3D model is being generated
	local gen3DWaitText = Instance.new("TextLabel")
	gen3DWaitText.Name = "Gen3DWaitText"
	gen3DWaitText.Text =
		"The 3D model will be generated. This may take several minutes. Progress will be displayed in the top-right corner of the screen. Once the model is generated, you will be able to view and equip it in this experience."
	gen3DWaitText.Size = UDim2.new(1, 0, 0, 0)
	gen3DWaitText.AutomaticSize = Enum.AutomaticSize.Y
	gen3DWaitText.BackgroundTransparency = 1
	gen3DWaitText.Font = TEXT_FONT
	gen3DWaitText.TextSize = 20
	gen3DWaitText.TextColor3 = COLOR_DIALOG_TEXT
	gen3DWaitText.TextWrapped = true
	gen3DWaitText.TextXAlignment = Enum.TextXAlignment.Left
	gen3DWaitText.TextYAlignment = Enum.TextYAlignment.Top
	gen3DWaitText.BorderSizePixel = 0
	gen3DWaitText.LayoutOrder = 3
	gen3DWaitText.Parent = self.gen3DWaitPanel

	local buttonPanel = Instance.new("Frame")
	buttonPanel.Name = "ButtonPanel"
	buttonPanel.Size = UDim2.new(1, 0, 0, 40)
	buttonPanel.BackgroundTransparency = 1
	buttonPanel.LayoutOrder = 4
	buttonPanel.Parent = self.gen3DWaitPanel

	local continueButton = Instance.new("TextButton")
	continueButton.Name = "ContinueButton"
	continueButton.Size = UDim2.new(0.5, -8, 0, 40)
	continueButton.Position = UDim2.new(0, 0, 0, 0)
	continueButton.AnchorPoint = Vector2.new(0, 0)
	continueButton.BackgroundColor3 = COLOR_ACTION
	continueButton.Text = "Continue"
	continueButton.Font = TEXT_FONT
	continueButton.TextSize = 16
	continueButton.TextColor3 = COLOR_WHITE
	continueButton.Parent = buttonPanel
	UIUtils.AddUICorner(continueButton, 10)

	continueButton.Activated:Connect(function()
		self.CreationManager:OnClickedGenerate3d(self.selectedImageIndex)
		self.progressUI:ShowProgress()
		self:Hide(EndSessionReason.Gen3D)
	end)

	local cancelButtonFrame, cancelButton =
		UIUtils.CreateOutlineButton("Cancel", COLOR_DIALOG_TEXT, COLOR_DIALOG_BG, COLOR_DIALOG_TEXT)
	cancelButtonFrame.Parent = buttonPanel
	cancelButtonFrame.Size = UDim2.new(0.5, -8, 0, 40)
	cancelButtonFrame.Position = UDim2.new(1, 0, 0, 0)
	cancelButtonFrame.AnchorPoint = Vector2.new(1, 0)

	cancelButton.Activated:Connect(function()
		self.gen3DAlertScreenGui.Enabled = false
	end)
end

function SelfiePreview:CreateGenerate2DButton()
	local generate2DButton = Instance.new("TextButton")
	generate2DButton.Name = "Generate2DButton"
	generate2DButton.Size = UDim2.new(0, 160, 0, 40)
	generate2DButton.AnchorPoint = Vector2.new(1, 1)
	generate2DButton.Position = UDim2.new(1, -20, 1, -12)
	generate2DButton.BackgroundColor3 = COLOR_ACTION
	generate2DButton.Text = "Take a Selfie"
	generate2DButton.Font = TEXT_FONT
	generate2DButton.TextWrapped = true
	generate2DButton.TextSize = 14
	generate2DButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	UIUtils.AddUICorner(generate2DButton, 8)

	return generate2DButton
end

function SelfiePreview:CreatePromptParent()
	local promptParent = Instance.new("Frame")
	promptParent.Name = "PromptParent"
	promptParent.BackgroundTransparency = 1
	promptParent.BorderSizePixel = 0
	UIUtils.AddUICorner(promptParent, 5)

	-- Prompt text field
	local promptField = Instance.new("TextBox")
	promptField.Active = false -- Needed to prevent editing (TextEditable is not enough for some reason)
	promptField.Name = "PromptField"
	promptField.Size = UDim2.new(1, -(40 + PROMPT_TEXTBOX_HEIGHT), 0, PROMPT_TEXTBOX_HEIGHT)
	promptField.AnchorPoint = Vector2.new(0, 0.5)
	promptField.Position = UDim2.new(0, 30 + PROMPT_TEXTBOX_HEIGHT, 0.5, 0)
	promptField.BackgroundTransparency = 1
	promptField.Text = ""
	promptField.TextEditable = false
	promptField.ClearTextOnFocus = false
	promptField.Font = TEXT_FONT
	promptField.TextSize = 14
	promptField.TextWrapped = true
	promptField.TextXAlignment = Enum.TextXAlignment.Left
	promptField.TextYAlignment = Enum.TextYAlignment.Center
	promptField.TextColor3 = Color3.fromRGB(200, 200, 200)
	promptField.BorderSizePixel = 0
	promptField.Parent = promptParent

	UIUtils.AddUICorner(promptField, 10)
	UIUtils.AddUIPadding(promptField, 10)

	return promptParent, promptField
end

function SelfiePreview:CreateGenTimeText()
	genTimeTextBg = Instance.new("TextButton")
	genTimeTextBg.Name = "GenTimeTextBg"
	genTimeTextBg.Text = ""
	genTimeTextBg.AutoButtonColor = false
	genTimeTextBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	UIUtils.AddUICorner(genTimeTextBg, 10)

	genTimeText = Instance.new("TextLabel")
	genTimeText.Name = "GenTimeText"
	genTimeText.Size = UDim2.new(1, -20, 1, -10)
	genTimeText.Position = UDim2.new(0, 10, 0, 5)
	genTimeText.BackgroundTransparency = 1
	genTimeText.Text = "0:00 minutes remaining"
	genTimeText.Font = TEXT_FONT
	genTimeText.TextSize = 11
	genTimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
	genTimeText.TextXAlignment = Enum.TextXAlignment.Left
	genTimeText.TextYAlignment = Enum.TextYAlignment.Center
	genTimeText.Parent = genTimeTextBg

	-- Info icon that suggest that this is a clickable element
	local infoIcon = Instance.new("ImageLabel")
	infoIcon.Name = "InfoIcon"
	infoIcon.Size = UDim2.new(0, 20, 0, 20)
	infoIcon.Position = UDim2.new(1, -5, 0.5, 0)
	infoIcon.AnchorPoint = Vector2.new(1, 0.5)
	infoIcon.BackgroundTransparency = 1
	infoIcon.Image = "rbxassetid://17571549522"
	infoIcon.Parent = genTimeTextBg

	-- Update the time text every second
	genTimeTextUpdate = RunService.Heartbeat:Connect(function()
		if self.genEndTime then
			timeRemaining = self.genEndTime - tick()

			if timeRemaining < 0 then
				local overMinutes = 0
				local overSeconds = math.floor((60 + timeRemaining) % 60)
				genTimeText.Text = string.format("%d:%02d to create avatar", overMinutes, overSeconds)
			else
				local minutes = math.floor(timeRemaining / 60)
				local seconds = math.floor(timeRemaining % 60)
				genTimeText.Text = string.format("%d:%02d minutes remaining", minutes, seconds)
			end

			-- If we've just passed the 2 minute mark, tween the background color to yellow
			if timeRemaining < 120 and not self.genTimeTextBgHighlighted then
				self.genTimeTextBgHighlighted = true
				local tInfo = TweenInfo.new(
					2, -- Time/Speed
					Enum.EasingStyle.Quint, -- EasingStyle
					Enum.EasingDirection.Out, -- EasingDirection
					0, -- RepeatCount (when less than zero the tween will loop indefinitely)
					true, -- Reverses (tween will reverse once reaching it's goal)
					0 -- DelayTime
				)
				TweenService:Create(genTimeTextBg, tInfo, { BackgroundColor3 = Color3.fromRGB(191, 138, 0) }):Play()
			end

			-- If we've just passed the 1 minute mark, tween the background color to red
			if timeRemaining < 60 and not self.genTimeTextBgRed then
				self.genTimeTextBgRed = true
				local tInfo = TweenInfo.new(
					1, -- Time/Speed
					Enum.EasingStyle.Quint, -- EasingStyle
					Enum.EasingDirection.Out, -- EasingDirection
					0, -- RepeatCount (when less than zero the tween will loop indefinitely)
					false, -- Reverses (tween will reverse once reaching it's goal)
					0 -- DelayTime
				)
				TweenService:Create(genTimeTextBg, tInfo, { BackgroundColor3 = Color3.fromRGB(162, 18, 11) }):Play()
			end

			-- When the time runs out, put an overlay on top of the base images/prompts and disable the 2d button.
			-- Generate 3d is active for one more minute.
			if timeRemaining <= 0 and not self.gen2dTimeExpired then
				self.gen2dTimeExpired = true
				self:Disable2DInput()
				self:DisableGenerate2DButton()
			end

			-- When the time runs out for the 3d model, exit the UI and show an alert "time has expired"
			if timeRemaining <= -60 and not self.gen3dTimeExpired then
				self.gen3dTimeExpired = true
				self:DisableGenerate3DButton()
				self.timeExpired3DAlertScreenGui.Enabled = true

				-- Exit the UI
				self:Hide(EndSessionReason.TimeExpired)
			end
		end
	end)

	-- Small tooltip that appears when the user clicks on the info icon
	local genTimeTooltip = Instance.new("Frame")
	genTimeTooltip.Name = "GenTimeTooltip"
	genTimeTooltip.Size = UDim2.new(0, 200, 0, 60)
	genTimeTooltip.Position = UDim2.new(0.5, 0, 1, 5)
	genTimeTooltip.AnchorPoint = Vector2.new(0.5, 0)
	genTimeTooltip.BackgroundColor3 = Color3.fromRGB(101, 102, 104)
	genTimeTooltip.BorderSizePixel = 0
	genTimeTooltip.Visible = false
	genTimeTooltip.ZIndex = 15
	genTimeTooltip.Parent = genTimeTextBg
	UIUtils.AddUICorner(genTimeTooltip, 5)

	-- Arrow (rotated frame) that points to the info icon
	local arrowFrame = Instance.new("Frame")
	arrowFrame.Name = "ArrowFrame"
	arrowFrame.Size = UDim2.new(0, 20, 0, 20)
	arrowFrame.Position = UDim2.new(0.5, 0, 0, 0)
	arrowFrame.AnchorPoint = Vector2.new(0.5, 0)
	arrowFrame.BackgroundColor3 = Color3.fromRGB(101, 102, 104)
	arrowFrame.BorderSizePixel = 0
	arrowFrame.Rotation = 45
	arrowFrame.Parent = genTimeTooltip

	local genTimeTooltipHeader = Instance.new("TextLabel")
	genTimeTooltipHeader.Name = "GenTimeTooltipHeader"
	genTimeTooltipHeader.Size = UDim2.new(1, 0, 0, 20)
	genTimeTooltipHeader.Position = UDim2.new(0, 10, 0, 10)
	genTimeTooltipHeader.BackgroundTransparency = 1
	genTimeTooltipHeader.Text = "Time Limit"
	genTimeTooltipHeader.Font = TEXT_FONT
	genTimeTooltipHeader.TextSize = 12
	genTimeTooltipHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
	genTimeTooltipHeader.TextWrapped = true
	genTimeTooltipHeader.TextXAlignment = Enum.TextXAlignment.Left
	genTimeTooltipHeader.TextYAlignment = Enum.TextYAlignment.Top
	genTimeTooltipHeader.Parent = genTimeTooltip

	local genTimeTooltipText = Instance.new("TextLabel")
	genTimeTooltipText.Name = "GenTimeTooltipText"
	genTimeTooltipText.Size = UDim2.new(1, -20, 1, -20)
	genTimeTooltipText.Position = UDim2.new(0, 10, 0, 30)
	genTimeTooltipText.BackgroundTransparency = 1
	genTimeTooltipText.Text = "We're limiting creation time to allow everyone in line a chance to create"
	genTimeTooltipText.Font = TEXT_FONT
	genTimeTooltipText.TextSize = 10
	genTimeTooltipText.TextColor3 = Color3.fromRGB(255, 255, 255)
	genTimeTooltipText.TextWrapped = true
	genTimeTooltipText.TextXAlignment = Enum.TextXAlignment.Left
	genTimeTooltipText.TextYAlignment = Enum.TextYAlignment.Top
	genTimeTooltipText.Parent = genTimeTooltip

	-- When the user clicks this element, show a small tooltip
	genTimeTextBg.Activated:Connect(function()
		genTimeTooltip.Visible = not genTimeTooltip.Visible
	end)

	return genTimeTextBg, genTimeText
end

function SelfiePreview:CreateExitButton()
	local exitButton = Instance.new("TextButton")
	exitButton.Name = "ExitButton"
	exitButton.Size = UDim2.new(0, 30, 0, 30)
	exitButton.Position = UDim2.new(0, 5, 0, 5)
	exitButton.AnchorPoint = Vector2.new(0, 0)
	exitButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	exitButton.Text = "X"
	exitButton.Font = TEXT_FONT
	exitButton.TextSize = 16
	exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	UIUtils.AddUICorner(exitButton, 0, 0.5)
	return exitButton
end

function SelfiePreview:SetupConfirmLeaveDialog()
	self.confirmLeaveScreenGui = Instance.new("ScreenGui")
	self.confirmLeaveScreenGui.Name = "ConfirmLeaveScreenGui"
	self.confirmLeaveScreenGui.DisplayOrder = 10
	self.confirmLeaveScreenGui.Enabled = false
	self.confirmLeaveScreenGui.ResetOnSpawn = false
	self.confirmLeaveScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	self.confirmLeaveScreenGui.ScreenInsets = Enum.ScreenInsets.None
	self.confirmLeaveScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.confirmLeaveScreenGui.Parent = PlayerGui

	-- Blocker panel to prevent user from clicking on the UI after time has expired
	local blockerOverlay = Instance.new("TextButton")
	blockerOverlay.Name = "BlockerOverlay"
	blockerOverlay.AutoButtonColor = false
	blockerOverlay.Text = ""
	blockerOverlay.Size = UDim2.new(1, 0, 1, 0)
	blockerOverlay.Position = UDim2.new(0, 0, 0, 0)
	blockerOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blockerOverlay.BackgroundTransparency = 0.5
	blockerOverlay.Active = true
	blockerOverlay.ZIndex = 1
	blockerOverlay.Parent = self.confirmLeaveScreenGui

	local confirmLeavePanel = Instance.new("Frame")
	confirmLeavePanel.Name = "ConfirmLeavePanel"
	confirmLeavePanel.Size = UDim2.fromOffset(480, 0)
	confirmLeavePanel.AutomaticSize = Enum.AutomaticSize.Y
	confirmLeavePanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	confirmLeavePanel.AnchorPoint = Vector2.new(0.5, 0.5)
	confirmLeavePanel.BackgroundColor3 = COLOR_DIALOG_BG
	confirmLeavePanel.ZIndex = 2
	confirmLeavePanel.Parent = self.confirmLeaveScreenGui
	UIUtils.AddUICorner(confirmLeavePanel)

	local panelPadding = Instance.new("UIPadding")
	panelPadding.PaddingBottom = UDim.new(0, 24)
	panelPadding.PaddingTop = UDim.new(0, 10)
	panelPadding.PaddingLeft = UDim.new(0, 24)
	panelPadding.PaddingRight = UDim.new(0, 24)
	panelPadding.Parent = confirmLeavePanel

	local listLayout = UIUtils.AddListLayout(confirmLeavePanel, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "ConfirmLeaveTitleFrame"
	titleFrame.BackgroundTransparency = 1
	titleFrame.Size = UDim2.new(1, 0, 0, 38)
	titleFrame.Parent = confirmLeavePanel

	local title = Instance.new("TextLabel")
	title.Name = "ConfirmLeaveTitle"
	title.Text = "Leave Creation"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = TEXT_FONT
	title.TextSize = 28
	title.TextColor3 = COLOR_WHITE
	title.BorderSizePixel = 0
	title.LayoutOrder = 1
	title.Parent = titleFrame

	local divider = Instance.new("Frame")
	divider.BackgroundColor3 = COLOR_DIALOG_DIVIDER
	divider.BorderSizePixel = 0
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.LayoutOrder = 2
	divider.Parent = titleFrame

	local description = Instance.new("TextLabel")
	description.Name = "ConfirmLeaveDescription"
	description.Text = "Preview images won't be saved, and you'll need to rejoin the queue to return."
	description.Size = UDim2.new(1, 0, 0, 0)
	description.AutomaticSize = Enum.AutomaticSize.Y
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.BackgroundTransparency = 1
	description.Font = TEXT_FONT
	description.TextSize = 20
	description.TextColor3 = COLOR_DIALOG_TEXT
	description.TextWrapped = true
	description.BorderSizePixel = 0
	description.LayoutOrder = 1
	description.Parent = confirmLeavePanel

	local buttonPanel = Instance.new("Frame")
	buttonPanel.Name = "ButtonPanel"
	buttonPanel.Size = UDim2.new(1, 0, 0, 30)
	buttonPanel.BackgroundTransparency = 1
	buttonPanel.LayoutOrder = 4
	buttonPanel.Parent = confirmLeavePanel

	local confirmLeaveButton = Instance.new("TextButton")
	confirmLeaveButton.Name = "ConfirmLeaveButton"
	confirmLeaveButton.Size = UDim2.new(0.5, -8, 0, 40)
	confirmLeaveButton.Position = UDim2.new(0, 0, 0, 0)
	confirmLeaveButton.AnchorPoint = Vector2.new(0, 0)
	confirmLeaveButton.BackgroundColor3 = COLOR_ACTION
	confirmLeaveButton.Text = "Confirm"
	confirmLeaveButton.Font = TEXT_FONT
	confirmLeaveButton.TextSize = 16
	confirmLeaveButton.TextColor3 = COLOR_WHITE
	confirmLeaveButton.Parent = buttonPanel
	UIUtils.AddUICorner(confirmLeaveButton, 10)

	confirmLeaveButton.Activated:Connect(function()
		self:HideConfirmLeaveDialog()
		self:Hide(EndSessionReason.Exit)
	end)

	local cancelLeaveButtonFrame, cancelLeaveButton =
		UIUtils.CreateOutlineButton("Cancel", COLOR_DIALOG_TEXT, COLOR_DIALOG_BG, COLOR_DIALOG_TEXT)
	cancelLeaveButtonFrame.Parent = buttonPanel
	cancelLeaveButtonFrame.Size = UDim2.new(0.5, -8, 0, 40)
	cancelLeaveButtonFrame.Position = UDim2.new(1, 0, 0, 0)
	cancelLeaveButtonFrame.AnchorPoint = Vector2.new(1, 0)

	cancelLeaveButton.Activated:Connect(function()
		self:HideConfirmLeaveDialog()
	end)
end

function SelfiePreview:HideConfirmLeaveDialog()
	self.confirmLeaveScreenGui.Enabled = false
end

function SelfiePreview:ShowConfirmLeaveDialog()
	self.confirmLeaveScreenGui.Enabled = true
end

function SelfiePreview:Start2dLoadingAnimation()
	self:ShowPlaceholderImage("")

	self.loadingSpinner.Visible = true

	self.genProgressText.Visible = true
	self.genHelpText.Visible = false
	self.loadingImageFrame.Visible = true
	self:HideGeneratedImage()

	-- Disable 2d input
	self:Disable2DInput()
end

function SelfiePreview:Stop2dLoadingAnimation()
	-- Hide the spinning thing
	self.loadingSpinner.Visible = false

	self.genProgressText.Visible = false
	self.loadingImageFrame.Visible = false

	self:Enable2DInput()
end

function SelfiePreview:ShowPlaceholderImage(image)
	-- Remove any existing editableImage children
	for _, child in pairs(self.generatedImage:GetChildren()) do
		if child:IsA("EditableImage") then
			child:Destroy()
		end
	end

	self.generatedImage.Image = image
end

function SelfiePreview:ShowGeneratedImage(editableImage, playerPromptString, jobId)
	self.totalNumGenerations = self.totalNumGenerations + 1
	self.numGenerationsRemaining = self.numGenerationsRemaining - 1
	-- When user generates a 2d preview, reduce the number of generations remaining
	if self.numGenerationsRemaining <= 3 then
		self.genRemainingText.Visible = true
		self.genRemainingText.Text = self.numGenerationsRemaining .. " generations remaining"

		if self.numGenerationsRemaining <= 0 then
			self:DisableGenerate2DButton()
			self:Disable2DInput()
		end
	else
		self.genRemainingText.Visible = false
	end
	local newImageIndex = jobId
	self.selectedImageIndex = newImageIndex

	self:Stop2dLoadingAnimation()
	self:EnableGenerate2DButton()
	self:EnableGenerate3DButton()

	-- Parent the editable image to the generated image frame
	if editableImage then
		local imageRectSize, imageRectOffset = UIUtils.GetImageRightHalfRect(editableImage)
		self.generatedImage.ImageContent = Content.fromObject(editableImage)
		if imageRectSize then
			self.generatedImage.ImageRectOffset = imageRectOffset
			self.generatedImage.ImageRectSize = imageRectSize
		end

		-- We need to make the 2d button the secondary button and change the text to "Retake Selfie"
		self.generate2DButton.Text = "Retake Selfie"
		self.generate2DButton.BackgroundColor3 = Color3.fromHex("#D0D9FB")
		self.generate2DButton.BackgroundTransparency = 0.88
		self.generate2DButton.TextColor3 = COLOR_WHITE

		-- and re-order the buttons so that 3d is primary (layout order swap)
		self.generate2DButton.LayoutOrder = 3
		self.generate3DButton.LayoutOrder = 2

		self.generate3DButton.Visible = true
		self.generate3DButton.Active = true

		self:RightAlignGeneratedImageParent()

		local imageFrame = Instance.new("Frame")
		imageFrame.Size = UDim2.new(0, 70, 0, 70)
		imageFrame.BackgroundColor3 = BUTTON_GREEN_COLOR
		imageFrame.BackgroundTransparency = 1
		imageFrame.Parent = self.generatedImagesListFrame
		UIUtils.AddUICorner(imageFrame, 5)

		local imageButton = Instance.new("ImageButton")
		imageButton.Size = UDim2.new(1, -4, 1, -4)
		imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
		imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageButton.BackgroundTransparency = 1
		imageButton.Parent = imageFrame
		imageButton.ImageContent = Content.fromObject(editableImage)
		if imageRectSize then
			imageButton.ImageRectOffset = imageRectOffset
			imageButton.ImageRectSize = imageRectSize
		end
		UIUtils.AddUICorner(imageButton, 5)

		-- When clicked, set the generated image to the cropped image
		imageButton.Activated:Connect(function()
			self:HideGeneratedImage()
			local imageRectSize, imageRectOffset = UIUtils.GetImageRightHalfRect(editableImage)
			self.generatedImage.ImageContent = Content.fromObject(editableImage)
			if imageRectSize then
				self.generatedImage.ImageRectOffset = imageRectOffset
				self.generatedImage.ImageRectSize = imageRectSize
			end
			self.selectedImageIndex = newImageIndex

			local image = self.CreationManager:GetImage(newImageIndex)

			-- Clear the base preview and prompt text
			-- Strip characters that are not alphanumeric, spaces, or commas
			self.promptField.Text = string.gsub(playerPromptString, "[^%w%s,]", "")
			self:EnableGenerate2DButton()
			self:EnableGenerate3DButton()

			-- Highlight the selected tile
			for _, child in pairs(self.generatedImagesListFrame:GetChildren()) do
				if child:IsA("Frame") then
					child.BackgroundTransparency = 1
				end
			end
			imageFrame.BackgroundTransparency = 0
		end)

		-- Highlight the tile that was just generated
		for _, child in pairs(self.generatedImagesListFrame:GetChildren()) do
			if child:IsA("Frame") then
				child.BackgroundTransparency = 1
			end
		end
		imageFrame.BackgroundTransparency = 0
	end
end

function SelfiePreview:HideGeneratedImage()
	-- If the generatedImage has a child, remove it
	local editableImage = self.generatedImage:FindFirstChildWhichIsA("EditableImage")

	if editableImage then
		editableImage:Destroy()
	end
end

function SelfiePreview:Disable2DInput()
	if promptFields then
		for _, child in pairs(self.promptFields) do
			if child:IsA("TextBox") then
				child.TextEditable = false
				child.TextColor3 = Color3.fromRGB(57, 59, 61)
			end
		end
	end

	-- Add an overlay to block the base avatars and prompt fields
	if not self.blockerOverlay2d then
		return
	end
	self.blockerOverlay2d.Visible = true
	self.blockerOverlay2d.Activated:Connect(function()
		-- Show a message that time has expired and the only option is to generate 3d
		print("Time has expired.")
	end)
end

function SelfiePreview:Enable2DInput()
	if self.gen2dTimeExpired or self.numGenerationsRemaining <= 0 then
		return
	end

	if self.promptFields then
		for _, child in pairs(self.promptFields) do
			if child:IsA("TextBox") then
				child.TextEditable = true
				child.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end

	if self.blockerOverlay2d then
		self.blockerOverlay2d.Visible = false
	end
end

function SelfiePreview:HasPromptError()
	if not self.promptErrorFrames then
		return false
	end
	for _, promptErrorFrame in self.promptErrorFrames do
		if promptErrorFrame.Visible then
			return true
		end
	end
	return false
end

function SelfiePreview:DisableGenerate2DButton()
	self.generate2DButton.Active = false
	self.generate2DButton.AutoButtonColor = false
	self.generate2DButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	self.generate2DButton.BackgroundTransparency = 0
	self.generate2DButton.TextColor3 = Color3.fromRGB(57, 59, 61)
end

function SelfiePreview:EnableGenerate2DButton()
	if self.gen2dTimeExpired or self.numGenerationsRemaining <= 0 then
		return
	end

	-- if the 3d button is active, then the 2d button should be secondary (different color)
	if self.generate3DButton.Active then
		self.generate2DButton.Active = true
		self.generate2DButton.AutoButtonColor = true
		self.generate2DButton.BackgroundColor3 = Color3.fromHex("#D0D9FB")
		self.generate2DButton.BackgroundTransparency = 0.88
		self.generate2DButton.TextColor3 = COLOR_WHITE
	else
		self.generate2DButton.Active = true
		self.generate2DButton.AutoButtonColor = true
		self.generate2DButton.BackgroundColor3 = COLOR_ACTION
		self.generate2DButton.BackgroundTransparency = 0
		self.generate2DButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

function SelfiePreview:UpdateGenerate2DButton()
	if self:HasPromptError() then
		self:DisableGenerate2DButton()
	else
		self:EnableGenerate2DButton()
	end
end

function SelfiePreview:DisableGenerate3DButton()
	self.generate3DButton.Active = false
	self.generate3DButton.AutoButtonColor = false
	self.generate3DButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	self.generate3DButton.TextColor3 = Color3.fromRGB(57, 59, 61)
end

function SelfiePreview:EnableGenerate3DButton()
	if self.gen3dTimeExpired then
		return
	end

	self.generate3DButton.Active = true
	self.generate3DButton.AutoButtonColor = true
	self.generate3DButton.BackgroundColor3 = COLOR_ACTION
	self.generate3DButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end

function SelfiePreview:SetupEventListeners()
	self.generate2DButton.Activated:Connect(function()
		self:Start2dLoadingAnimation()

		self:DisableGenerate2DButton()
		self:DisableGenerate3DButton()
		self.CreationManager:OnClickedGenerate2d()

		-- Record identity for reporting
		self.lastInputIdentity = self.selectedPhotoData.Identity
		self.lastInputImageId = self.selectedPhotoData.Image
	end)
	self.generate3DButton.Activated:Connect(function()
		self.blockerPanel.Visible = true
		self.gen3DAlertScreenGui.Enabled = true
	end)

	EquipModelEvent.Event:Connect(function(modelName)
		self:Hide(EndSessionReason.EquipModel)
	end)

	-- Error param is Enum.AvatarGenerationError
	ImageFailedEvent.OnClientEvent:Connect(function(error)
		self:Stop2dLoadingAnimation()

		self:UpdateGenerate2DButton()
		self:DisableGenerate3DButton()

		-- Show some red text to indicate that the image failed to generate
		self.genHelpText.Visible = true
		self.genHelpText.Text = ERROR_TEXT
		self.genHelpText.TextColor3 = ERROR_COLOR
	end)
end

function SelfiePreview:Hide(endSessionReason)
	self.blockerPanel.Visible = false
	self.gen3DAlertScreenGui.Enabled = false
	self.screenGui.Enabled = false

	-- Nil out the gen time
	self.genEndTime = nil

	self.CreationManager:OnCloseSelfiePreview()
end

return SelfiePreview
