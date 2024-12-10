-- Captures user input to rotate/zoom/pan the 3d model of the mesh

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local DEGREES_PER_PIXEL = 0.5
local MIN_OFFSET_X = -2
local MAX_OFFSET_X = 2
local MIN_OFFSET_Y = -1
local MAX_OFFSET_Y = 1
local MIN_OFFSET_Z = -3
local MAX_OFFSET_Z = 2

-- TODO take out camera control into camera manager

local ModelDisplay = {}
ModelDisplay.__index = ModelDisplay

function ModelDisplay.new(modelInfo: ModelInfo.ModelInfoClass)
	local self = {}
	setmetatable(self, ModelDisplay)

	self.model = modelInfo:GetModel()

	self.rotationX = 180
	self.rotationY = 0
	self.positionOffset = Vector3.new(0, 0, -2)

	Lighting.ClockTime = 9
	Lighting.GeographicLatitude = 50

	self.originalCFrame = modelInfo:GetInitialModelCFrame()
	self.localFocusPoint = Vector3.zero
	self.globalFocusPoint = self.model.PrimaryPart.CFrame.Position
	self.defaultCameraCFrame = workspace.CurrentCamera.CFrame

	self:RotateModel()

	self.inputObjects = {}
	self:UpdateModelCFrames()

	return self
end

function ModelDisplay:ResetModel()
	self.rotationX = 180
	self.rotationY = 0
	self.positionOffset = Vector3.new(0, 0, -2)
	self:RotateModel()
	self:UpdateModelCFrames()
end

function ModelDisplay:GetNearestSnapAngle()
	local rotation = self.rotationX % 360
	local nearestSnapAngle = math.round(rotation / 90) * 90

	return nearestSnapAngle
end

function ModelDisplay:GetCurrentView()
	local nearestSnapAngle = self:GetNearestSnapAngle()

	if nearestSnapAngle == 180 then
		return "Front"
	elseif nearestSnapAngle == 90 or nearestSnapAngle == 270 then
		return "Side"
	else
		return "Back"
	end
end

function ModelDisplay:UpdateModelCFrames()
	-- Clamp the offset so that the model doesn't go out-of-frame
	local clampedX = math.clamp(self.positionOffset.x, MIN_OFFSET_X, MAX_OFFSET_X)
	local clampedY = math.clamp(self.positionOffset.y, MIN_OFFSET_Y, MAX_OFFSET_Y)
	local clampedZ = math.clamp(self.positionOffset.z, MIN_OFFSET_Z, MAX_OFFSET_Z)
	self.positionOffset = Vector3.new(clampedX, clampedY, clampedZ)

	local newCFrame = CFrame.new(self.originalCFrame.Position + self.positionOffset)
		* self.originalCFrame.Rotation
		* CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)

	self.model:SetPrimaryPartCFrame(newCFrame)
end

function ModelDisplay:GetModel()
	return self.model
end

function ModelDisplay:SetRotationY(rotationY)
	self.rotationY = rotationY
end

function ModelDisplay:RotateModelFromPixels(deltaX)
	self.rotationX += deltaX * DEGREES_PER_PIXEL
	self:RotateModel()
end

function ModelDisplay:RotateModelFromDegrees(degrees)
	self.rotationX += degrees
	self:RotateModel()
end

function ModelDisplay:GetScreenPosition()
	local modelWorldPosition = self.model.PrimaryPart.Position
	local vector, _onScreen = workspace.CurrentCamera:WorldToScreenPoint(modelWorldPosition)
	return Vector2.new(vector.X, vector.Y)
end

function ModelDisplay:RotateModel()
	if self.model == nil or self.model.PrimaryPart == nil then
		return
	end
	local currentCFrame = self.model.PrimaryPart.CFrame
	local currentPos = currentCFrame.Position
	local startOrientation = self.originalCFrame.Rotation
	local newCFrame = CFrame.new(currentPos.X, currentPos.Y, currentPos.Z)
		* startOrientation
		* CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)
	local worldSpaceOffset = (newCFrame:PointToWorldSpace(self.localFocusPoint) - newCFrame.Position)
	local modelPos = self.globalFocusPoint - worldSpaceOffset

	newCFrame = CFrame.new(modelPos.X, modelPos.Y, modelPos.Z)
		* startOrientation
		* CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)
	-- If we're currently focused on a point other than the center, move the model so that our focus point is where the center was
	self.model:SetPrimaryPartCFrame(newCFrame + self.positionOffset)
end

function ModelDisplay:OnExitedEditMode()
	-- Revert model to start pos
	self.model:SetPrimaryPartCFrame(self.originalCFrame)
	self.localFocusPoint = Vector3.zero
	self.globalFocusPoint = self.model.PrimaryPart.CFrame.Position
	self:RotateModel()
end

function ModelDisplay:Destroy()
	-- The model will be destroyed by the ModelInfo that owns it
end

return ModelDisplay
