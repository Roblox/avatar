-- A module for displaying the queueing UI to the player

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local AllowEnterQueueEvent = Events:WaitForChild("AllowEnterQueueEvent")
local QueueProgressEvent = Events:WaitForChild("QueueProgressEvent")
local SetupUIEvent = Events:WaitForChild("SetupUIEvent")

local UIUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIUtils"))

local TEXT_FONT = Enum.Font.GothamSemibold

local BACKGROUND_TRANSPARENCY = 0.1
local COLOR_BACKGROUND = Color3.fromHex("#191A1F")
local COLOR_ACTION = Color3.fromHex("#335FFF")

local QueueingUI = {}
QueueingUI.__index = QueueingUI

function QueueingUI.new()
	local self = {}
	setmetatable(self, QueueingUI)

	self:SetupQueueingUI()

	QueueProgressEvent.OnClientEvent:Connect(function(waitTimeSeconds)
		-- If we're already in the queue, ignore this
		-- This shouldn't happen (there's a check in QueueManager to prevent this)
		if self.queuePanel.Visible or self.queueCompletePanel.Visible then
			warn("QueueProgressEvent received while already in queue")
			return
		end

		self:ShowProgress()
		for t = waitTimeSeconds, 1, -1 do
			local roundedTime = math.round(t) -- floating point errors were causing this to sometimes display as "31.9999999"
			self:SetProgressText("Wait Time: " .. roundedTime .. " seconds")
			wait(1)
		end
		self:HideProgress()
		self:ShowQueueComplete()
	end)

	return self
end

function QueueingUI:SetupQueueingUI()
	-- A screen gui parent
	self.queueingGui = Instance.new("ScreenGui")
	self.queueingGui.Name = "QueueingGui"
	self.queueingGui.Parent = game.Players.LocalPlayer.PlayerGui
	self.queueingGui.DisplayOrder = 10
	self.queueingGui.ResetOnSpawn = false

	-- A panel that appears in the top-middle of the screen and displays a text message (and maybe queue position/estimated wait time?)
	-- The purpose of this UI is to let the player know that they are waiting in a queue

	self.queuePanel = Instance.new("Frame")
	self.queuePanel.Name = "QueuePanel"
	self.queuePanel.Size = UDim2.new(0, 350, 0, 50)
	self.queuePanel.AnchorPoint = Vector2.new(0.5, 0)
	self.queuePanel.Position = UDim2.new(0.5, 0, 0, 0)
	self.queuePanel.BackgroundColor3 = COLOR_BACKGROUND
	self.queuePanel.BackgroundTransparency = BACKGROUND_TRANSPARENCY
	self.queuePanel.Parent = self.queueingGui
	UIUtils.AddUICorner(self.queuePanel, 10)

	self.progressText = Instance.new("TextLabel")
	self.progressText.Size = UDim2.new(0.5, -10, 1, -10)
	self.progressText.Position = UDim2.new(0, 10, 0, 5)
	self.progressText.Text = "You're up next"
	self.progressText.TextXAlignment = Enum.TextXAlignment.Left
	self.progressText.TextSize = 14
	self.progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.progressText.Font = TEXT_FONT
	self.progressText.BackgroundTransparency = 1
	self.progressText.Parent = self.queuePanel

	-- A button that becomes active when the player is at the front of the queue
	self.enterButton = Instance.new("TextButton")
	self.enterButton.Size = UDim2.new(0.5, -10, 1, -10)
	self.enterButton.AnchorPoint = Vector2.new(1, 0)
	self.enterButton.Position = UDim2.new(1, -5, 0, 5)
	self.enterButton.BackgroundTransparency = 0
	self.enterButton.Text = "Enter Avatar Creator"
	self.enterButton.TextSize = 14
	self.enterButton.Font = TEXT_FONT
	self.enterButton.Parent = self.queuePanel
	UIUtils.AddUICorner(self.enterButton, 10)
	self:DisableEnterButton()

	self.queuePanel.Visible = false

	-- A different panel for when the player is at the front of the queue
	self.queueCompletePanel = Instance.new("Frame")
	self.queueCompletePanel.Name = "QueueCompletePanel"
	self.queueCompletePanel.Size = UDim2.new(0, 300, 0, 110)
	self.queueCompletePanel.AnchorPoint = Vector2.new(0.5, 0)
	self.queueCompletePanel.Position = UDim2.new(0.5, 0, 0, 0)
	self.queueCompletePanel.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
	self.queueCompletePanel.BackgroundTransparency = 0
	self.queueCompletePanel.Parent = self.queueingGui
	UIUtils.AddUICorner(self.queueCompletePanel, 10)

	local queueCompleteText = Instance.new("TextLabel")
	queueCompleteText.Size = UDim2.new(1, -20, 0, 30)
	queueCompleteText.Position = UDim2.new(0, 10, 0, 5)
	queueCompleteText.Text = "It's your turn"
	queueCompleteText.TextXAlignment = Enum.TextXAlignment.Left
	queueCompleteText.TextSize = 16
	queueCompleteText.TextColor3 = Color3.new(1, 1, 1)
	queueCompleteText.Font = TEXT_FONT
	queueCompleteText.BackgroundTransparency = 1
	queueCompleteText.Parent = self.queueCompletePanel

	self.queueCompleteSubtext = Instance.new("TextLabel")
	self.queueCompleteSubtext.Size = UDim2.new(1, -20, 0, 30)
	self.queueCompleteSubtext.Position = UDim2.new(0, 10, 0, 30)
	self.queueCompleteSubtext.Text = "1:00 to enter before losing your spot"
	self.queueCompleteSubtext.TextXAlignment = Enum.TextXAlignment.Left
	self.queueCompleteSubtext.TextSize = 14
	self.queueCompleteSubtext.TextColor3 = Color3.new(1, 1, 1)
	self.queueCompleteSubtext.Font = TEXT_FONT
	self.queueCompleteSubtext.BackgroundTransparency = 1
	self.queueCompleteSubtext.Parent = self.queueCompletePanel

	local enterButton = Instance.new("TextButton")
	enterButton.Size = UDim2.new(1, -20, 0, 40)
	enterButton.AnchorPoint = Vector2.new(0, 1)
	enterButton.Position = UDim2.new(0, 10, 1, -10)
	enterButton.BackgroundTransparency = 0
	enterButton.BackgroundColor3 = COLOR_ACTION
	enterButton.Text = "Enter Avatar Creator"
	enterButton.TextSize = 14
	enterButton.TextColor3 = Color3.new(1, 1, 1)
	enterButton.Font = TEXT_FONT
	enterButton.Parent = self.queueCompletePanel
	UIUtils.AddUICorner(enterButton, 10)
	enterButton.MouseButton1Click:Connect(function()
		-- Close the panel
		self.queueCompletePanel.Visible = false

		SetupUIEvent:Fire()
	end)

	self.queueCompletePanel.Visible = false
end

function QueueingUI:ShowProgress()
	self.queuePanel.Visible = true
end

function QueueingUI:HideProgress()
	self.queuePanel.Visible = false
end

function QueueingUI:ShowQueueComplete()
	self.queueCompletePanel.Visible = true

	-- Update the subtext with the countdown in the format X:xx
	local countdown = 60
	self.queueCompleteSubtext.Text = ""
	while countdown > 0 do
		countdown = countdown - 1
		self.queueCompleteSubtext.Text = "0:" .. string.format("%02d to enter before losing your spot", countdown)
		wait(1)

		-- When the countdown reaches 0, hide the panel
		if countdown == 0 then
			self.queueCompletePanel.Visible = false

			-- Allow the player to re-enter the queue
			AllowEnterQueueEvent:FireServer()
		end
	end
end

function QueueingUI:DisableEnterButton()
	self.enterButton.Active = false
	self.enterButton.AutoButtonColor = false
	self.enterButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	self.enterButton.TextColor3 = Color3.fromRGB(57, 59, 61)
end

function QueueingUI:SetProgressText(progressText)
	self.progressText.Text = progressText
end

return QueueingUI
