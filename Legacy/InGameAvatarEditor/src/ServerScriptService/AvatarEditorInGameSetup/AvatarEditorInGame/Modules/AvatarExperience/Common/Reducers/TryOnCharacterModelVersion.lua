local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local IncrementTryOnCharacterModelVersion =
	require(Modules.AvatarExperience.Catalog.Actions.IncrementTryOnCharacterModelVersion)

return Rodux.createReducer(0, {
	[IncrementTryOnCharacterModelVersion.name] = function(state, action)
		return state + 1
	end,
})