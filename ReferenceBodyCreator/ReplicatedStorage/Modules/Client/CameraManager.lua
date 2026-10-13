local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local MakeupCameraConfig = require(Config:WaitForChild("MakeupCameraConfig"))

local CAMERA_FOV = 30

local MAX_CAMERA_DISTANCE = 12
local MIN_CAMERA_DISTANCE = 1.5
local MIN_ACCESSORY_CAMERA_DISTANCE = 4

local SCROLL_ZOOM_STEP = -1
local TOUCH_ZOOM_STEP = -0.05

local ACCESSORY_DISTANCE_SCALE = 3
local ACCESSORY_ZOOM = 0.85
local MOBILE_ACCESSORY_PAN_XOFFSET_SCALE = 2

local CameraManager = {}
CameraManager.__index = CameraManager

local function getMinCameraDistance(creationType)
	if creationType == Constants.CREATION_TYPES.Accessory then
		return MIN_ACCESSORY_CAMERA_DISTANCE
	end
	if creationType == Constants.CREATION_TYPES.Makeup then
		return MakeupCameraConfig.MinDistance
	end

	return MIN_CAMERA_DISTANCE
end

local function getMakeupFitDistance(fov: number, headSize: Vector3, preset): number
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local aspectRatio = if viewportSize.X > 0 and viewportSize.Y > 0 then viewportSize.X / viewportSize.Y else 1
	local verticalTangent = math.tan(math.rad(fov) / 2)
	local horizontalTangent = verticalTangent * aspectRatio

	local framedWidth = headSize.X * preset.BoundsScale.X
	local framedHeight = headSize.Y * preset.BoundsScale.Y
	local horizontalDistance = framedWidth / 2 / horizontalTangent
	local verticalDistance = framedHeight / 2 / verticalTangent
	local distance = (math.max(horizontalDistance, verticalDistance) + headSize.Z / 2) * preset.DistanceScale

	return math.clamp(distance, MakeupCameraConfig.MinDistance, MAX_CAMERA_DISTANCE)
end

function CameraManager:GetCameraDistance(fov, extentsSize)
	local xSize, ySize, zSize = extentsSize.X, extentsSize.Y, extentsSize.Z

	local maxSize = math.max(xSize, ySize)

	local fovMultiplier = 1 / math.tan(math.rad(fov) / 2)
	local halfSize = maxSize / 2
	local distance = (halfSize * fovMultiplier) + (zSize / 2)
	if ySize < 3.0 then
		distance = distance * ACCESSORY_DISTANCE_SCALE
	end

	local minCameraDistance = getMinCameraDistance(self.creationType)
	return math.clamp(distance, minCameraDistance, MAX_CAMERA_DISTANCE)
end

function CameraManager.new(modelInfo)
	local self = {}
	setmetatable(self, CameraManager)

	self.isLocked = false
	self.model = modelInfo:GetModel()
	self.creationType = modelInfo:GetCreationType()
	self.modelCFrame = modelInfo:GetInitialModelCFrame()
	self.cameraTargetPosition = self.modelCFrame.Position
	if self.creationType == Constants.CREATION_TYPES.Makeup then
		self.initialLookVector = Vector3.new(0, 0, 1)
	else
		self.initialLookVector = self.modelCFrame.lookVector
	end
	self:ResetCamera()
	self.initialDistance = self.cameraDistance
	return self
end

function CameraManager:TweenCamera(newCFrame)
	self:CancelCameraTween()

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
	self.cameraTween = TweenService:Create(workspace.CurrentCamera, tweenInfo, { CFrame = newCFrame })
	self.cameraTween:Play()
end

function CameraManager:CancelCameraTween()
	if self.cameraTween then
		self.cameraTween:Cancel()
		self.cameraTween = nil
	end
end

function CameraManager:ApplyMakeupPreset(useTween: boolean?)
	local head = self.model:FindFirstChild("Head", true)
	if not head or not head:IsA("BasePart") then
		return false
	end

	local preset = MakeupCameraConfig.Presets[self.makeupAssetType] or MakeupCameraConfig.DefaultPreset
	local localOffset = head.Size * preset.FocusOffset
	self.cameraTargetPosition = head.CFrame:PointToWorldSpace(localOffset)
	self.modelExtentsSize = head.Size
	self.cameraDistance = getMakeupFitDistance(MakeupCameraConfig.FieldOfView, head.Size, preset)
	workspace.CurrentCamera.FieldOfView = MakeupCameraConfig.FieldOfView

	if useTween then
		workspace.CurrentCamera.Focus = CFrame.new(self.cameraTargetPosition)
		self:TweenCamera(self:CalculateNewCFrame())
	else
		self:UpdateCameraPosition()
	end

	return true
end

function CameraManager:FocusOnMakeupAssetType(makeupAssetType: string?, useTween: boolean, panForPanel: boolean): number
	if self.creationType ~= Constants.CREATION_TYPES.Makeup then
		return 0
	end

	self.makeupAssetType = makeupAssetType
	local panFromCenterX = if panForPanel
		then workspace.CurrentCamera.ViewportSize.X * MakeupCameraConfig.PanelPanViewportScale
		else 0
	self.cameraPanInPixels = Vector2.new(panFromCenterX, 0)
	if not self:ApplyMakeupPreset(useTween) then
		return 0
	end

	return self:GetMakeupPanelFacingYaw()
end

function CameraManager:SetCameraInputLocked(shouldLock: boolean)
	self.isLocked = shouldLock
end

function CameraManager:FocusCameraOnParts(affectedMeshParts, position, panForPanel: boolean?): number
	-- temp model to get extents size
	local tempModel = Instance.new("Model")
	for i, meshPart in affectedMeshParts do
		meshPart:Clone().Parent = tempModel
	end
	local affectedPartsExtentsSize = tempModel:GetExtentsSize()
	tempModel:Destroy()

	self.modelExtentsSize = affectedPartsExtentsSize
	if panForPanel then
		local preset = MakeupCameraConfig.IsolatedAccessoryPreset
		self.cameraDistance =
			getMakeupFitDistance(workspace.CurrentCamera.FieldOfView, affectedPartsExtentsSize, preset)
		self.cameraTargetPosition = position
		self.cameraPanInPixels = Vector2.new(workspace.CurrentCamera.ViewportSize.X * preset.PanelPanViewportScale, 0)
		workspace.CurrentCamera.Focus = CFrame.new(position)
	else
		self.cameraDistance = self:GetCameraDistance(workspace.CurrentCamera.FieldOfView, affectedPartsExtentsSize)
		-- points to pixels factor is used to scale the panning in world coordinates to pixels
		local newPan = (position - self.cameraTargetPosition) * self:PointsToPixelsRatio()
		self.cameraPanInPixels = Vector2.new(newPan.X, newPan.Y)
	end
	local newCFrame = self:CalculateNewCFrame()
	self:TweenCamera(newCFrame)
	return self:GetMakeupPanelFacingYaw()
end

function CameraManager:ZoomToPoint(zoomDelta: number, screenPixelPoint: Vector2?, useTouchStep)
	if self.isLocked then
		return
	end

	local prevCameraDistance = self.cameraDistance
	local step = if useTouchStep then TOUCH_ZOOM_STEP * zoomDelta else SCROLL_ZOOM_STEP * zoomDelta

	step = step * (self.cameraDistance / self.initialDistance)
	self.cameraDistance = self.cameraDistance + step
	self:ClampValues()
	-- don't pan if the distance didn't change
	if screenPixelPoint and prevCameraDistance ~= self.cameraDistance then
		-- we change the cameraPanInPixels to keep pointFromCenter in position when zooming
		local screenCenterPoint =
			Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		local scalingFactor = (step / self.cameraDistance * Vector2.new(-1, 1))
		self.cameraPanInPixels = self.cameraPanInPixels + (screenPixelPoint - screenCenterPoint) * scalingFactor
		self:ClampValues()
	end
	self:UpdateCameraPosition()
end

function CameraManager:CalculateNewCFrame()
	-- Zoom

	local targetPosition = self.cameraTargetPosition
	local newCFrame = CFrame.new(targetPosition + (self.initialLookVector * self.cameraDistance), targetPosition)

	-- PANNING
	-- panScalingFactor represents the ratio of points to pixels of actual panning in pixels
	local panScalingFactor = self:PixelsToPointsRatio()
	-- we move the camera on the perpendicular plane to the lookVector
	newCFrame = newCFrame
		+ newCFrame.UpVector * panScalingFactor * self.cameraPanInPixels.Y
		+ newCFrame.RightVector * panScalingFactor * self.cameraPanInPixels.X
	return newCFrame
end

-- Sets new position of camera using current state, without a tween
function CameraManager:UpdateCameraPosition()
	if workspace.CurrentCamera.ViewportSize == nil or self.cameraDistance == nil then
		print("absoluteSize or cameraDistance were not defined!")
		return
	end

	self:CancelCameraTween()
	local newCFrame = self:CalculateNewCFrame()
	local camera = workspace.CurrentCamera
	camera.CFrame = newCFrame
	camera.Focus = CFrame.new(self.cameraTargetPosition)
end

function CameraManager:ResetCamera(useTween)
	local model = self.model
	if not model then
		error("Camera Manager did not find a model!")
	end

	if self.creationType ~= Constants.CREATION_TYPES.Makeup then
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			self.initialLookVector = humanoidRootPart.CFrame.lookVector
		end
	end

	self.cameraPanInPixels = Vector2.new(0, 0)
	if self.creationType == Constants.CREATION_TYPES.Makeup and self:ApplyMakeupPreset(useTween) then
		return
	end

	self.modelExtentsSize = model:GetExtentsSize()
	self.cameraDistance = self:GetCameraDistance(CAMERA_FOV, self.modelExtentsSize)

	self.cameraDegreesAngle = Vector2.new(0, 0)

	if useTween then
		local newCFrame = self:CalculateNewCFrame()
		self:TweenCamera(newCFrame)
	else
		self:UpdateCameraPosition()
	end
end

-- calculates how many pixels are per one world coordinate point at the current resolution
function CameraManager:PointsToPixelsRatio()
	return 1 / self:PixelsToPointsRatio()
end

-- calculates how many world coordinates points are per one pixel at the current resolution
function CameraManager:PixelsToPointsRatio()
	local absoluteSize = workspace.CurrentCamera.ViewportSize
	if
		self.creationType == Constants.CREATION_TYPES.Makeup
		and absoluteSize.Y > 0
		and self.cameraDistance
		and self.cameraDistance > 0
	then
		local visibleWorldHeight = 2 * self.cameraDistance * math.tan(math.rad(MakeupCameraConfig.FieldOfView) / 2)
		return visibleWorldHeight / absoluteSize.Y
	end

	if
		absoluteSize == nil
		or self.modelExtentsSize == nil
		or absoluteSize.Y == 0
		or self.modelExtentsSize.Y == 0
		or self.modelExtentsSize.X == 0
	then
		return 1
	end
	-- this calculation is based on how we calculate cameraDistance (to exactly match the max extents within the viewport)
	-- also viewport takes only height into consideration when scaling its content
	return math.max(self.modelExtentsSize.X, self.modelExtentsSize.Y) / workspace.CurrentCamera.ViewportSize.Y
end

function CameraManager:ClampValues()
	-- clamp panning
	-- we limit the panning so that the edge of the model extent does no go beyond the center of the frame
	-- absoluteSize / 2 (limits the panning so that the center of the object is on the edge)
	local absoluteSize = workspace.CurrentCamera.ViewportSize
	local maxPanFromCenterX = math.max(self.modelExtentsSize.X / 2 / self:PixelsToPointsRatio(), absoluteSize.X / 2)
	local maxPanFromCenterY = math.max(self.modelExtentsSize.Y / 2 / self:PixelsToPointsRatio(), absoluteSize.Y / 2)
	self.cameraPanInPixels = Vector2.new(
		math.clamp(self.cameraPanInPixels.X, -maxPanFromCenterX, maxPanFromCenterX),
		math.clamp(self.cameraPanInPixels.Y, -maxPanFromCenterY, maxPanFromCenterY)
	)

	--clamp zoom
	self.cameraDistance = math.clamp(self.cameraDistance, getMinCameraDistance(self.creationType), MAX_CAMERA_DISTANCE)
end

function CameraManager:PanByPixels(pixelDelta)
	if self.isLocked then
		return
	end

	self.cameraPanInPixels = self.cameraPanInPixels + pixelDelta
	self:ClampValues()
	self:UpdateCameraPosition()
end

function CameraManager:PanX(panFromCenterX)
	local model = self.model
	if not model then
		error("Camera Manager did not find a model!")
	end

	if self.creationType ~= Constants.CREATION_TYPES.Makeup then
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			self.initialLookVector = humanoidRootPart.CFrame.lookVector
		end

		self.modelExtentsSize = model:GetExtentsSize()
		self.cameraDistance = self:GetCameraDistance(CAMERA_FOV, self.modelExtentsSize)

		self.cameraDegreesAngle = Vector2.new(0, 0)
	end

	self.cameraPanInPixels = Vector2.new(panFromCenterX, 0)

	local newCFrame = self:CalculateNewCFrame()
	self:TweenCamera(newCFrame)
end

function CameraManager:GetMakeupPanelFacingYaw(): number
	if self.creationType ~= Constants.CREATION_TYPES.Makeup or self.cameraDistance <= 0 then
		return 0
	end

	local cameraOffset = self:PixelsToPointsRatio() * self.cameraPanInPixels.X
	return math.deg(math.atan2(cameraOffset, self.cameraDistance))
end

function CameraManager:PanToLeft(isMobile: boolean?)
	local absoluteSize = workspace.CurrentCamera.ViewportSize
	-- move the model to be about a fourth from the edge of the screen
	local panFromCenterX = absoluteSize.X / 2 - absoluteSize.X / 4
	if self.creationType == Constants.CREATION_TYPES.Makeup then
		panFromCenterX = absoluteSize.X * MakeupCameraConfig.PanelPanViewportScale
	end

	if self.creationType == Constants.CREATION_TYPES.Accessory and isMobile then
		panFromCenterX *= MOBILE_ACCESSORY_PAN_XOFFSET_SCALE
	end

	self:PanX(panFromCenterX)

	-- For ease of accessory editing, zoom after panning over
	if self.creationType == Constants.CREATION_TYPES.Accessory then
		self.cameraDistance = math.max(getMinCameraDistance(self.creationType), self.cameraDistance * ACCESSORY_ZOOM)

		local newCFrame = self:CalculateNewCFrame()
		self:TweenCamera(newCFrame)
	end

	return self:GetMakeupPanelFacingYaw()
end

function CameraManager:Destroy()
	self:CancelCameraTween()
end

return CameraManager
