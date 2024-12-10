local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Utils = require(Modules:WaitForChild("Utils"))

-- InputManager is what prevents different parts of the code from stealing input from others.
-- EG: The user is dragging a scaling handle and their mouse/finger moves too fast and goes off the handle button.
--   Previously, this would cause input to be grabbed by whatever was lying under the handle.
--   InputManager prevents this from happening by locking input while dragging.
local InputManager = {}
InputManager.__index = InputManager

function InputManager.new(cameraManager, modelDisplay)
	local self = {}
	setmetatable(self, InputManager)

	self.isLocked = false
	self.objectWithLock = nil

	-- setup interaction frame connections
	self.connections = {}
	self:SetUpInteractionFrame()
	self:InitializeCameraInteractions()

	self.connections["inputBegan"] = UserInputService.InputBegan:Connect(self.onInputBegan)
	self.connections["scrollConnection"] = self.screenGui.InputCapture.InputChanged:Connect(function(inputObject)
		self:HandleScroll(inputObject)
	end)

	self.connections["touchPinchConnection"] = UserInputService.TouchPinch:Connect(
		function(touchPositions, scale, velocity, state)
			self:OnTouchPinch(touchPositions, scale, velocity, state)
		end
	)

	self.cameraManager = cameraManager
	self.modelDisplay = modelDisplay

	self.activeTouchInputs = {}
	self.numActiveTouchInputs = 0
	self.activeMouseInput = nil

	self.numActiveInputs = 0

	-- for gamepad zoom and rotate
	self.storeInput = function(_actionName, inputState, inputObject)
		self.inputState = inputState
		self.inputObject = inputObject

		return Enum.ContextActionResult.Sink
	end

	self:SetUpGamepad()

	return self
end

function InputManager:TryGrabLock(grabber)
	if self.isLocked and self.objectWithLock ~= grabber then
		return false
	end

	self.isLocked = true
	self.objectWithLock = grabber
	return true
end

function InputManager:IsLocked()
	return self.isLocked
end

function InputManager:SetUpInteractionFrame()
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "CameraInputCapture"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 0
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = PlayerGui

	self.ScreenGui = self.screenGui

	local InputCapture = Instance.new("Frame")
	InputCapture.Name = "InputCapture"
	InputCapture.BackgroundTransparency = 1
	InputCapture.Size = UDim2.fromScale(1, 1)
	InputCapture.Parent = self.screenGui
end

local function splitInputType(inputObject)
	local isTouch = inputObject.UserInputType == Enum.UserInputType.Touch
	local isMouse1 = inputObject.UserInputType == Enum.UserInputType.MouseButton1
	local isMouse2 = inputObject.UserInputType == Enum.UserInputType.MouseButton2
	local isMouseMovement = inputObject.UserInputType == Enum.UserInputType.MouseMovement
	-- isMouse checks for mouse clicking
	local isMouse = isMouse1 or isMouse2

	return isTouch, isMouse, isMouse1, isMouse2, isMouseMovement
end

function InputManager:GetActiveInput(inputObject)
	local isTouch, isMouseButton = splitInputType(inputObject)
	local isMouseMovement = inputObject.UserInputType == Enum.UserInputType.MouseMovement
	local isMouse = isMouseMovement or isMouseButton

	if not (isMouse or isTouch) then
		return
	end

	local activeInput
	if isMouse then
		activeInput = self.activeMouseInput
	elseif isTouch then
		activeInput = self.activeTouchInputs[inputObject]
	end

	return activeInput
end

function InputManager:HandleScroll(inputObject)
	if self:IsLocked() then
		return
	end
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		self.cameraManager:ZoomToPoint(inputObject.Position.Z, UserInputService:GetMouseLocation())
	end
end

function InputManager:OnTouchPinch(touchPositions, scale, velocity, state)
	if touchPositions[2] == nil then
		return
	end

	if state == Enum.UserInputState.Begin then
		self.lastPinchDistance = (touchPositions[1] - touchPositions[2]).Magnitude
		return
	end
	local pinchDistance = (touchPositions[1] - touchPositions[2]).Magnitude
	local deltaPinch = pinchDistance - self.lastPinchDistance
	self.lastPinchDistance = pinchDistance
	self.cameraManager:ZoomToPoint(deltaPinch, (touchPositions[1] + touchPositions[2]) / 2, true)
end

function InputManager:InitializeCameraInteractions()
	self.onInputBegan = function(inputObject, _gameProcessed)
		local isTouch, isMouse, isMouse1, _isMouse2 = splitInputType(inputObject)
		local isValidInputType = isTouch or isMouse

		if not isValidInputType then
			return
		end

		local time = tick()
		if isMouse1 then
			self.lastDragPosition = inputObject.Position
		end

		self:AddActivePointerInput(inputObject, isMouse, time)
	end

	self.onInputChanged = function(inputObject, gameProcessedEvent)
		if self:IsLocked() or gameProcessedEvent then
			return
		end
		local isTouch, _isMouse, _isMouse1, _isMouse2, isMouseMovement = splitInputType(inputObject)
		local isValidInputType = isMouseMovement or isTouch

		if not isValidInputType then
			return
		end
		local activeInput = self:GetActiveInput(inputObject)
		if not activeInput then
			return
		end
		local time = tick()
		local deltaPosition = inputObject.Position - activeInput.lastPosition
		local deltaPosition2D = Vector2.new(deltaPosition.X, deltaPosition.Y) * Vector2.new(-1, 1)
		local mouse1Pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		local mouse2Pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		--TODO test for touch
		-- Handle Panning
		if isMouseMovement and mouse2Pressed or isTouch and self.numActiveTouchInputs == 2 then
			local averageDeltaPosition2D = deltaPosition2D / self.numActiveInputs
			self.cameraManager:PanByPixels(averageDeltaPosition2D)
			self.lastPanTime = time
		-- Handle Rotation
		elseif isMouseMovement and mouse1Pressed or isTouch and self.numActiveTouchInputs == 1 then
			local delta = inputObject.Delta
			-- Single-touch = rotation
			if self.numActiveInputs == 1 then
				-- Delta is always 0 for mouse click+drag.
				if delta.Magnitude == 0 and self.lastDragPosition ~= nil then
					delta = inputObject.Position - self.lastDragPosition
					self.lastDragPosition = inputObject.Position
				end

				self.modelDisplay:RotateModelFromPixels(delta.X)
			end
		end

		-- Update activeInput fields
		activeInput.lastPosition = inputObject.Position
		activeInput.lastTime = time
	end

	self.onInputEnded = function(inputObject, _gameProcessedEvent)
		local isTouch, isMouse, _isMouse1, _isMouse2, _isMouseMovement = splitInputType(inputObject)
		local isValidInputType = isTouch or isMouse

		if not isValidInputType then
			return
		end

		local activeInput = self:GetActiveInput(inputObject)
		if not activeInput then
			return
		end

		self:RemoveActivePointerInput(inputObject, isMouse)
		if self.numActiveTouchInputs == 0 then
			self.isLocked = false
			self.objectWithLock = nil
		end
	end
end

function InputManager:AddActivePointerInput(inputObject, isMouse, time)
	if self:GetActiveInput(inputObject) then
		return
	end

	local activeInput = {
		lastPosition = inputObject.Position,
		lastTime = time,
	}

	if isMouse then
		self.activeMouseInput = activeInput
	else
		activeInput.lastDeltaTime = 0
		activeInput.lastDeltaPosition = Vector3.new(0, 0, 0)
		self.activeTouchInputs[inputObject] = activeInput
		self.numActiveTouchInputs = self.numActiveTouchInputs + 1
	end
	self.numActiveInputs = self.numActiveInputs + 1

	if self.numActiveInputs == 1 then
		self.connections["inputChanged"] = UserInputService.InputChanged:Connect(self.onInputChanged)
		self.connections["inputEnded"] = UserInputService.InputEnded:Connect(self.onInputEnded)
	end
end

function InputManager:DisconnectEvents()
	self.connections["inputChanged"]:Disconnect()
	self.connections["inputEnded"]:Disconnect()
	self.connections["inputChanged"] = nil
	self.connections["inputEnded"] = nil
end

function InputManager:RemoveActivePointerInput(inputObject, isMouse)
	if isMouse then
		local allMouseButtonsReleased = not (
			UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		)

		if allMouseButtonsReleased then
			self.activeMouseInput = nil
		else
			return
		end
	else
		self.activeTouchInputs[inputObject] = nil
		self.numActiveTouchInputs = self.numActiveTouchInputs - 1
	end
	self.numActiveInputs = self.numActiveInputs - 1

	if self.numActiveInputs == 0 then
		self:DisconnectEvents()
	end
end

function InputManager:SetUpGamepad()
	ContextActionService:UnbindAction("RotateAndZoom")
	ContextActionService:BindAction("RotateAndZoom", self.storeInput, false, Enum.KeyCode.Thumbstick2)
	local rotateByDegrees = function(degrees)
		self.modelDisplay:RotateModelFromDegrees(degrees)
	end
	local zoomStraight = function(zoomDelta)
		self.cameraManager:ZoomToPoint(-zoomDelta, self.modelDisplay:GetScreenPosition())
	end
	local gamePadConnection = RunService.RenderStepped:Connect(function(deltaTime)
		if self.inputState == Enum.UserInputState.Change and self.inputObject then
			Utils.rotateAndZoom(self.inputObject, deltaTime, rotateByDegrees, zoomStraight)
		end
	end)
	self.connections["gamePadConnection"] = gamePadConnection
end

function InputManager:Destroy()
	for i, connection in self.connections do
		if connection then
			connection:Disconnect()
			self.connections[i] = nil
		end
	end
	ContextActionService:UnbindAction("RotateAndZoom")

	self.screenGui:Destroy()
end

return InputManager
