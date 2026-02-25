local InGameSetup = script.Parent.Parent
local RunAvatarSceneManager = require(InGameSetup.Actions.RunAvatarSceneManager)

return function(state, action)
	state = state or false

	if action.type == RunAvatarSceneManager.name then
		return action.run
	end

	return state
end