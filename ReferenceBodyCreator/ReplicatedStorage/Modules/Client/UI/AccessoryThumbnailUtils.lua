--[[
	Builds eyebrow/eyelash catalog previews using the publish prompt's thumbnail head and cameras.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))

local Components = script.Parent:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))

local THUMBNAIL_HEAD_ASSET_ID = 103273511207307
local THUMBNAIL_HEAD_COLOR = BrickColor.new(194)
local CAMERA_LOOK_VECTOR = Vector3.new(-0.54678017, -0.019651636, 0.83704555)
local CAMERA_POSITIONS = {
	Eyebrows = Vector3.new(4.5928926, 0.37917417, -7.374273),
	Eyelashes = Vector3.new(4.593966, 0.2791934, -7.375918),
}

local AccessoryThumbnailUtils = {}

function AccessoryThumbnailUtils.CreateHead(): Model?
	local description = Instance.new("HumanoidDescription")
	description.Head = THUMBNAIL_HEAD_ASSET_ID
	local success, character = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
	end)
	description:Destroy()
	if not success then
		warn("Could not load accessory thumbnail head: " .. tostring(character))
		return nil
	end

	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("MeshPart") or not head:FindFirstChildOfClass("WrapTarget") then
		character:Destroy()
		return nil
	end

	-- Thumbnail characters must not run Animate or other character scripts.
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end

	character.Parent = workspace
	character:GetBoundingBox()
	character.Parent = nil
	for _, child in character:GetChildren() do
		if child:IsA("BasePart") and child ~= head then
			child:Destroy()
		end
	end
	local bodyColors = character:FindFirstChildOfClass("BodyColors")
	if bodyColors then
		bodyColors.HeadColor = THUMBNAIL_HEAD_COLOR
	end
	head.Color = THUMBNAIL_HEAD_COLOR.Color
	head.Anchored = true
	head.PivotOffset = CFrame.identity
	character.PrimaryPart = head
	character:PivotTo(CFrame.identity)
	return character
end

function AccessoryThumbnailUtils.CreatePreview(headModel: Model, accessory: Accessory): Model
	local preview = headModel:Clone()
	AccessoryUtils.EquipLayeredAccessoryOntoWrapTarget(preview, accessory:Clone())
	return preview
end

function AccessoryThumbnailUtils.GetViewportOptions(category: string): BaseTile.ViewportOptions
	local position = CAMERA_POSITIONS[category]
	return {
		ambient = Color3.fromRGB(160, 160, 160),
		lightColor = Color3.fromRGB(240, 240, 240),
		lightDirection = Vector3.new(9.5, -12, 7.5),
		fieldOfView = 5,
		cameraCFrame = CFrame.lookAt(position, position + CAMERA_LOOK_VECTOR),
		preserveAnchoring = true,
	}
end

return AccessoryThumbnailUtils
