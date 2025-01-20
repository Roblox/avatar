--[[ Roblox Services ]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local PlayersService = game:GetService("Players")

--[[ Constants ]]--
local AvatarEvents = Instance.new("Folder")
AvatarEvents.Name = "AvatarEvents"

local AvatarEditorClosed = Instance.new("RemoteEvent")
AvatarEditorClosed.Name = "AvatarEditorClosed"
AvatarEditorClosed.Parent = AvatarEvents

local LoadAnimationServer = Instance.new("RemoteFunction")
LoadAnimationServer.Name = "LoadAnimationServer"
LoadAnimationServer.Parent = AvatarEvents

AvatarEvents.Parent = ReplicatedStorage

local allowedTypes = {
	"Animation",
	"Model",
	"Folder",
	"AnimationTrack",
	"ValueBase"
}

local function isValidAnimationModel(model)
	local isAllowedType = false
	for _, type in ipairs(allowedTypes) do
		if model:IsA(type) then
			isAllowedType = true
			break
		end
	end
	if not isAllowedType then
		print("Bad type:", model.ClassName)
		return false
	end
	for _, child in ipairs(model:GetChildren()) do
		if not isValidAnimationModel(child) then
			return false
		end
	end
	return true
end

LoadAnimationServer.OnServerInvoke = function(player, assetId)
	local model = InsertService:LoadAsset(assetId)
	if isValidAnimationModel(model) and player.Parent then
		model.Parent = game.Workspace
		delay(10, function()
			model:Destroy()
		end)
		return model
	end
	model:Destroy()
	return nil
end

AvatarEditorClosed.OnServerEvent:Connect(function(player)
	local characterInfo = PlayersService:GetCharacterAppearanceInfoAsync(player.UserId)
	local newHumanoidDescription = PlayersService:GetHumanoidDescriptionFromUserId(player.UserId)

	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local rigType = humanoid.RigType
			if rigType.Name == characterInfo.playerAvatarType then
				humanoid:ApplyDescription(newHumanoidDescription, Enum.AssetTypeVerification.Always)
			else
				player:LoadCharacter()
			end
		end
	end
end)