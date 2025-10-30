--[[
	Handles the previewing of accessories on the default and player avatars.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local PreviewModels = ReplicatedStorage:WaitForChild("PreviewModels")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local PreviewTool = {}
PreviewTool.__index = PreviewTool

local ACCESSORY_CLONE_NAME = "AccessoryClone"

local CAMERA_FOV = 35
local CAMERA_OFFSET = Vector3.new(0, 0, -12)

function PreviewTool.new(modelInfo: ModelInfo.ModelInfoClass, cameraManager, modelDisplay)
	local self = {}
	setmetatable(self, PreviewTool)

	self.modelInfo = modelInfo
	self.cameraManager = cameraManager
	self.modelDisplay = modelDisplay

	self:SetupRoxy()
	self:SetupPlayerClone()

	modelDisplay:TrackPreviewModels({ self.roxyModel, self.playerAvatar })

	return self
end

function PreviewTool:SetupRoxy()
	local RoxyModel = PreviewModels:WaitForChild("Roxy")

	self.roxyModel = RoxyModel:Clone()
	self.roxyModel.Parent = workspace

	self.roxyPreviewMarker = game.Workspace:WaitForChild("PreviewPositionMarker1")
	self.roxyPreviewMarker.Transparency = 1

	self:RemoveExistingMatchingAccessories(self.roxyModel)

	self.roxyModel:PivotTo(CFrame.new(self.roxyPreviewMarker.Position))
end

function PreviewTool:SetupPlayerClone()
	local playerAvatarModel = LocalPlayer.Character

	playerAvatarModel.Archivable = true
	self.playerAvatar = playerAvatarModel:Clone()
	playerAvatarModel.Archivable = false

	self.playerAvatar.Parent = workspace
	self.playerAvatar.Name = "PlayerAvatarClone"

	self.playerAvatarPreviewMarker = game.Workspace:WaitForChild("PreviewPositionMarker2")
	self.playerAvatarPreviewMarker.Transparency = 1

	self:RemoveExistingMatchingAccessories(self.playerAvatar)

	self.playerAvatar:PivotTo(CFrame.new(self.playerAvatarPreviewMarker.Position))
end

-- Remove existing accessories of the same type as the asset we are previewing
function PreviewTool:RemoveExistingMatchingAccessories(body)
	local model: Model = self.modelInfo:GetModel()
	local accessory = model:FindFirstChildWhichIsA("Accessory")

	local humanoid: Humanoid = body:FindFirstChildWhichIsA("Humanoid")
	local humanoidAccessories = humanoid:GetAccessories()
	for _, existingAccessory in humanoidAccessories do
		if existingAccessory.AccessoryType == accessory.AccessoryType then
			existingAccessory:Destroy()
		end
	end
end

function PreviewTool:GetPreviewModels()
	return { self.roxyModel, self.playerAvatar }
end

function PreviewTool:MoveCameraToMarker(marker)
	self.cameraManager:SetCameraInputLocked(true)
	local camera = workspace.CurrentCamera

	local cameraPosition = marker.Position + CAMERA_OFFSET
	local targetPosition = marker.Position

	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = CAMERA_FOV
	camera.CFrame = CFrame.lookAt(cameraPosition, targetPosition)
end

function PreviewTool:MoveCameraToRoxy()
	self:MoveCameraToMarker(self.roxyPreviewMarker)
end

function PreviewTool:MoveCameraToPlayerAvatar()
	self:MoveCameraToMarker(self.playerAvatarPreviewMarker)
end

function PreviewTool:ApplyAccessoryToBodies()
	if self.modelInfo:GetCreationType() ~= Constants.CREATION_TYPES.Accessory then
		warn("Cannot apply non-accessory item to avatar for preview!")
		return
	end

	local model: Model = self.modelInfo:GetModel()
	local accessory = model:FindFirstChildWhichIsA("Accessory")
	assert(accessory, "Model must contain an accessory.")

	for _, body in { self.roxyModel, self.playerAvatar } do
		local accessoryClone = accessory:Clone()
		accessoryClone.Name = ACCESSORY_CLONE_NAME
		local handle = accessoryClone:FindFirstChildWhichIsA("MeshPart")
		handle.Name = "Handle"
		handle.Anchored = false
		accessoryClone.Parent = body

		local humanoid: Humanoid = body:FindFirstChildWhichIsA("Humanoid")
		humanoid:BuildRigFromAttachments()

		if body == self.roxyModel then
			-- Rigid accessories may want a previewScale on their
			-- blankData to fit more nicely in a default avatar preview
			local previewScale = self.modelInfo:GetPreviewScale() or 1
			handle.Size = handle.Size * previewScale
		end
	end
end

function PreviewTool:EndPreview()
	-- Remove accessory from bodies
	for _, body in { self.roxyModel, self.playerAvatar } do
		local accessory = body:FindFirstChild(ACCESSORY_CLONE_NAME)
		accessory:Destroy()
	end
	-- Return camera
	self.cameraManager:SetCameraInputLocked(false)
	self.cameraManager:ResetCamera()
end

function PreviewTool:Destroy()
	self.roxyModel:Destroy()
	self.playerAvatar:Destroy()
end

return PreviewTool
