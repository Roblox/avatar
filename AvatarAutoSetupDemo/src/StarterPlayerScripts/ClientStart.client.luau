-- Client-side initialization

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipAvatarEvent = ReplicatedStorage:WaitForChild("EquipAvatarEvent") :: RemoteEvent
local AvatarUtils = require(ReplicatedStorage:WaitForChild("AvatarUtils"))

-- Connect RemoteEvent on client to equip generated avatar model
EquipAvatarEvent.OnClientEvent:Connect(function(generationId: string)
	AvatarUtils.equipAvatarOnClientById(generationId)
end)
