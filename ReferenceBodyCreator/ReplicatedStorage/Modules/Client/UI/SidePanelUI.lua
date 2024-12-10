local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local UIConstants = require(UI:WaitForChild("UIConstants"))

local SidePanelUI = {}

function SidePanelUI.CreateButton(text, imageAssetId, imageAspectRatio)
	if not imageAspectRatio then
		imageAspectRatio = 1
	end

	local newButton = Instance.new("ImageButton")
	newButton.Name = text
	newButton.Size = UDim2.fromOffset(UIConstants.LeftBarButtonSize, UIConstants.LeftBarButtonSize * imageAspectRatio)
	newButton.BackgroundTransparency = 1

	-- Create an ImageLabel and TextLabel
	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.Image = imageAssetId
	ImageLabel.Size = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
	ImageLabel.Position = UDim2.new(0.5, 0, 0, 10)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Parent = newButton

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Text = text
	TextLabel.AnchorPoint = Vector2.new(0.5, 0)
	TextLabel.Position = UDim2.new(0.5, 0, 0, 44)
	TextLabel.Size = UDim2.new(1, 0, 0, 14)
	TextLabel.TextXAlignment = Enum.TextXAlignment.Center
	TextLabel.TextYAlignment = Enum.TextYAlignment.Center
	TextLabel.FontFace = Enum.Font.SourceSans
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextSize = 14
	TextLabel.Parent = newButton

	return newButton
end

function SidePanelUI.CreateSidePanel()
	local SidePanel = Instance.new("Frame")
	SidePanel.Name = "SidePanel"
	SidePanel.AutomaticSize = Enum.AutomaticSize.Y
	SidePanel.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	SidePanel.Position = UDim2.fromOffset(0, 0)
	SidePanel.BackgroundTransparency = 0
	SidePanel.BackgroundColor3 = UIConstants.BGColor

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, UIConstants.BarCornerRadius)
	UICorner.Parent = SidePanel

	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.FillDirection = Enum.FillDirection.Vertical
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, UIConstants.LeftBarButtonPadding)
	ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ButtonLayout.Parent = SidePanel

	return SidePanel
end

return SidePanelUI
