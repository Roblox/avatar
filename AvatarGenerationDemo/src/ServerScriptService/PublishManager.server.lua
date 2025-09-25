local AvatarCreationService = game:GetService("AvatarCreationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local PublishAvatarEvent = Events:WaitForChild("PublishAvatar")

local tokenMap = {
	[82532142400096] = "a553ce5d-c132-413c-a46f-2d4cac5e380a",
	[18235917861] = "8e60bab4-6eaf-4c09-b50a-8c5940d25b80"
}

function PublishAvatar(player, generationId)
	local humanoidDescription = ServerStorage:WaitForChild(generationId)
	local token = tokenMap[game.PlaceId]
	if not token then
		print(AvatarCreationService:ValidateUGCFullBodyAsync(player, humanoidDescription))
		return
	end
	print(AvatarCreationService:PromptCreateAvatarAsync(token, player, humanoidDescription))
end

PublishAvatarEvent.OnServerEvent:Connect(PublishAvatar)
