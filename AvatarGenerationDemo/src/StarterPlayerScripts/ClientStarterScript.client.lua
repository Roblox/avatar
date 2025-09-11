local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local loadUIEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetupUIEvent")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local QueueingUI = require(Modules:WaitForChild("QueueingUI"))
local TextPromptUI = require(Modules:WaitForChild("TextPromptUI"))

local queueingUI = QueueingUI.new()
local textPromptUI = TextPromptUI.new()

local creationManager = nil

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

local RunCreationManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CreationManager"))

-- Force orientation to landscape
PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

function OnLoadUI()
	if creationManager == nil then
		creationManager = RunCreationManager(textPromptUI)
	else
		creationManager:ReopenUI()
	end
end

loadUIEvent.Event:Connect(OnLoadUI)
