local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")

local inputUtils = {}

-- deadzone is the distance from the center of the thumbstick that the thumbstick has to move before it registers
local THUMBSTICK_DEADZONE = 0.2
local MAX_ZOOM_SPEED = 10
local MIN_AXIS_THRESHOLD = 0.5
local MAX_STICK_ANGULAR_SPEED = math.rad(140) -- Radians per second

local gamepadInputTypes = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true,
}

-- Handles thumbstick deadzones for gamepad support
function inputUtils.normalizeStickByDeadzone(stickVector: Vector2)
	local magnitude = stickVector.Magnitude
	if magnitude < THUMBSTICK_DEADZONE then
		return Vector2.new(0, 0)
	else
		return (magnitude - THUMBSTICK_DEADZONE) / (1 - THUMBSTICK_DEADZONE) * stickVector.Unit
	end
end

function inputUtils.rotateAndZoom(
	inputObject: InputObject,
	deltaTime: number,
	rotateByDegrees: ((number, number) -> ())?,
	zoomStraight: ((number) -> ())?
)
	local stickInput = inputUtils.normalizeStickByDeadzone(Vector2.new(inputObject.Position.X, inputObject.Position.Y))
	if stickInput == Vector2.new(0, 0) then
		return
	end

	if
		rotateByDegrees and (math.abs(stickInput.X) > MIN_AXIS_THRESHOLD or math.abs(stickInput.Y) > MIN_AXIS_THRESHOLD)
	then
		local radiansToDegrees = 180 / math.pi
		local degreesX = deltaTime * stickInput.X * MAX_STICK_ANGULAR_SPEED * radiansToDegrees
		local degreesY = deltaTime * stickInput.Y * MAX_STICK_ANGULAR_SPEED * radiansToDegrees
		rotateByDegrees(degreesX, degreesY)
	end

	if zoomStraight and math.abs(stickInput.Y) > MIN_AXIS_THRESHOLD then
		zoomStraight(deltaTime * -stickInput.Y * MAX_ZOOM_SPEED)
	end
end

function inputUtils.isGamepadInputType(userInputType: Enum.UserInputType): boolean
	return userInputType and gamepadInputTypes[userInputType] == true
end

function inputUtils.isVirtualCursor(userInputType: Enum.UserInputType): boolean
	return inputUtils.isGamepadInputType(userInputType) and GamepadService.GamepadCursorEnabled
end

function inputUtils.isValidDraggingInput(input: InputObject)
	return (
		input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.MouseMovement
		or input.KeyCode == Enum.KeyCode.Thumbstick1
	)
end

function inputUtils.isValidSelectingInput(input: InputObject)
	return (
		input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1
		or input.KeyCode == Enum.KeyCode.ButtonA
	)
end

function inputUtils.getInputPosition(input: InputObject)
	local guiInset = GuiService:GetGuiInset()
	if input.UserInputType == Enum.UserInputType.Touch then
		return input.Position
	else
		return UserInputService:GetMouseLocation() - guiInset
	end
end

return inputUtils
