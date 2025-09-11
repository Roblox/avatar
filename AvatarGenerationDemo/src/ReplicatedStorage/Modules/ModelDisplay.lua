-- Captures user input to rotate/zoom/pan the 3d model of the mesh

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local DEGREES_PER_PIXEL = 0.5
local PINCH_DELTA_TO_ZOOM_DELTA = 0.007
local PAN_SPEED = 0.003
local WHEEL_ZOOM_SPEED = 0.2
local MAX_ROTATION_Y = 0
local PREVIEW_OFFSET = Vector3.new(20, 0, -3)
local MIN_OFFSET_X = -2
local MAX_OFFSET_X = 2
local MIN_OFFSET_Y = -1
local MAX_OFFSET_Y = 1
local MIN_OFFSET_Z = -3
local MAX_OFFSET_Z = 2
local EDIT_GROUPS = {
	{"Head"},
	{"LeftUpperArm", "LeftLowerArm", "LeftHand"},
	{"RightUpperArm", "RightLowerArm", "RightHand"},
	{"UpperTorso", "LowerTorso"},
	{"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
	{"RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

local ModelDisplay = {}
ModelDisplay.__index = ModelDisplay

function ModelDisplay.new(manager)
	local self = {}
	setmetatable(self, ModelDisplay)

	self.manager = manager
	self.rotationX = 180
	self.rotationY = 0
	self.positionOffset = Vector3.new(0, 0, -2)

	Lighting.ClockTime = 9
	Lighting.GeographicLatitude = 50

	self.InputObjects = {}
	self:_captureInput()

	-- Create a highlight that will be used to highlight various body parts under the mouse
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(128, 255, 128)
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(10, 10, 10)
	highlight.OutlineTransparency = 0.5
	self.highlight = highlight

	return self
end

function ModelDisplay:SetupModel(modelInstance)
	self.model = modelInstance

	if modelInstance:IsA("MeshPart") then
		self.ObjectMovementHandle = modelInstance
	else
		self.ObjectMovementHandle = modelInstance:FindFirstChildWhichIsA("MeshPart")
	end

	self.originalCFrame = self.model.PrimaryPart.CFrame
	self.localFocusPoint = Vector3.zero
	self.globalFocusPoint = self.model.PrimaryPart.CFrame.Position
	self.defaultCameraCFrame = workspace.CurrentCamera.CFrame

	-- Create a bounding box that is the same size/position/orientation as the accessory
	-- This bounding box will be used in paint mode to determine if the player is trying to draw on the mesh or rotate the camera.
	if self.AccessoryBoundingBox then
		self.AccessoryBoundingBox:Destroy()
	end
	self.AccessoryBoundingBox = Instance.new("Part")
	self.AccessoryBoundingBox.Name = "BoundingBox"
	self.AccessoryBoundingBox.Position = self.ObjectMovementHandle.Position
	self.AccessoryBoundingBox.Orientation = self.ObjectMovementHandle.Orientation
	self.AccessoryBoundingBox.Size = Vector3.new(3, 4, 3)
	self.AccessoryBoundingBox.Transparency = 1 --0.9
	self.AccessoryBoundingBox.Anchored = true
	self.AccessoryBoundingBox.CanCollide = false
	self.AccessoryBoundingBox.Parent = workspace
	self.manager.BoundingBox = self.AccessoryBoundingBox

	self:_rotateModel()
	self:updateModelCFrames()
end

function ModelDisplay:getNearestSnapAngle()
	local rotation = self.rotationX % 360
	local nearestSnapAngle = math.round(rotation / 90) * 90

	return nearestSnapAngle
end

function ModelDisplay:updateModelCFrames()
	-- Clamp the offset so that the model doesn't go out-of-frame
	local clampedX = math.clamp(self.positionOffset.x, MIN_OFFSET_X, MAX_OFFSET_X)
	local clampedY = math.clamp(self.positionOffset.y, MIN_OFFSET_Y, MAX_OFFSET_Y)
	local clampedZ = math.clamp(self.positionOffset.z, MIN_OFFSET_Z, MAX_OFFSET_Z)
	self.positionOffset = Vector3.new(clampedX, clampedY, clampedZ)

	local newCFrame = CFrame.new(self.originalCFrame.Position + self.positionOffset) * self.originalCFrame.Rotation * CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)
			
	--self.ObjectMovementHandle.CFrame = newCFrame
	if self.model ~= nil and self.model.PrimaryPart ~= nil then
		self.model:SetPrimaryPartCFrame(newCFrame)
	end

	self:updateBoundingBox()
end

function ModelDisplay:splitInputType(inputObject)
	local isTouch = inputObject.UserInputType == Enum.UserInputType.Touch
	local isMouse1 = inputObject.UserInputType == Enum.UserInputType.MouseButton1
	local isMouse2 = inputObject.UserInputType == Enum.UserInputType.MouseButton2
	local isMouseMovement = inputObject.UserInputType == Enum.UserInputType.MouseMovement
	local isMouseWheel = inputObject.UserInputType == Enum.UserInputType.MouseWheel
	local isMouse = isMouse1 or isMouse2 or isMouseMovement or isMouseWheel

	return isTouch, isMouse, isMouse1, isMouse2, isMouseMovement, isMouseWheel
end

function ModelDisplay:_captureInput()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "InputCapture"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 0
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	self.ScreenGui = ScreenGui

	local InputCapture = Instance.new("Frame")
	InputCapture.BackgroundTransparency = 1
	InputCapture.Size = UDim2.fromScale(1, 1)
	InputCapture.Parent = ScreenGui

	self.maxRotationY = MAX_ROTATION_Y

	self.inputBeganConnection = InputCapture.InputBegan:Connect(function(inputObject, gameProcessed)
		if self.model == nil then
			return
		end

		if gameProcessed then
			return
		end

		local isTouch, isMouse, isMouse1, isMouse2, isMouseMovement, isMouseWheel = self:splitInputType(inputObject)
		local isValidInputType = isTouch or isMouse1 or isMouse2

		if isMouseWheel then
			-- Move the model closer to or farther from the camera
			self.positionOffset = self.positionOffset + Vector3.new(0, 0, inputObject.Position.Z) * WHEEL_ZOOM_SPEED
			self:updateModelCFrames()
		end

		if not isValidInputType then
			return
		end

		self.isRotating = true

		if isMouse1 then
			self.lastDragPosition = inputObject.Position
		end
		self.InputObjects[#self.InputObjects + 1] = inputObject
	end)

	self.inputChangedConnection = InputCapture.InputChanged:Connect(function(inputObject, gameProcessed)
		if self.model == nil then
			return
		end

		if gameProcessed then
			return
		end

		--if self.manager.isCameraLocked or self.manager.InputManager:IsLocked() then
			-- We should not rotate/pan the camera while another system (brush or sticker tool) has locked input.
		--	return
		--end

		local isTouch, isMouse, isMouse1, isMouse2, isMouseMovement, isMouseWheel = self:splitInputType(inputObject)
		local isValidInputType = isMouse or isTouch
		if not isValidInputType then
			return
		end

		if isMouseWheel then
			-- Move the model closer to or farther from the camera
			self.positionOffset = self.positionOffset + Vector3.new(0, 0, inputObject.Position.Z) * WHEEL_ZOOM_SPEED
			self:updateModelCFrames()
		end

		local delta = inputObject.Delta
		-- Single-touch = rotation
		if #self.InputObjects == 1 then
			-- For some reason, delta is always 0 for mouse click+drag.
			if delta.Magnitude == 0 and self.lastDragPosition ~= nil then
				delta = inputObject.Position - self.lastDragPosition
				self.lastDragPosition = inputObject.Position
			end

			local degreesRotationX = delta.X * DEGREES_PER_PIXEL
			local degreesRotationY = delta.Y * DEGREES_PER_PIXEL
			self.rotationX += degreesRotationX
			self.rotationY += degreesRotationY

			self.rotationY = math.clamp(self.rotationY, -self.maxRotationY, self.maxRotationY)
			self:_rotateModel()
		-- Multi-touch = pan
		elseif #self.InputObjects > 1 then
			-- Multi-touch pan
			self.positionOffset = self.positionOffset + Vector3.new(delta.X, -delta.Y, 0) * PAN_SPEED
			self:updateModelCFrames()
		end
	end)

	self.inputEndedConnection = InputCapture.InputEnded:Connect(function(inputObject, _gameProcessed)

		for i, input in pairs(self.InputObjects) do
			if input == inputObject then
				table.remove(self.InputObjects, i)
				break
			end
		end

		self.isRotating = false
	end)

	self.touchPinchConnection = UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state, _gameProcessed)
		if touchPositions[2] == nil then
			return
		end

		if self.manager.isCameraLocked then
			return
		end

		if state == Enum.UserInputState.Begin then
			self.lastPinchDistance = (touchPositions[1] - touchPositions[2]).Magnitude
			return
		end

		local pinchDistance = (touchPositions[1] - touchPositions[2]).Magnitude
		local deltaPinch = pinchDistance - self.lastPinchDistance
		self.lastPinchDistance = pinchDistance

		self.positionOffset = self.positionOffset + Vector3.new(0, 0, deltaPinch * PINCH_DELTA_TO_ZOOM_DELTA)
		self:updateModelCFrames()
	end)
end

function ModelDisplay:updateBoundingBox()
	if self.model ~= nil and self.model.PrimaryPart ~= nil then
		self.AccessoryBoundingBox.Position = self.model.PrimaryPart.Position
		self.AccessoryBoundingBox.Orientation = self.model.PrimaryPart.Orientation
	end
	
	self.AccessoryBoundingBox.Size = Vector3.new(2, 7, 2)
end

function ModelDisplay:_rotateModel()
	if self.model == nil or self.model.PrimaryPart == nil then
		return
	end

	local currentCFrame = self.model.PrimaryPart.CFrame
	local currentPos = currentCFrame.Position
	local startOrientation = self.originalCFrame.Rotation
	local newCFrame = CFrame.new(currentPos.X, currentPos.Y, currentPos.Z) * startOrientation * CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)

	local worldSpaceOffset = (newCFrame:PointToWorldSpace(self.localFocusPoint) - newCFrame.Position)
	local modelPos = self.globalFocusPoint - worldSpaceOffset

	newCFrame = CFrame.new(modelPos.X, modelPos.Y, modelPos.Z) * startOrientation * CFrame.Angles(math.rad(self.rotationY), math.rad(self.rotationX), 0)

	-- If we're currently focused on a point other than the center, move the model so that our focus point is where the center was
	self.model:SetPrimaryPartCFrame(newCFrame + self.positionOffset)

	self:updateBoundingBox()
end

-- Called when UI is shown in the middle of the screen, to ensure the model is still visible.
function ModelDisplay:MoveModelRight()
	self.positionOffset = Vector3.new(1, 0, 0)
	self:updateModelCFrames()
end

function ModelDisplay:MoveModelCenter()
	self.positionOffset = Vector3.new(0, 0, 0)
	self:updateModelCFrames()
end

function ModelDisplay:SetMaxTiltAngle(angle)
	self.maxRotationY = angle
end

function ModelDisplay:SetCameraSnapping(isCameraSnapEnabled)
	self.isCameraSnapEnabled = isCameraSnapEnabled
end

function ModelDisplay:GetBodyPartGroup(bodyPartName)
	for _, partNameList in EDIT_GROUPS do
		for _, partName in partNameList do
			if partName == bodyPartName then
				-- We need to highlight all grouped parts
				return partNameList
			end
		end
	end
	
	return nil
end

function ModelDisplay:AddHighlightToPart(part)
	local newHighlight = self.highlight:Clone()
	newHighlight.Parent = part
end

function ModelDisplay:HighlightParts(parent, partNames)
	for _, partName in partNames do
		local part = parent:FindFirstChild(partName, true)
		if part then
			self:AddHighlightToPart(part)
		end
	end
end

function ModelDisplay:ClearAllHighlights(parent)
	local highlight = parent:FindFirstChildWhichIsA("Highlight", true)
	while highlight ~= nil do
		highlight.Parent = nil
		highlight:Destroy()
		highlight = parent:FindFirstChildWhichIsA("Highlight", true)
	end
end

function ModelDisplay:OnEnteredPaintMode()
	self:ClearAllHighlights(self.model)
end

function ModelDisplay:OnExitedEditMode()
	-- Restore all parts to be visible
	for _, meshPart in pairs(self.model.MeshPart:GetChildren()) do
		meshPart.Transparency = 0
		meshPart.CanQuery = true
	end

	-- Revert model to start pos
	self.model:SetPrimaryPartCFrame(self.originalCFrame)
	self.localFocusPoint = Vector3.zero
	self.globalFocusPoint = self.model.PrimaryPart.CFrame.Position
	self:_rotateModel()

	self:ResetCamera()
end

function ModelDisplay:ResetCamera()
	-- Revert camera to start pos
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
	local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, {CFrame = self.defaultCameraCFrame})
	tween:Play()
end

function ModelDisplay:DestroyUI()
	self.ScreenGui:Destroy()
end

function ModelDisplay:Quit()
	self.inputBeganConnection:Disconnect()
	self.inputChangedConnection:Disconnect()
	self.inputEndedConnection:Disconnect()
	self.touchPinchConnection:Disconnect()
	
	self:ClearAllHighlights(self.model)
	self:DestroyUI()
	self.model:Destroy()
	self.AccessoryBoundingBox:Destroy()
end

return ModelDisplay
