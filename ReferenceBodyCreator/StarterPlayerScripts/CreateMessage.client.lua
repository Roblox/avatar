--[[ Roblox Services ]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[ Constants ]]--
local ShowMessageEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShowMessageEvent")
local Message = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("Message"))

-- Connect the event to the function
ShowMessageEvent.OnClientEvent:Connect(Message.CreateMessageGui)