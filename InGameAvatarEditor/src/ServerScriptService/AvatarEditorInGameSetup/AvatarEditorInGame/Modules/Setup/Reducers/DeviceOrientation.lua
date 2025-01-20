local InGameSetup = script.Parent.Parent
local Modules = InGameSetup.Parent

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local SetDeviceOrientation = require(Modules.Setup.Actions.SetDeviceOrientation)

return function(state, action)
	state = state or DeviceOrientationMode.Landscape

	if action.type == SetDeviceOrientation.name then
		state = action.orienation
	end

	return state
end