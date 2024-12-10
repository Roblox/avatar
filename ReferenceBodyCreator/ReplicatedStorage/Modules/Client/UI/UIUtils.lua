local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local UIConstants = require(UI:WaitForChild("UIConstants"))

local TEXT_FONT = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold)
local BUTTON_BLUE_COLOR = Color3.fromHex("335FFF")
local BUTTON_PADDING = 5

local UIUtils = {}

-- Adds a UICorner to the element that is passed in.
UIUtils.AddUICorner = function(element, radiusPixels, radiusPercent)
	local UICorner = Instance.new("UICorner")
	if radiusPixels == nil then
		radiusPixels = 0
	end
	if radiusPercent == nil then
		radiusPercent = 0
	end
	UICorner.CornerRadius = UDim.new(radiusPercent, radiusPixels)
	UICorner.Parent = element
end

UIUtils.CreateLeftSideBar = function()
	local leftSideBar = Instance.new("Frame")
	leftSideBar.Name = "LeftSideBar"
	leftSideBar.Position = UDim2.new()
	leftSideBar.BackgroundTransparency = 0
	leftSideBar.BackgroundColor3 = UIConstants.BGColor
	leftSideBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	leftSideBar.AutomaticSize = Enum.AutomaticSize.Y

	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.FillDirection = Enum.FillDirection.Vertical
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, UIConstants.LeftBarButtonPadding)
	ButtonLayout.Parent = leftSideBar
	ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder

	UIUtils.AddUICorner(leftSideBar, UIConstants.BarCornerRadius)

	return leftSideBar
end

UIUtils.CreateSideBarButton = function(name, imageAssetIdOff, imageAssetIdOn)
	local newButton = Instance.new("ImageButton")
	newButton.Name = name
	newButton.Size = UDim2.fromOffset(UIConstants.LeftBarButtonSize, UIConstants.LeftBarButtonSize)
	newButton.BackgroundTransparency = 1

	-- Create an ImageLabel and TextLabel
	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.Image = imageAssetIdOff
	ImageLabel.Size = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
	ImageLabel.Position = UDim2.new(0.5, 0, 0, 10)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Parent = newButton

	local valueOff = Instance.new("StringValue")
	valueOff.Name = "Off"
	valueOff.Value = imageAssetIdOff
	valueOff.Parent = newButton

	if imageAssetIdOn then
		local valueOn = Instance.new("StringValue")
		valueOn.Name = "On"
		valueOn.Value = imageAssetIdOn
		valueOn.Parent = newButton
	end

	return newButton
end

-- button background that appears when the button is selected
-- hideTopCorners is true if it has corners in the bottom and not the top
UIUtils.AddButtonBackground = function(parent, cornerRadius: UDim?, hideTopCorners: boolean?, isVisible: boolean?)
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Size = UDim2.fromScale(1, 1)
	backgroundFrame.BackgroundColor3 = UIConstants.BackButtonBGColor
	backgroundFrame.BorderSizePixel = 0
	backgroundFrame.ZIndex = 0
	backgroundFrame.Name = "ButtonBackgroundFrame"
	if isVisible ~= nil then
		backgroundFrame.Visible = isVisible
	end

	if cornerRadius then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = backgroundFrame
		if hideTopCorners then
			local hideCornersFrame = Instance.new("Frame")
			hideCornersFrame.Size = UDim2.fromScale(1, 0.5)
			hideCornersFrame.BackgroundColor3 = UIConstants.BackButtonBGColor
			hideCornersFrame.ZIndex = 0
			hideCornersFrame.Name = "HideCornersFrame"
			hideCornersFrame.BorderSizePixel = 0
			hideCornersFrame.Parent = backgroundFrame
		end
	end
	backgroundFrame.Parent = parent
end

-- Change Button Background to hide corners
UIUtils.ChangeButtonBackgroundCorner = function(parent, newCornerRadius, hideTopCornersVisible)
	local backgroundFrame = parent:FindFirstChild("ButtonBackgroundFrame")
	if not backgroundFrame then
		warn("No button background frame found")
		return
	end

	local uiCorner = backgroundFrame:FindFirstChild("UICorner")
	if not uiCorner then
		warn("No UICorner found")
		return
	end

	uiCorner.CornerRadius = newCornerRadius

	if hideTopCornersVisible ~= nil then
		local hideCornersFrame = backgroundFrame:FindFirstChild("HideCornersFrame")
		if not hideCornersFrame then
			warn("No HideCornersFrame found")
			return
		end
		hideCornersFrame.Visible = hideTopCornersVisible
	end
end

-- Creates a generic "go back" button with an arrow pointing to the left.
UIUtils.CreateBackButton = function()
	local backButton = Instance.new("ImageButton")
	backButton.Size = UDim2.fromOffset(UIConstants.LeftBarButtonSize, UIConstants.LeftBarButtonSize)
	backButton.BackgroundTransparency = 1
	backButton.LayoutOrder = 1

	local backIcon = Instance.new("ImageLabel")
	backIcon.Size = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
	backIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	backIcon.Position = UDim2.fromScale(0.5, 0.5)
	backIcon.BackgroundTransparency = 1
	backIcon.Parent = backButton
	backIcon.Image = "rbxassetid://78693146296304"

	UIUtils.AddButtonBackground(backButton, UDim.new(1, 0), false)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingRight = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingLeft = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingBottom = UDim.new(0, BUTTON_PADDING)
	uiPadding.Parent = backButton

	return backButton
end

-- Creates a generic "close" button.
UIUtils.CreateCloseButton = function(buttonSize)
	local closeButton = Instance.new("ImageButton")
	closeButton.Size = UDim2.fromOffset(buttonSize, buttonSize)
	closeButton.BackgroundTransparency = 1
	closeButton.LayoutOrder = 1

	local closeIcon = Instance.new("ImageLabel")
	closeIcon.Size = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	closeIcon.BackgroundTransparency = 1
	closeIcon.Parent = closeButton
	closeIcon.Image = "rbxassetid://72013784847925"

	UIUtils.AddButtonBackground(closeButton, UDim.new(1, 0), false)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingRight = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingLeft = UDim.new(0, BUTTON_PADDING)
	uiPadding.PaddingBottom = UDim.new(0, BUTTON_PADDING)
	uiPadding.Parent = closeButton

	return closeButton
end

UIUtils.CreateBuyButton = function(onClick, parent)
	local BuyButton = Instance.new("TextButton")
	BuyButton.Name = "BuyButton"
	BuyButton.AnchorPoint = Vector2.new(1, 1)
	BuyButton.Position = UDim2.new(1, -20, 1, -20)
	BuyButton.Size = UDim2.fromOffset(150, 50)
	BuyButton.Text = "Publish"
	BuyButton.TextSize = 18
	BuyButton.FontFace = TEXT_FONT
	BuyButton.BackgroundColor3 = BUTTON_BLUE_COLOR
	BuyButton.TextColor3 = Color3.new(1, 1, 1)
	BuyButton.BackgroundTransparency = 0

	UIUtils.AddUICorner(BuyButton, UIConstants.PanelCornerRadius)
	BuyButton.MouseButton1Click:Connect(onClick)
	BuyButton.Parent = parent
end

-- utility to set button appearance for on and off state
UIUtils.SetButtonState = function(button, isOn)
	local backgroundFrame = button:FindFirstChild("ButtonBackgroundFrame")
	if backgroundFrame then
		backgroundFrame.Visible = isOn
	end
	local imageLabel = button:FindFirstChild("ImageLabel")
	imageLabel.Image = isOn and button:FindFirstChild("On").Value or button:FindFirstChild("Off").Value
end

-- sets image of the buttons used in sidebars
UIUtils.SetButtonImage = function(button, isVisible)
	local backgroundFrame = button:FindFirstChild("ButtonBackgroundFrame")
	if backgroundFrame then
		backgroundFrame.Visible = isVisible
	end
end

return UIUtils
