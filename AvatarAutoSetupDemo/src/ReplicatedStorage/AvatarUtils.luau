-- Utilities for loading and equipping generated avatars.

local AvatarCreationService = game:GetService("AvatarCreationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EditableUtils = require(ReplicatedStorage:WaitForChild("EditableUtils"))
local EquipAvatarEvent = ReplicatedStorage:WaitForChild("EquipAvatarEvent") :: RemoteEvent
local AvatarUtils = {}

local tokenMap = {
	[120412862677951] = "f40f3712-2e6e-4263-9d39-18efdf340fca",
	[70760078093031] = "abcfb7e7-425f-4912-8e2f-baca98de6bc4",
	[90515339563907] = "b15869c1-79ab-4260-a4f3-0a0ce6a73e72",
}

local TOKEN = tokenMap[game.PlaceId]

-- Cache all humanoid descriptions that we fetch since they will be removed once
-- fetched from both client and server.
local cachedHumanoidDescriptions = {}

-- Wrapper around LoadGeneratedAvatarAsync to cache the results.
local function loadGeneratedAvatar(generationId: string)
	if cachedHumanoidDescriptions[generationId] then
		return cachedHumanoidDescriptions[generationId]
	end

	local humanoidDescription = AvatarCreationService:LoadGeneratedAvatarAsync(generationId)
	cachedHumanoidDescriptions[generationId] = humanoidDescription

	return humanoidDescription
end

-- Manually equips the avatar on the client by replacing the current character model
local function equipAvatarOnClient(newModel: Model)
	local localPlayer = Players.LocalPlayer
	local prevModel = localPlayer.Character
	local newAnim = prevModel.Animate:Clone() -- Clone the existing animations
	local name = prevModel.Name
	local cframe = prevModel.PrimaryPart.CFrame

	newModel.Parent = Workspace
	newModel.Name = name
	localPlayer.Character = newModel -- Set the new model as the local player character

	-- Destroy the old Animate instance and add the new one as a child
	local oldAnim = newModel:FindFirstChild("Animate")
	if oldAnim then
		oldAnim:Destroy()
	end
	newAnim.Parent = newModel

	prevModel:Destroy()
	newModel:PivotTo(cframe.Rotation + cframe.Position)

	-- Update the camera to follow the new player model
	local camera = Workspace.CurrentCamera
	local cameraCFrame = camera.CFrame

	-- Updating the camera subject causes the camera CFrame to change
	local changedSignal
	changedSignal = camera:GetPropertyChangedSignal("CFrame"):Connect(function()
		-- Restore the original CFrame once it has changed
		camera.CFrame = cameraCFrame
		changedSignal:Disconnect()
	end)

	camera.CameraSubject = game.Players.LocalPlayer.Character
end

function AvatarUtils.equipAvatarOnClientById(generationId: string)
	local humanoidDescription = loadGeneratedAvatar(generationId)
	local model = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	equipAvatarOnClient(model)
end

function AvatarUtils.setupAvatar(player: Player, inputModel: Model)
	local model = inputModel:Clone()
	EditableUtils.convertAllToEditables(model)
	return AvatarCreationService:AutoSetupAvatarAsync(player, model)
end

function AvatarUtils.publishAvatar(player:Player, generationId: string)
	local humanoidDescription = loadGeneratedAvatar(generationId)

	local success, errorMessage = pcall(function()
		local result, bundleId, outfitId = AvatarCreationService:PromptCreateAvatarAsync(TOKEN, player, humanoidDescription)
		print("publishAvatar result:", result, bundleId, outfitId)
	end)
	if not success then
		warn("Failed to publish avatar:", errorMessage)
	end
end

function AvatarUtils.equipAvatarFromServer(player: Player, generationId: string)
	EquipAvatarEvent:FireClient(player, generationId)
end

return AvatarUtils
