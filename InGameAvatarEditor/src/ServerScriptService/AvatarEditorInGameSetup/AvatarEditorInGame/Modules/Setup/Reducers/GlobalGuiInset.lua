local InGameSetup = script.Parent.Parent
local SetGlobalGuiInset = require(InGameSetup.Actions.SetGlobalGuiInset)

return function(state, action)
	state = state or {
		left = 0,
		top = 36,
		right = 0,
		bottom = 0,
	}

	if action.type == SetGlobalGuiInset.name then
		return {
			left = action.left,
			top = action.top,
			right = action.right,
			bottom = action.bottom,
		}
	end

	return state
end