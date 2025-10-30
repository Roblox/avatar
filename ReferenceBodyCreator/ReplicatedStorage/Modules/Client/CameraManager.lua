local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

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

	return MIN_CAMERA_DISTANCE
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
	self.creationType = modelInfo:GetCreationType()
	self.initialLookVector = self.modelCFrame.lookVector
	self.initialDistance = self:GetCameraDistance(CAMERA_FOV, self.model:GetExtentsSize())
	self:ResetCamera()
	return self
end

local function tweenCamera(newCFrame)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
	local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, { CFrame = newCFrame })
	tween:Play()
end

function CameraManager:SetCameraInputLocked(shouldLock: boolean)
	self.isLocked = shouldLock
end

function CameraManager:FocusCameraOnParts(affectedMeshParts, position)
	-- points to pixels factor is used to scale the panning in world coordinates to pixels
	local newPan = (position - self.modelCFrame.p) * self:PointsToPixelsRatio()
	self.cameraPanInPixels = Vector2.new(newPan.X, newPan.Y)
	-- temp model to get extents size
	local tempModel = Instance.new("Model")
	for i, meshPart in affectedMeshParts do
		meshPart:Clone().Parent = tempModel
	end
	local affectedPartsExtentsSize = tempModel:GetExtentsSize()
	tempModel:Destroy()

	self.cameraDistance = self:GetCameraDistance(CAMERA_FOV, affectedPartsExtentsSize)
	local newCFrame = self:CalculateNewCFrame()
	tweenCamera(newCFrame)
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

	local newCFrame =
		CFrame.new(self.modelCFrame.p + (self.initialLookVector * self.cameraDistance), self.modelCFrame.p)

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

	local newCFrame = self:CalculateNewCFrame()
	local camera = workspace.CurrentCamera
	camera.CFrame = newCFrame
	camera.Focus = self.modelCFrame
end

function CameraManager:ResetCamera(useTween)
	local model = self.model
	if not model then
		error("Camera Manager did not find a model!")
	end

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		self.initialLookVector = humanoidRootPart.CFrame.lookVector
	end

	self.modelExtentsSize = model:GetExtentsSize()
	self.cameraDistance = self:GetCameraDistance(CAMERA_FOV, self.modelExtentsSize)

	self.cameraDegreesAngle = Vector2.new(0, 0)

	self.cameraPanInPixels = Vector2.new(0, 0)

	if useTween then
		local newCFrame = self:CalculateNewCFrame()
		tweenCamera(newCFrame)
	else
		self:UpdateCameraPosition()
	end
end

-- calculates how many pixels are per one world coordinate point at the current resolution
function CameraManager:PointsToPixelsRatio()
	local absoluteSize = workspace.CurrentCamera.ViewportSize
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
	return workspace.CurrentCamera.ViewportSize.Y / math.max(self.modelExtentsSize.X, self.modelExtentsSize.Y)
end

-- calculates how many world coordinates points are per one pixel at the current resolution
function CameraManager:PixelsToPointsRatio()
	local absoluteSize = workspace.CurrentCamera.ViewportSize
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

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		self.initialLookVector = humanoidRootPart.CFrame.lookVector
	end

	self.modelExtentsSize = model:GetExtentsSize()
	self.cameraDistance = self:GetCameraDistance(CAMERA_FOV, self.modelExtentsSize)

	self.cameraDegreesAngle = Vector2.new(0, 0)

	self.cameraPanInPixels = Vector2.new(panFromCenterX, 0)

	local newCFrame = self:CalculateNewCFrame()
	tweenCamera(newCFrame)
end

function CameraManager:PanToLeft(isMobile: boolean?)
	local absoluteSize = workspace.CurrentCamera.ViewportSize
	-- move the model to be about a fourth from the edge of the screen
	local panFromCenterX = absoluteSize.X / 2 - absoluteSize.X / 4
	
	if self.creationType == Constants.CREATION_TYPES.Accessory and isMobile then
		panFromCenterX *= MOBILE_ACCESSORY_PAN_XOFFSET_SCALE
	end

	self:PanX(panFromCenterX)

	-- For ease of accessory editing, zoom after panning over
	if self.creationType == Constants.CREATION_TYPES.Accessory then
		self.cameraDistance = math.max(
			getMinCameraDistance(self.creationType),
			self.cameraDistance * ACCESSORY_ZOOM
		)

		local newCFrame = self:CalculateNewCFrame()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, { CFrame = newCFrame })
		tween:Play()
	end
end

function CameraManager:Destroy() end

return CameraManager
