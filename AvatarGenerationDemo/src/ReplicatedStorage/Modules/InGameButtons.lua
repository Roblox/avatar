local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local UIUtils = require(Modules:WaitForChild("UIUtils"))

local TEXT_FONT = Enum.Font.GothamSemibold

local InGameButtons = {}
InGameButtons.__index = InGameButtons

function InGameButtons.new(creationManager)
	local self = {}
	setmetatable(self, InGameButtons)

	self.creationManager = creationManager
	self:CreateInGameButtons()

	return self
end

function InGameButtons:CreateInGameButton(name, text, backgroundColor)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 1)
	button.Size = UDim2.new(0, 200, 0, 50)
	button.Text = text
	button.TextSize = 20
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = TEXT_FONT
	button.BackgroundColor3 = backgroundColor
	button.Visible = false
	UIUtils.AddUICorner(button, 10)
	return button
end

function InGameButtons:CreateInGameButtons()
	local inGameButtonsGui = Instance.new("ScreenGui")
	inGameButtonsGui.Name = "AvatarEditorEditPublishGui"
	inGameButtonsGui.Parent = game.Players.LocalPlayer.PlayerGui
	inGameButtonsGui.ResetOnSpawn = false

	local inGameButtonsFrame = Instance.new("Frame")
	inGameButtonsFrame.Name = "EditPublishFrame"
	inGameButtonsFrame.AutomaticSize = Enum.AutomaticSize.XY
	inGameButtonsFrame.Position = UDim2.new(1, -20, 1, -20)
	inGameButtonsFrame.AnchorPoint = Vector2.new(1, 1)
	inGameButtonsFrame.Parent = inGameButtonsGui
	inGameButtonsFrame.BackgroundTransparency = 1

	local inGameButtonsGridLayout = Instance.new("UIGridLayout")
	inGameButtonsGridLayout.Parent = inGameButtonsFrame
	inGameButtonsGridLayout.FillDirection = Enum.FillDirection.Vertical
	inGameButtonsGridLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	inGameButtonsGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	inGameButtonsGridLayout.FillDirectionMaxCells = 0
	inGameButtonsGridLayout.CellSize = UDim2.new(0, 200, 0, 50)
	inGameButtonsGridLayout.CellPadding = UDim2.fromOffset(5, 5)
	inGameButtonsGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	self.toggleButton = self:CreateInGameButton("AvatarEditorButton", "Avatar Editor", Color3.fromHex("#121215"))
	self.toggleButton.BackgroundTransparency = 0.08
	self.toggleButton.Parent = inGameButtonsFrame

	self.toggleButton.Activated:Connect(function()
		self.creationManager:OpenAvatarEditor()
	end)

	self.publishButton = self:CreateInGameButton("PublishAvatarButton", "Publish Avatar", Color3.fromRGB(7, 170, 43))
	self.publishButton.Parent = inGameButtonsFrame

	self.publishButton.Activated:Connect(function()
		self.creationManager:PublishAvatar()
	end)
end

function InGameButtons:SetToggleButtonVisibility(visible)
	self.toggleButton.Visible = visible
end

function InGameButtons:SetPublishButtonVisibility(visible)
	self.publishButton.Visible = visible
end

return InGameButtons
