local InGameSetup = script.Parent.Parent
local Modules = InGameSetup.Parent
local Immutable = require(Modules.Common.Immutable)

local SetLastInputType = require(Modules.Setup.Actions.SetLastInputType)
local InputType = require(Modules.Setup.InputType)

local inputTypeMap = {
	[Enum.UserInputType.MouseButton1] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.MouseButton2] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.MouseButton3] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.MouseWheel] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.MouseMovement] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.Keyboard] = InputType.MouseAndKeyboard,
	[Enum.UserInputType.TextInput] = InputType.MouseAndKeyboard,

	[Enum.UserInputType.Gamepad1] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad2] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad3] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad4] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad5] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad6] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad7] = InputType.Gamepad,
	[Enum.UserInputType.Gamepad8] = InputType.Gamepad,

	[Enum.UserInputType.Touch] = InputType.Touch,

	[Enum.UserInputType.None] = InputType.None,
}

return function(state, action)
	state = state or {
		lastInputType = Enum.UserInputType.None,
		lastInputGroup = InputType.None,
	}

	if action.type == SetLastInputType.name then
		state = {
			lastInputType = action.lastInputType,
			lastInputGroup = inputTypeMap[action.lastInputType] or InputType.None,
		}
	end

	return state
end
