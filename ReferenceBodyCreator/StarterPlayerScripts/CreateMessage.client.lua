local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShowMessageEvent = Remotes:WaitForChild("ShowMessageEvent")

local function createMessageGui(message)
	local ScreenGui = Instance.new("ScreenGui")
	local TextLabel = Instance.new("TextLabel")
	local UICorner = Instance.new("UICorner")

	ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	ScreenGui.DisplayOrder = 10 -- Ensures this ScreenGui appears above others

	TextLabel.Size = UDim2.new(0, 400, 0, 100)
	TextLabel.Position = UDim2.new(0.5, -200, -0.2, 0) -- Start off-screen above the top
	TextLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	TextLabel.Text = message
	TextLabel.TextScaled = true
	TextLabel.Parent = ScreenGui

	-- Add rounded corners
	UICorner.CornerRadius = UDim.new(0, 15)
	UICorner.Parent = TextLabel

	-- Tween to move the TextLabel from the top to the top of the screen
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tweenGoal = { Position = UDim2.new(0.5, -200, 0, 0) }
	local tween = TweenService:Create(TextLabel, tweenInfo, tweenGoal)
	tween:Play()

	-- Optionally add a longer delay before removing the message
	wait(10)

	-- Tween to move the TextLabel off-screen above the top again
	local tweenInfoOut = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In)
	local tweenGoalOut = { Position = UDim2.new(0.5, -200, -0.2, 0) }
	local tweenOut = TweenService:Create(TextLabel, tweenInfoOut, tweenGoalOut)
	tweenOut:Play()

	-- Destroy the GUI after the tween is complete
	tweenOut.Completed:Wait()
	ScreenGui:Destroy()
end

ShowMessageEvent.OnClientEvent:Connect(createMessageGui)
