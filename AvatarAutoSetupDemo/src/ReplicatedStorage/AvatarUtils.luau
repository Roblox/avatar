-- Utilities for loading and equipping generated avatars.

local AvatarCreationService = game:GetService("AvatarCreationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EquipAvatarEvent = ReplicatedStorage:WaitForChild("EquipAvatarEvent") :: RemoteEvent

local AvatarUtils = {}

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

local function replaceAccessory(humanoidDescription: HumanoidDescription, accessoryDescription: AccessoryDescription)
	for _, child in humanoidDescription:GetChildren() do
		if child:IsA("AccessoryDescription") and child.AccessoryType == accessoryDescription.AccessoryType then
			child:Destroy()
		end
	end
	accessoryDescription:Clone().Parent = humanoidDescription
end

local function mergeAccessoriesWithCurrentHD(accessoryHd: HumanoidDescription): HumanoidDescription?
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("No humanoid found on character")
		return nil
	end
	local hd = humanoid:GetAppliedDescription()

	for _, child in accessoryHd:GetChildren() do
		if child:IsA("AccessoryDescription") then
			replaceAccessory(hd, child)
		end
	end
	return hd
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
	camera:GetPropertyChangedSignal("CFrame"):Once(function()
		-- Restore the original CFrame once it has changed
		camera.CFrame = cameraCFrame
	end)

	camera.CameraSubject = Players.LocalPlayer.Character
end

function AvatarUtils.equipAvatarOnClientById(generationId: string)
	local humanoidDescription = loadGeneratedAvatar(generationId)
	local foundBodyPart = false
	for _, child in humanoidDescription:GetChildren() do
		if child:IsA("BodyPartDescription") and child.Instance ~= nil then
			foundBodyPart = true
			break
		end
	end
	if not foundBodyPart then
		humanoidDescription = mergeAccessoriesWithCurrentHD(humanoidDescription) or humanoidDescription
	end
	local model = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	equipAvatarOnClient(model)
end

export type ProgressInfo = {
	Progress: number, -- A value between 0 and 1
}

function AvatarUtils.equipAvatarFromServer(player: Player, generationId: string)
	EquipAvatarEvent:FireClient(player, generationId)
end

return AvatarUtils
