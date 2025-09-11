-- A manager for displaying the progress of 3d model generation while the player is in the experience.
-- This is separate from the SelfiePreview because it is displayed independant of the BaseUI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")

local EquipModelEvent = Events:WaitForChild("EquipModelEvent")
local ModelGeneratedEvent = Events:WaitForChild("ModelGeneratedEvent")
local ModelProgressUpdateEvent = Events:WaitForChild("ModelProgressUpdateEvent")
local OpenAvatarEditorEvent = Events:WaitForChild("OpenAvatarEditorEvent")
local ProgressSpinner = require(Modules:WaitForChild("ProgressSpinner"))
local UIUtils = require(Modules:WaitForChild("UIUtils"))

local TEXT_FONT = Enum.Font.GothamSemibold
local BACKGROUND_TRANSPARENCY = 0.1
local COLOR_ACTION = Color3.fromHex("#335FFF")
local COLOR_BACKGROUND = Color3.fromHex("#191A1F")
local COLOR_ERROR = Color3.fromRGB(200, 0, 0)
local COLOR_WHITE = Color3.fromHex("#F7F7F8")

local ProgressUI = {}
ProgressUI.__index = ProgressUI

function ProgressUI.new()
	local self = {}
	setmetatable(self, ProgressUI)

	self:SetupProgressUI()

	ModelProgressUpdateEvent.OnClientEvent:Connect(function(progress)
		if progress ~= -1 then
			self:ShowProgress()
		else
			self:ShowError()
		end
	end)

	ModelGeneratedEvent.OnClientEvent:Connect(function(modelName)
		self.modelName = modelName

		self:ShowModelReady()
	end)

	OpenAvatarEditorEvent.Event:Connect(function()
		self:HideProgress()
	end)

	return self
end

function ProgressUI:SetupProgressUI()
	-- A screen gui parent
	self.progressGui = Instance.new("ScreenGui")
	self.progressGui.Name = "ProgressGui"
	self.progressGui.Parent = game.Players.LocalPlayer.PlayerGui
	self.progressGui.DisplayOrder = 10
	self.progressGui.ResetOnSpawn = false

	-- A panel that appears in the top-right of the screen and displays a text message (and maybe estimated wait time?)
	-- The purpose of this UI is to let the player know that the 3D model is still being generated

	self.progressPanel = Instance.new("Frame")
	self.progressPanel.Size = UDim2.fromOffset(300, 0)
	self.progressPanel.AutomaticSize = Enum.AutomaticSize.Y
	self.progressPanel.AnchorPoint = Vector2.new(1, 0)
	self.progressPanel.Position = UDim2.new(1, -20, 0, 0)
	self.progressPanel.BackgroundColor3 = COLOR_BACKGROUND
	self.progressPanel.BackgroundTransparency = BACKGROUND_TRANSPARENCY
	self.progressPanel.Parent = self.progressGui
	UIUtils.AddUICorner(self.progressPanel, 10)
	UIUtils.AddUIPadding(self.progressPanel, 12)

	local layout = UIUtils.AddListLayout(self.progressPanel, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	self.progressText = Instance.new("TextLabel")
	self.progressText.Name = "ProgressText"
	self.progressText.Size = UDim2.new(1, -20, 0, 30)
	self.progressText.Position = UDim2.new(0, 10, 0, 10)
	self.progressText.TextXAlignment = Enum.TextXAlignment.Left
	self.progressText.TextSize = 14
	self.progressText.TextColor3 = COLOR_WHITE
	self.progressText.Font = TEXT_FONT
	self.progressText.BackgroundTransparency = 1
	self.progressText.LayoutOrder = 1
	self.progressText.Parent = self.progressPanel

	self.progressSpinner = ProgressSpinner.new(self.progressPanel, 2)

	-- A button that appears on the progress panel when the 3D model is ready
	-- User can click this button to equip the 3D model
	self.viewButton = Instance.new("TextButton")
	self.viewButton.Name = "ViewButton"
	self.viewButton.Size = UDim2.new(1, -20, 0, 40)
	self.viewButton.AnchorPoint = Vector2.new(0, 1)
	self.viewButton.Position = UDim2.new(0, 10, 1, -10)
	self.viewButton.BackgroundColor3 = COLOR_ACTION
	self.viewButton.BackgroundTransparency = 0
	self.viewButton.Text = "View"
	self.viewButton.TextSize = 14
	self.viewButton.TextColor3 = Color3.new(1, 1, 1)
	self.viewButton.Font = TEXT_FONT
	self.viewButton.Parent = self.progressPanel
	self.viewButton.LayoutOrder = 2
	UIUtils.AddUICorner(self.viewButton, 10)

	self.viewButton.MouseButton1Click:Connect(function()
		self:HideProgress()
		EquipModelEvent:Fire(self.modelName)
	end)

	-- A button that appears when the 3D model job fails
	self.errorButton = Instance.new("TextButton")
	self.errorButton.Name = "ErrorButton"
	self.errorButton.Size = UDim2.new(1, -20, 0, 40)
	self.errorButton.AnchorPoint = Vector2.new(0, 1)
	self.errorButton.Position = UDim2.new(0, 10, 1, -10)
	self.errorButton.BackgroundColor3 = COLOR_ERROR
	self.errorButton.BackgroundTransparency = 0
	self.errorButton.Text = "OK"
	self.errorButton.TextSize = 14
	self.errorButton.TextColor3 = Color3.new(1, 1, 1)
	self.errorButton.Font = TEXT_FONT
	self.errorButton.Parent = self.progressPanel
	self.errorButton.LayoutOrder = 2
	UIUtils.AddUICorner(self.errorButton, 10)

	self.errorButton.MouseButton1Click:Connect(function()
		self:HideProgress()
	end)

	self.progressPanel.Visible = false
end

function ProgressUI:ShowProgress()
	self:SetProgressText("Creating your Avatar")
	self.progressPanel.Visible = true
	self.progressSpinner:Show()
	self.viewButton.Visible = false
	self.errorButton.Visible = false
end

function ProgressUI:ShowModelReady()
	self:SetProgressText("Your avatar head is ready!")
	self.progressPanel.Visible = true
	self.progressSpinner:Hide()
	self.viewButton.Visible = true
	self.errorButton.Visible = false
end

function ProgressUI:ShowError()
	self:SetProgressText("Error generating 3D model")
	self.progressPanel.Visible = true
	self.progressSpinner:Hide()
	self.viewButton.Visible = false
	self.errorButton.Visible = true
end

function ProgressUI:HideProgress()
	self.progressPanel.Visible = false
end

function ProgressUI:SetProgressText(progressText)
	self.progressText.Text = progressText
end

return ProgressUI
