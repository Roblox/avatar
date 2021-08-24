local InGameSetup = script.Parent.Parent
local Modules = InGameSetup.Parent
local Immutable = require(Modules.Common.Immutable)

local SetUserRobux = require(Modules.NotLApp.Actions.SetUserRobux)

return function(state, action)
	state = state or {}

	if action.type == SetUserRobux.name then
		state = Immutable.Set(state, action.userId, action.robux)
	end

	return state
end
