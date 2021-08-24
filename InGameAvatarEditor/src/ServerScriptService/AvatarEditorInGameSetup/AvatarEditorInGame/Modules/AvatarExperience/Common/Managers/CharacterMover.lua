local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AppPage = require(Modules.NotLApp.AppPage)

local FFlagDontRotateCharacterWhenInputSunk = true

local ToggleAvatarEditor3DFullView = require(Modules.AvatarExperience.AvatarEditor.Thunks.Toggle3DFullView)
local ToggleCatalog3DFullView = require(Modules.AvatarExperience.Catalog.Thunks.Toggle3DFullView)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)


local CharacterMover = {}
CharacterMover.__index = CharacterMover

local ROTATIONAL_INERTIA = 0.9
local CHARACTER_ROTATION_SPEED = 0.0065
local INITIAL_CHARACTER_OFFSET = 0.6981 + (-115.85) -- Offset + Initial HRP orientation

local DOUBLETAP_THRESHOLD = 0.25
local TAP_DISTANCE_THRESHOLD = 30

local STICK_ROTATION_MULTIPLIER = 3
local THUMBSTICK_DEADZONE = 0.2

local SWIM_ROTATION = -math.rad(60)
local SWIM_ROTATION_SPEED = 0.04

local STICK_ROTATION_ACTION = "AvatarSceneCharacterMoverStickRotation"

function CharacterMover.new(store)
	local self = {}
	setmetatable(self, CharacterMover)

	self.connections = {}
	self.store = store

	self.mouseDown = false
	self.keyboardDown = false

	self.keysDown = {}
	self.numKeysDown = 0

	self.lastTouchInput = 0
	self.lastTouchPosition = Vector3.new(0, 0, 0)

	self.xRotation = 0
	self.yRotation = 0
	self.delta = 0
	self.goal = 0
	self.rotationDelta = 0
	self.rotationalMomentum = 0

	self.lastRotation = 0
	self.lastEmptyInput = 0
	self.lastInputPosition = Vector3.new(0, 0, 0)

	self.rotatingManually = false
	self.gamepadRotating = false

	return self
end

function CharacterMover:start()
	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	self.connections[#self.connections + 1] = storeChangedConnection

	local inputBeganConnection = UserInputService.InputBegan:connect(function(input, gameProcessedEvent)
		self:inputBegan(input, gameProcessedEvent)
	end)
	self.connections[#self.connections + 1] = inputBeganConnection

	local inputChangedConnection = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
		self:inputChanged(input, gameProcessedEvent)
	end)
	self.connections[#self.connections + 1] = inputChangedConnection

	local inputEndedConnection = UserInputService.InputEnded:connect(function(input, gameProcessedEvent)
		self:inputEnded(input, gameProcessedEvent)
	end)
	self.connections[#self.connections + 1] = inputEndedConnection

	local inputTypeChangedConnection = UserInputService.LastInputTypeChanged:connect(function(lastInputType)
		self:onLastInputTypeChanged(lastInputType)
	end)
	self.connections[#self.connections + 1] = inputTypeChangedConnection

	self:onLastInputTypeChanged(UserInputService:GetLastInputType())
	self:handleGamepad()

	self.alreadyRotating = false
end

function CharacterMover:update(newState, oldState)
	local newPlayingSwimAnimation = newState.AvatarExperience.AvatarScene.Character.PlayingSwimAnimation
	local oldPlayingSwimAnimation = oldState.AvatarExperience.AvatarScene.Character.PlayingSwimAnimation

	if newPlayingSwimAnimation ~= oldPlayingSwimAnimation then
		self:setSwimRotation(newPlayingSwimAnimation)
	end
end

function CharacterMover:setSwimRotation(swimming)
	self.swimming = swimming
	if self.swimming then
		self.goal = SWIM_ROTATION
	else
		self.goal = 0.0
	end

	self.rotatingForSwim = true
	self:rotate()
end

function CharacterMover:setRotation()
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	if not currentCharacter then
		return
	end

	local hrp = currentCharacter.HumanoidRootPart
	hrp.CFrame = CFrame.new(hrp.CFrame.p)
		* CFrame.Angles(0, INITIAL_CHARACTER_OFFSET + self.yRotation, 0)
		* CFrame.Angles(self.xRotation, 0, 0)
end

function CharacterMover:processKeyDown(input)
	if self.keysDown[input.KeyCode] then
		return
	end

	self.keysDown[input.KeyCode] = true
	self.numKeysDown = self.numKeysDown + 1

	self.keyboardDown = true

	if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
		self.rotationDelta = self.rotationDelta - math.rad(180)
	elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
		self.rotationDelta = self.rotationDelta + math.rad(180)
	end
end

function CharacterMover:processKeyUp(input)
	if not self.keysDown[input.KeyCode] then
		return
	end

	self.keysDown[input.KeyCode] = nil
	self.numKeysDown = self.numKeysDown - 1

	if self.numKeysDown == 0 then
		self.keyboardDown = false
	end

	if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
		self.rotationDelta = self.rotationDelta + math.rad(180)
	elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
		self.rotationDelta = self.rotationDelta - math.rad(180)
	end
end

function CharacterMover:shouldBeRotating()
	if self.rotatingManually or math.abs(self.rotationalMomentum) > 0.001
		or self.rotatingForSwim or self.gamepadRotating then
		return true
	else
		return false
	end
end

function CharacterMover:rotate()
	-- If this function has already spawned, don't spawn another.
	if self.alreadyRotating then
		return
	end

	self.alreadyRotating = true
	spawn(function()
		while self:shouldBeRotating() do
			if self.lastTouchInput then
				self.rotationalMomentum = self.yRotation - self.lastRotation
			elseif self.rotationalMomentum ~= 0 then
				self.rotationalMomentum = self.rotationalMomentum * ROTATIONAL_INERTIA
				if math.abs(self.rotationalMomentum) < .001 then
					self.rotationalMomentum = 0
				end

				self.yRotation = self.yRotation + self.rotationalMomentum
			end

			if self.gamepadRotating or self.keyboardDown then
				self.yRotation = self.yRotation + self.delta * self.rotationDelta
			end

			-- Rotate the character to/from swim position
			if not self.swimming and self.xRotation < self.goal then
				self.xRotation = self.xRotation + SWIM_ROTATION_SPEED
			elseif self.swimming and self.xRotation > self.goal then
				self.xRotation = self.xRotation - SWIM_ROTATION_SPEED
			else
				self.xRotation = self.goal
				self.rotatingForSwim = false
			end

			self:setRotation()
			self.lastRotation = self.yRotation

			self.delta = RunService.RenderStepped:wait()
		end
		self.alreadyRotating = false
	end)
end

function CharacterMover:inputBegan(input, gameProcessedEvent)
	self.rotatingManually = true
	self:rotate()

	if gameProcessedEvent then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.mouseDown = true
		self.lastTouchInput = input
		self.lastTouchPosition = input.Position
	elseif input.UserInputType == Enum.UserInputType.Touch then
		self.lastTouchInput = input
		self.lastTouchPosition = input.Position
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		self:processKeyDown(input)
	end
end

function CharacterMover:inputChanged(input, gameProcessedEvent)
	local isTouchMove = self.lastTouchInput == input and input.UserInputType == Enum.UserInputType.Touch
	local isMouseMove = self.mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement

	if FFlagDontRotateCharacterWhenInputSunk and gameProcessedEvent then
		return
	end

	if isTouchMove or isMouseMove then
		local moveDelta = (input.Position - self.lastTouchPosition)
		self.lastTouchPosition = input.Position
		self.yRotation = self.yRotation + moveDelta.X * CHARACTER_ROTATION_SPEED

		if self.lastTouchInput and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			self.rotationalMomentum = self.yRotation - self.lastRotation
		end
	end
end

function CharacterMover:inputEnded(input, gameProcessedEvent)
	self.mouseDown = false

	if input.UserInputType == Enum.UserInputType.Keyboard then
		self:processKeyUp(input)
	end

	if not self.mouseDown and not self.keyboardDown then
		self.rotatingManually = false
	end

	if self.lastTouchInput == input or input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.lastTouchInput = nil
	end

	if gameProcessedEvent then
		return
	end

	-- Check if the user double tapped based on distance and time apart.
	local isTouchInput = input.UserInputType == Enum.UserInputType.Touch
	local isMouse1 = input.UserInputType == Enum.UserInputType.MouseButton1
	local isTapInput = isTouchInput or isMouse1

	if AvatarExperienceUtils.doubleTapToZoomEnabled(self.store:getState()) and isTapInput then
		local thisEmptyInput = tick()

		if (self.lastInputPosition and self.lastInputPosition - input.Position).magnitude <= TAP_DISTANCE_THRESHOLD
			and thisEmptyInput - self.lastEmptyInput <= DOUBLETAP_THRESHOLD then
			self:activateFullView()
		end

		self.lastEmptyInput = thisEmptyInput
		self.lastInputPosition = input.Position
	end
end

function CharacterMover:activateFullView()
	local appPage = AvatarExperienceUtils.getCurrentPage(self.store:getState())
	if appPage == AppPage.ItemDetails then
		appPage = AvatarExperienceUtils.getParentPage(self.store:getState())
	end

	if appPage == AppPage.AvatarEditor then
		self.store:dispatch(ToggleAvatarEditor3DFullView())
	elseif appPage == AppPage.Catalog or appPage == AppPage.SearchPage then
		self.store:dispatch(ToggleCatalog3DFullView())
	end
end

function CharacterMover:handleGamepad()
	if not UserInputService.GamepadEnabled then
		return
	end

	local gamepadInput = Vector2.new(0, 0)

	ContextActionService:UnbindAction(STICK_ROTATION_ACTION)
	ContextActionService:BindAction(STICK_ROTATION_ACTION, function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Change then
			gamepadInput = inputObject.Position or gamepadInput
			gamepadInput = Vector2.new(gamepadInput.X, gamepadInput.Y)

			if math.abs(gamepadInput.X) > THUMBSTICK_DEADZONE then
				if not self.gamepadRotating then
					self:rotate()
				end

				self.gamepadRotating = true
				self.rotationDelta = STICK_ROTATION_MULTIPLIER * gamepadInput.X
			else
				self.gamepadRotating = false
				self.rotationDelta = 0
			end
		end
	end, --[[ createTouchButton = ]] false, Enum.KeyCode.Thumbstick2)
end

function CharacterMover:onLastInputTypeChanged(inputType)
	local isGamepad = inputType.Name:find("Gamepad")

	if isGamepad and UserInputService.MouseIconEnabled then
		UserInputService.MouseIconEnabled = false
	elseif not isGamepad and not UserInputService.MouseIconEnabled then
		UserInputService.MouseIconEnabled = true
	end
end

function CharacterMover:stop()
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}

	ContextActionService:UnbindAction(STICK_ROTATION_ACTION)
	self.rotatingManually = false
end

function CharacterMover:onDestroy()
end

return CharacterMover
