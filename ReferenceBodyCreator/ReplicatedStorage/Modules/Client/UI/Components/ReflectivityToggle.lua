--[[
	Toggle for enabling PBR coloring in texture editing modes
]]

local UI = script.Parent.Parent
local Components = UI:WaitForChild("Components")
local ToggleButton = require(Components:WaitForChild("ToggleButton"))

local REFLECTIVITY_TOGGLE_LABEL = "Reflective Effect"

local ReflectivityToggle = {}

function ReflectivityToggle.createComponentFrame(
	onReflectiveModeChanged: (isReflective: boolean) -> (),
	initialOn: boolean?
)
	return ToggleButton.createComponentFrame({
		label = REFLECTIVITY_TOGGLE_LABEL,
		initialOn = initialOn,
		callback = function(isOn: boolean)
			if onReflectiveModeChanged then
				onReflectiveModeChanged(isOn)
			end
		end,
	})
end

return ReflectivityToggle
