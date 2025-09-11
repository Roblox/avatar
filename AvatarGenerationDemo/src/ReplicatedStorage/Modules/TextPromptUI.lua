-- A module for displaying the queueing UI to the player

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIUtils"))

local TEXT_FONT = Enum.Font.GothamSemibold
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_ACTION = Color3.fromHex("#335FFF")
local COLOR_DIALOG_BG = Color3.fromRGB(57, 59, 61)
local COLOR_DIALOG_DIVIDER = Color3.fromRGB(101, 102, 104)

local TextPromptUI = {}
TextPromptUI.__index = TextPromptUI

function TextPromptUI.new()
	local self = {}
	setmetatable(self, TextPromptUI)

	self:SetupTextPromptUI()

	return self
end

function TextPromptUI:SetupTextPromptUI()
	-- A screen gui parent
	self.textPromptGui = Instance.new("ScreenGui")
	self.textPromptGui.Name = "TextPromptGui"
	self.textPromptGui.DisplayOrder = 10
	self.textPromptGui.ResetOnSpawn = false
	self.textPromptGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	self.textPromptGui.ScreenInsets = Enum.ScreenInsets.None
	self.textPromptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.textPromptGui.Parent = game.Players.LocalPlayer.PlayerGui

	-- A panel that appears in the top-middle of the screen and displays a text message (and maybe queue position/estimated wait time?)
	-- The purpose of this UI is to let the player know that they are waiting in a queue
	--
	self.textPromptPanel = Instance.new("Frame")
	self.textPromptPanel.Name = "TextPromptPanel"
	self.textPromptPanel.Size = UDim2.fromOffset(480, 0)
	self.textPromptPanel.AutomaticSize = Enum.AutomaticSize.Y
	self.textPromptPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.textPromptPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	self.textPromptPanel.BackgroundColor3 = COLOR_DIALOG_BG
	self.textPromptPanel.ZIndex = 2
	self.textPromptPanel.Visible = false
	self.textPromptPanel.Parent = self.textPromptGui
	UIUtils.AddUICorner(self.textPromptPanel)

	local panelPadding = Instance.new("UIPadding")
	panelPadding.PaddingBottom = UDim.new(0, 10)
	panelPadding.PaddingTop = UDim.new(0, 10)
	panelPadding.PaddingLeft = UDim.new(0, 24)
	panelPadding.PaddingRight = UDim.new(0, 24)
	panelPadding.Parent = self.textPromptPanel

	local listLayout = UIUtils.AddListLayout(self.textPromptPanel, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TextPromptTitleFrame"
	titleFrame.BackgroundTransparency = 1
	titleFrame.Size = UDim2.new(1, 0, 0, 38)
	titleFrame.Parent = self.textPromptPanel

	local title = Instance.new("TextLabel")
	title.Name = "TextPromptTitle"
	title.Text = "Add Optional Descriptives"
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

	local description = Instance.new("TextLabel")
	description.Name = "TextPromptDescription"
	description.Text = "Add an optional description to add a style influence"
	description.Size = UDim2.new(1, 0, 0, 0)
	description.AutomaticSize = Enum.AutomaticSize.Y
	description.BackgroundTransparency = 1
	description.Font = TEXT_FONT
	description.TextSize = 16
	description.TextColor3 = Color3.new(0.853529, 0.857145, 0.867979)
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextWrapped = true
	description.BorderSizePixel = 0
	description.LayoutOrder = 2
	description.Parent = self.textPromptPanel

	local inputDescription = Instance.new("TextLabel")
	inputDescription.Name = "InputDescription"
	inputDescription.Text = "Description"
	inputDescription.Size = UDim2.new(1, 0, 0, 0)
	inputDescription.AutomaticSize = Enum.AutomaticSize.Y
	inputDescription.BackgroundTransparency = 1
	inputDescription.Font = TEXT_FONT
	inputDescription.TextSize = 16
	inputDescription.TextColor3 = COLOR_WHITE
	inputDescription.TextXAlignment = Enum.TextXAlignment.Left
	inputDescription.LayoutOrder = 3
	inputDescription.Parent = self.textPromptPanel

	self.textPromptTextBox = Instance.new("TextBox")
	self.textPromptTextBox.Name = "TextPromptTextBox"
	self.textPromptTextBox.Text = ""
	self.textPromptTextBox.Size = UDim2.new(1, 0, 0, 40)
	self.textPromptTextBox.Position = UDim2.new(0, 0, 0, 0)
	self.textPromptTextBox.BackgroundColor3 = COLOR_DIALOG_BG
	self.textPromptTextBox.Font = TEXT_FONT
	self.textPromptTextBox.TextSize = 20
	self.textPromptTextBox.TextColor3 = COLOR_WHITE
	self.textPromptTextBox.TextXAlignment = Enum.TextXAlignment.Left
	self.textPromptTextBox.LayoutOrder = 4
	self.textPromptTextBox.Parent = self.textPromptPanel
	UIUtils.AddUICorner(self.textPromptTextBox, 8)

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Color = Color3.fromHex("#D0D9FB")
	uiStroke.Transparency = 0.6
	uiStroke.Thickness = 1
	uiStroke.Parent = self.textPromptTextBox

	local buttonPanel = Instance.new("Frame")
	buttonPanel.Name = "ButtonPanel"
	buttonPanel.Size = UDim2.new(1, 0, 0, 40)
	buttonPanel.BackgroundTransparency = 1
	buttonPanel.LayoutOrder = 5
	buttonPanel.Parent = self.textPromptPanel

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.Parent = buttonPanel
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	buttonLayout.Padding = UDim.new(0, 16)

	self.textPromptButton = Instance.new("TextButton")
	self.textPromptButton.Name = "TextPromptButton"
	self.textPromptButton.Size = UDim2.new(0.5, -8, 0, 40)
	self.textPromptButton.Position = UDim2.new(0, 0, 0, 0)
	self.textPromptButton.AnchorPoint = Vector2.new(0, 0)
	self.textPromptButton.BackgroundColor3 = COLOR_ACTION
	self.textPromptButton.Text = "Generate Preview"
	self.textPromptButton.Font = TEXT_FONT
	self.textPromptButton.TextSize = 16
	self.textPromptButton.TextColor3 = COLOR_WHITE
	self.textPromptButton.Parent = buttonPanel
	UIUtils.AddUICorner(self.textPromptButton, 10)

	self.textPromptButton.Activated:Connect(function()
		self.textPromptPanel.Visible = false
	end)
end

return TextPromptUI
