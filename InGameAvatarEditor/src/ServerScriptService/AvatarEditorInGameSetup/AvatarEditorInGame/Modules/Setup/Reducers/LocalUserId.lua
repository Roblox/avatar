local InGameSetup = script.Parent.Parent
local SetLocalUserId = require(InGameSetup.Actions.SetLocalUserId)

return function(state, action)
	state = state or ""

	if action.type == SetLocalUserId.name then
		return action.userId
	end

	return state
end