local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShowMessageEvent = Remotes:WaitForChild("ShowMessageEvent")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Message = require(UI:WaitForChild("Message"))

ShowMessageEvent.OnClientEvent:Connect(Message.CreateMessageGui)
