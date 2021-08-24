local Players = game:GetService("Players")
local UserInputService = game:GetService('UserInputService')

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Otter = require(Modules.Packages.Otter)
local Roact = require(Modules.Packages.Roact)
local RoactGamepad = require(Modules.Packages.RoactGamepad)
local Focusable = RoactGamepad.Focusable
local UIBlox = require(Modules.Packages.UIBlox)
local t = require(Modules.Packages.t)
local Utils = require(Modules.AvatarExperience.Common.Utils)

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local Images = UIBlox.App.ImageSet.Images
local Colors = UIBlox.App.Style.Colors
local withStyle = UIBlox.Style.withStyle

local FFlagAvatarExperienceSliderFixes = true

local DPAD_INITIAL_MOVE_INTERVAL = 0.2
local DPAD_SPEED = 8 -- In increments per second
local STICK_MAX_SPEED = 1 -- In percent of slider size per second

local BASE_EXTENSION_SCALE = 0.51

local KNOB_SHADOW_IMAGE = Images["component_assets/dropshadow_28"]
local KNOB_IMAGE = Images["component_assets/circle_29"]

local KNOB_DEFAULT_COLOR = Colors.White
local KNOB_PRESSED_COLOR = Colors.Pumice
local KNOB_DISABLED_COLOR = Colors.Pumice
local KNOB_DEFAULT_TRANSPARENCY = 0
local KNOB_DISABLED_TRANSPARENCY = 0.5
local KNOB_SHADOW_DEFAULT_TRANSPARENCY = 0.7
local KNOB_SHADOW_PRESSED_TRANSPARENCY = 1
local KNOB_SHADOW_HOVERED_TRANSPARENCY = 0.5
local KNOB_SHADOW_DISABLED_TRANSPARENCY = 1
local SPRING_PARAMETERS = {
	frequency = 5,
}

local TwoAxisSlider = Roact.PureComponent:extend("TwoAxisSlider")

TwoAxisSlider.validateProps = t.strictInterface({
	mapPositionToScales = t.callback, -- (Vector2) -> number, number
	mapScalesToPosition = t.callback, -- (number, number) -> Vector2
	setScales = t.callback, -- (number, number) -> nil
	xScaleRules = t.table,
	yScaleRules = t.table,
	xScale = t.number,
	yScale = t.number,

	getBackgroundAbsolutePosition = t.callback, -- () -> Vector2
	getBackgroundAbsoluteSize = t.callback, -- () -> Vector2

	invertDPadX = t.optional(t.boolean),
	invertDPadY = t.optional(t.boolean),

	isDisabled = t.optional(t.boolean),

	onDragStart = t.optional(t.callback), -- () -> nil
	onDragEnd = t.optional(t.callback), -- () -> nil
})

function TwoAxisSlider:disconnectDragConnections()
	if self.dragChangeListen then
		self.dragChangeListen:Disconnect()
		self.dragChangeListen = nil
	end
	if self.dragEndListen then
		self.dragEndListen:Disconnect()
		self.dragEndListen = nil
	end
end

function TwoAxisSlider:init()
	self.dragChangeListen = nil
	self.dragEndListen = nil

	self.knobRef = Roact.createRef()
	self.selectionObjectRef = Roact.createRef()

	self.totalMoveTime = 0
	self.unhandledTime = 0
	self.firstMove = true
	self.state = {
		gamepadActive = false,
	}

	local pressedProgress, setPressedProgress = Roact.createBinding(0)
	local hoveredProgress, setHoveredProgress = Roact.createBinding(0)

	local interactionProgress = Roact.joinBindings({
		pressed = pressedProgress,
		hovered = hoveredProgress,
	})

	self.knobColorMapping = pressedProgress:map(function(value)
		return KNOB_DEFAULT_COLOR:lerp(KNOB_PRESSED_COLOR, value)
	end)
	self.knobShadowTransparencyMapping = interactionProgress:map(function(values)
		local baseTarget = Utils.lerp(KNOB_SHADOW_DEFAULT_TRANSPARENCY, KNOB_SHADOW_HOVERED_TRANSPARENCY, values.hovered)
		return Utils.lerp(baseTarget, KNOB_SHADOW_PRESSED_TRANSPARENCY, values.pressed)
	end)

	self.pressedMotor = Otter.createSingleMotor(0)
	self.pressedMotor:onStep(setPressedProgress)
	self.hoveredMotor = Otter.createSingleMotor(0)
	self.hoveredMotor:onStep(setHoveredProgress)

	self.mouseEnter = function()
		self.hoveredMotor:setGoal(Otter.spring(1, SPRING_PARAMETERS))
	end

	self.mouseLeave = function()
		self.hoveredMotor:setGoal(Otter.spring(0, SPRING_PARAMETERS))
	end

	self.nonGamepadInputChanged = function(inputObject)
		if not (inputObject.UserInputType == Enum.UserInputType.MouseMovement
			or inputObject.UserInputType == Enum.UserInputType.Touch) then
			return
		end

		local backgroundPos = self.props.getBackgroundAbsolutePosition()
		local backgroundSize = self.props.getBackgroundAbsoluteSize()
		if backgroundPos and backgroundSize then
			local inputPos = inputObject.Position
			local relativeInputPos = Vector2.new(
				(inputPos.X - backgroundPos.X) / backgroundSize.X,
				(inputPos.Y - backgroundPos.Y) / backgroundSize.Y)

			self.props.setScales(self.props.mapPositionToScales(relativeInputPos))
		end
	end

	self.nonGamepadInputEnded = function(inputObject)
		if not (inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch) then
			return
		end

		if self.props.onDragEnd then
			self.props.onDragEnd()
		end

		self:disconnectDragConnections()
		self.pressedMotor:setGoal(Otter.spring(0, SPRING_PARAMETERS))
	end

	self.nonGamepadInputBegan = function(rbx, inputObject)
		local isValidInputType =
			(not FFlagAvatarExperienceSliderFixes or inputObject.UserInputState == Enum.UserInputState.Begin)
			and (inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch)

		if self.props.isDisabled or self.dragChangeListen or not isValidInputType then
			return
		end

		if self.props.onDragStart then
			self.props.onDragStart()
		end
		self.dragChangeListen = UserInputService.InputChanged:connect(self.nonGamepadInputChanged)
		self.dragEndListen = UserInputService.InputEnded:connect(self.nonGamepadInputEnded)
		self.pressedMotor:setGoal(Otter.spring(1, SPRING_PARAMETERS))
	end

	self.disableGamepadInput = function()
		self:setState({gamepadActive = false})
	end

	self.onAPressed = function(inputObject)
		if self.state.gamepadActive then
			self:setState({gamepadActive = false})
		elseif not self.props.isDisabled then
			self:setState({gamepadActive = true})
		end
	end

	self.moveSlider = function(inputObjects, deltaTime)
		local stickPosition = Utils.normalizeStickByDeadzone(inputObjects[Enum.KeyCode.Thumbstick1].Position)
		local usingStick = stickPosition ~= Vector2.new(0, 0)

		local dPadLeftMovement = inputObjects[Enum.KeyCode.DPadLeft].Position.z == 1 and -1 or 0
		local dPadRightMovement = inputObjects[Enum.KeyCode.DPadRight].Position.z == 1 and 1 or 0
		local dPadUpMovement = inputObjects[Enum.KeyCode.DPadUp].Position.z == 1 and 1 or 0
		local dPadDownMovement = inputObjects[Enum.KeyCode.DPadDown].Position.z == 1 and -1 or 0
		local dPadMoveDirection = Vector2.new(dPadLeftMovement + dPadRightMovement, dPadUpMovement + dPadDownMovement)

		local xScale = self.props.xScale
		local yScale = self.props.yScale
		local newXScale = xScale
		local newYScale = yScale

		if usingStick then
			self.totalMoveTime = self.totalMoveTime + deltaTime

			-- Stick movement may be unaligned with increment grid
			local currentPosition = self.props.mapScalesToPosition(xScale, yScale)
			local adjustedMoveDirection = Vector2.new(stickPosition.x, -stickPosition.y)
			newXScale, newYScale = self.props.mapPositionToScales(
				currentPosition + adjustedMoveDirection * STICK_MAX_SPEED * deltaTime)

			self.unhandledTime = 0
			self.firstMove = false
		elseif dPadMoveDirection ~= Vector2.new(0, 0) then
			self.totalMoveTime = self.totalMoveTime + deltaTime

			-- Calculate increments
			local increments
			if self.firstMove then
				increments = 1
				self.unhandledTime = 0
				self.firstMove = false
			elseif self.totalMoveTime > DPAD_INITIAL_MOVE_INTERVAL then
				-- How much of delta time that was in the first interval
				local initialIntervalOverlap = math.max(DPAD_INITIAL_MOVE_INTERVAL - (self.totalMoveTime - deltaTime), 0)

				local timeToHandle = deltaTime - initialIntervalOverlap + self.unhandledTime
				increments = math.floor(DPAD_SPEED * timeToHandle)

				self.unhandledTime = timeToHandle - increments / DPAD_SPEED
			else -- Period between first move and subsequent moves
				increments = 0
				self.unhandledTime = 0
			end

			local inversion = Vector2.new(self.props.invertDPadX and -1 or 1, self.props.invertDPadY and -1 or 1)
			local extensionScale = increments - 1 + BASE_EXTENSION_SCALE

			-- D-Pad movement must be aligned with increment grid
			if dPadMoveDirection.x == 0 then
				newXScale = xScale
			else
				local xScaleRules = self.props.xScaleRules
				local xExtension = xScale + dPadMoveDirection.x * inversion.x * xScaleRules.increment * extensionScale
				local roundedXExtension = xScaleRules.min + Utils.Round(
					xExtension - xScaleRules.min, xScaleRules.increment)
				newXScale = math.clamp(roundedXExtension, xScaleRules.min, xScaleRules.max)
			end

			if dPadMoveDirection.y == 0 then
				newYScale = yScale
			else
				local yScaleRules = self.props.yScaleRules
				local yExtension = yScale + dPadMoveDirection.y * inversion.y * yScaleRules.increment * extensionScale
				local roundedYExtension = yScaleRules.min + Utils.Round(
					yExtension - yScaleRules.min, yScaleRules.increment)
				newYScale = math.clamp(roundedYExtension, yScaleRules.min, yScaleRules.max)
			end
		else
			self.totalMoveTime = 0
			self.unhandledTime = 0
			self.firstMove = true
		end

		if newXScale ~= xScale or newYScale ~= yScale then
			self.props.setScales(newXScale, newYScale)
		end
	end
end

function TwoAxisSlider:render()
	local gamepadActive = self.state.gamepadActive
	local isDisabled = self.props.isDisabled
	local xScale = self.props.xScale
	local yScale = self.props.yScale
	local sliderPosition = self.props.mapScalesToPosition(xScale, yScale)

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		return Roact.createFragment({
			Knob = Roact.createElement(Focusable[ImageSetLabel], {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(sliderPosition.X, 0, sliderPosition.Y, 0),
				Size = UDim2.fromOffset(30, 30),
				Image = KNOB_IMAGE,
				ImageColor3 = isDisabled and KNOB_DISABLED_COLOR or self.knobColorMapping,
				ImageTransparency = isDisabled and KNOB_DISABLED_TRANSPARENCY or KNOB_DEFAULT_TRANSPARENCY,
				Active = true,
				BackgroundTransparency = 1,
				ZIndex = 2,

				[Roact.Event.InputBegan] = self.nonGamepadInputBegan,
				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseLeave] = self.mouseLeave,

				[Roact.Ref] = self.knobRef,

				onFocusLost = self.disableGamepadInput,
				-- Replace keys with input strings when the controller bar is implemented
				inputBindings = {
					ToggleGamepadInput = RoactGamepad.Input.onBegin(Enum.KeyCode.ButtonA, self.onAPressed),
					DisableGamepadInput = gamepadActive
						and RoactGamepad.Input.onBegin(Enum.KeyCode.ButtonB, self.disableGamepadInput) or nil,

					MoveSlider = gamepadActive and RoactGamepad.Input.onMoveStep(self.moveSlider) or nil,
				},
				NextSelectionLeft = gamepadActive and self.knobRef or nil,
				NextSelectionRight = gamepadActive and self.knobRef or nil,
				NextSelectionUp = gamepadActive and self.knobRef or nil,
				NextSelectionDown = gamepadActive and self.knobRef or nil,
			}),

			KnobShadow = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(sliderPosition.X, 0, sliderPosition.Y, 0),
				Size = UDim2.new(0, 48, 0, 48),
				Image = KNOB_SHADOW_IMAGE,
				ImageTransparency = isDisabled and KNOB_SHADOW_DISABLED_TRANSPARENCY or self.knobShadowTransparencyMapping,
				Active = true,
				BackgroundTransparency = 1,
				ZIndex = 1,
			}),
		})
	end)
end

function TwoAxisSlider:willUnmount()
	self:disconnectDragConnections()
	self.pressedMotor:destroy()
	self.hoveredMotor:destroy()
end

return TwoAxisSlider
