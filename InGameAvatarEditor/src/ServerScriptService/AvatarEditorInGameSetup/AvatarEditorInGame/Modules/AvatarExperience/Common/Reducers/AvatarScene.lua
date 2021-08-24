local Reducers = script.Parent
local Character = require(Reducers.Character)
local TryOn = require(Reducers.TryOn)

return function(state, action)
	state = state or {}

	return {
		Character = Character(state.Character, action),
		TryOn = TryOn(state.TryOn, action),
	}
end