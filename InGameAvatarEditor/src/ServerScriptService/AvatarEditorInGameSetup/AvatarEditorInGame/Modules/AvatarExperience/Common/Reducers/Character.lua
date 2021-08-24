local Reducers = script.Parent

local CurrentCharacter = require(Reducers.CurrentCharacter)
local PlayingSwimAnimation = require(Reducers.PlayingSwimAnimation)
local CharacterModelVersion = require(Reducers.CharacterModelVersion)
local TryOnCharacterModelVersion = require(Reducers.TryOnCharacterModelVersion)

return function(state, action)
	state = state or {}

	return {
		CurrentCharacter = CurrentCharacter(state.CurrentCharacter, action),
		PlayingSwimAnimation = PlayingSwimAnimation(state.PlayingSwimAnimation, action),
		CharacterModelVersion = CharacterModelVersion(state.CharacterModelVersion, action),
		TryOnCharacterModelVersion = TryOnCharacterModelVersion(state.TryOnCharacterModelVersion, action),
	}
end
