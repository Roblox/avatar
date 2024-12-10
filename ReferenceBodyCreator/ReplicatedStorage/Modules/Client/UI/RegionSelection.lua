local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local UIConstants = require(UI:WaitForChild("UIConstants"))
local UIUtils = require(UI:WaitForChild("UIUtils"))

local RegionSelection = {}
RegionSelection.__index = RegionSelection

local PADDING = 22

-- the types of buttons
local ButtonType = {
	All = "All",
	Hair = "Hair",
	Head = "Head",
	Torso = "Torso",
	LeftLeg = "LeftLeg",
	LeftArm = "LeftArm",
	RightLeg = "RightLeg",
	RightArm = "RightArm",
}

local buttonIcons = {
	[ButtonType.All] = {
		Off = "rbxassetid://119065236297406",
		On = "rbxassetid://84142408471305",
	},
	[ButtonType.Hair] = {
		Off = "rbxassetid://95798547148674",
		On = "rbxassetid://74901575480062",
	},
	[ButtonType.Head] = {
		Off = "rbxassetid://89986272144373",
		On = "rbxassetid://82623401102755",
	},
	[ButtonType.RightArm] = {
		Off = "rbxassetid://111127742394707",
		On = "rbxassetid://93352960864033",
	},
	[ButtonType.LeftArm] = {
		Off = "rbxassetid://128636755241482",
		On = "rbxassetid://70826259009886",
	},
	[ButtonType.Torso] = {
		Off = "rbxassetid://136402258892124",
		On = "rbxassetid://91149579869310",
	},
	[ButtonType.RightLeg] = {
		Off = "rbxassetid://104749544073822",
		On = "rbxassetid://106814678568045",
	},
	[ButtonType.LeftLeg] = {
		Off = "rbxassetid://122325074883131",
		On = "rbxassetid://116773960442028",
	},
}

local buttonOrder = {
	ButtonType.All,
	ButtonType.Hair,
	ButtonType.Head,
	ButtonType.LeftArm,
	ButtonType.RightArm,
	ButtonType.Torso,
	ButtonType.LeftLeg,
	ButtonType.RightLeg,
}

function RegionSelection.new(onRegionSelectedCallback)
	local self = {}
	setmetatable(self, RegionSelection)

	self.onRegionSelectedCallback = onRegionSelectedCallback

	local Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = UIConstants.BGColor
	Frame.Name = "RegionSelection"
	Frame.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.ColorPickerHeight)
	self.Frame = Frame

	local ButtonBar = Instance.new("ScrollingFrame")
	ButtonBar.Name = "ButtonBar"
	ButtonBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ButtonBar.Size = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, UIConstants.ColorPickerHeight)
	ButtonBar.CanvasSize = UDim2.new(0, UIConstants.LeftBarButtonSize, 0, 0)
	ButtonBar.ScrollBarImageTransparency = 1
	ButtonBar.ScrollBarThickness = 0
	ButtonBar.ScrollingDirection = Enum.ScrollingDirection.Y
	ButtonBar.Position = UDim2.fromOffset(0, 0)
	ButtonBar.BackgroundColor3 = UIConstants.BGColor
	ButtonBar.BackgroundTransparency = 1
	ButtonBar.Parent = self.Frame

	UIUtils.AddUICorner(Frame, UIConstants.BarCornerRadius)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0, PADDING)
	UIPadding.PaddingBottom = UDim.new(0, PADDING)
	UIPadding.PaddingLeft = UDim.new(0, PADDING)
	UIPadding.PaddingRight = UDim.new(0, PADDING)
	UIPadding.Parent = ButtonBar

	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellSize = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
	-- TODO UI needs to be scaled down on mobile to fit everything
	GridLayout.CellPadding = UDim2.fromOffset(PADDING, PADDING)
	GridLayout.Parent = ButtonBar
	GridLayout.FillDirectionMaxCells = 1
	GridLayout.FillDirection = Enum.FillDirection.Horizontal
	GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- add region selection buttons in this order
	for _i, buttonType in buttonOrder do
		local button = Instance.new("ImageButton")
		button.AutomaticSize = Enum.AutomaticSize.XY
		button.Name = buttonType
		button.Parent = ButtonBar
		button.BackgroundTransparency = 1
		button.MouseButton1Click:Connect(function()
			self:OnClick(buttonType)
		end)

		-- Create an ImageLabel and TextLabel
		local ImageLabel = Instance.new("ImageLabel")
		ImageLabel.Image = buttonIcons[buttonType].Off
		ImageLabel.Size = UDim2.fromOffset(UIConstants.ImageButtonSize, UIConstants.ImageButtonSize)
		ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
		ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Parent = button
	end
	-- initialize as all being selected

	self:OnClick(ButtonType.All)

	return self
end

function RegionSelection:OnClick(bodyPartName)
	for _i, child in self.Frame.ButtonBar:GetChildren() do
		if child:IsA("ImageButton") then
			local imageLabel = child:FindFirstChild("ImageLabel")
			if child.Name == bodyPartName then
				-- change icon if it's the clicked button
				imageLabel.Image = buttonIcons[child.Name].On
			else
				imageLabel.Image = buttonIcons[child.Name].Off
			end
		end
	end

	self.onRegionSelectedCallback(bodyPartName)
end

function RegionSelection:Open()
	self.Frame.Visible = true
end

function RegionSelection:Close()
	self.Frame.Visible = false
	-- leave the region selection with all selected
	self:OnClick(ButtonType.All)
end

return RegionSelection
