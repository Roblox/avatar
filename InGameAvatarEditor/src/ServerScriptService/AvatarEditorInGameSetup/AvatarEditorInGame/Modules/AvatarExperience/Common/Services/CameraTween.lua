--[[
	Tweening between two camera CFrames, whilst handling none orthonormalized camera CFrames
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CameraTween = {}

CameraTween.__index = CameraTween

local tweenType = {
	bothCFramesOrthoNormalized = {},
	bothCFramesFlattened = {},
	mixedOrthoNormalizedAndFlattenedCFrames = {}
}

function CameraTween.new(camera, toCFrame, playTime, easingStyle, easingDirection)
	local self = setmetatable({}, CameraTween)

	self.camera = camera
	self.fromCFrame = nil
	self.fromCFrameOrthoNormalized = nil
	self.toCFrame = toCFrame
	self.toCFrameOrthoNormalized = CFrame.fromMatrix(toCFrame.Position, toCFrame.RightVector, toCFrame.UpVector)
	self.startTime = nil
	self.playTime = playTime
	self.easingStyle = easingStyle
	self.easingDirection = easingDirection
	self.renderSteppedConnection = nil
	self.tweenInterpolationType = nil

	return self
end

local function FuzzyEq(vect, vectOther)
	local diff = vect-vectOther
	local squaredDistance = diff:Dot(diff)
	local EqualityTol = 0.001*0.001
	return squaredDistance < EqualityTol
end

local function sphericalLerp(fromVector, toVector, interpolationVal)
	fromVector = fromVector.Unit
	toVector = toVector.Unit
	if FuzzyEq(fromVector, toVector) then -- check for this to avoid a failed cross product operation further down
		return fromVector
	end

	local upVector = toVector:Cross(fromVector).Unit
	local fromCFrame = CFrame.fromMatrix(Vector3.new(), upVector.Unit:Cross(fromVector).Unit, upVector)
	local toCFrame = CFrame.fromMatrix(Vector3.new(), upVector.Unit:Cross(toVector).Unit, upVector)
	return fromCFrame:Lerp(toCFrame, interpolationVal).LookVector.Unit
end

local function lerp(from, to, interp)
	return from + ((to - from) * interp)
end

local function tween(self, interpolationVal)
	local tweenedOrthoNormalized = self.fromCFrameOrthoNormalized:Lerp(self.toCFrameOrthoNormalized, interpolationVal)
	if tweenType.bothCFramesOrthoNormalized == self.tweenInterpolationType then
		return tweenedOrthoNormalized
	end

	local finalLookVector = sphericalLerp(self.fromCFrame.LookVector, self.toCFrame.LookVector, interpolationVal)

	local finalMagnitude = nil
	if tweenType.bothCFramesFlattened == self.tweenInterpolationType then
		local cosineOfSkewAngle = -finalLookVector:Dot(tweenedOrthoNormalized.LookVector)
		finalMagnitude = cosineOfSkewAngle
	else -- mixedOrthoNormalizedAndFlattenedCFrames == self.tweenInterpolationType
		finalMagnitude = lerp(self.fromCFrame.LookVector.Magnitude, self.toCFrame.LookVector.Magnitude, interpolationVal)
	end

	return CFrame.fromMatrix(tweenedOrthoNormalized.Position, tweenedOrthoNormalized.RightVector,
		tweenedOrthoNormalized.UpVector, finalLookVector*finalMagnitude)
end

local function checkFinish(self, linearInterpolationVal)
	local isFinished = linearInterpolationVal >= 1
	if isFinished then
		self:stop()
	end
end

local function getSmoothedInterpolationVal(self, linearInterpolationVal)
	return TweenService:GetValue(linearInterpolationVal, self.easingStyle, self.easingDirection)
end

local function calculateTweenType(self)
	local isFromOrthoNormalized = FuzzyEq(self.fromCFrameOrthoNormalized.LookVector, self.fromCFrame.LookVector)
	local isToOrthoNormalized = FuzzyEq(self.toCFrameOrthoNormalized.LookVector, self.toCFrame.LookVector)

	if isFromOrthoNormalized and isToOrthoNormalized then
		return tweenType.bothCFramesOrthoNormalized
	end

	if not isFromOrthoNormalized and not isToOrthoNormalized then
		return tweenType.bothCFramesFlattened
	end
	return tweenType.mixedOrthoNormalizedAndFlattenedCFrames
end

local function initPlay(self)
	self.startTime = time()
	self.fromCFrame = self.camera.CFrame
	self.fromCFrameOrthoNormalized =
		CFrame.fromMatrix(self.fromCFrame.Position, self.fromCFrame.RightVector, self.fromCFrame.UpVector)
	self.tweenInterpolationType = calculateTweenType(self)
end

function CameraTween:play()
	initPlay(self)
	if self.renderSteppedConnection then
		return
	end

	self.renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local linearInterpolationVal = (time()-self.startTime)/self.playTime
		local smoothedInterpolationVal = getSmoothedInterpolationVal(self, math.min(1, linearInterpolationVal))
		self.camera.CFrame = tween(self, smoothedInterpolationVal)
		checkFinish(self, linearInterpolationVal)
	end)
end

function CameraTween:stop()
	if self.renderSteppedConnection then
		self.renderSteppedConnection:disconnect()
		self.renderSteppedConnection = nil
	end
end

return CameraTween