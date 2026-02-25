local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local IncrementCharacterModelVersion =
	require(Modules.AvatarExperience.AvatarEditor.Actions.IncrementCharacterModelVersion)

return Rodux.createReducer(0, {
	[IncrementCharacterModelVersion.name] = function(state, action)
		return state + 1
	end,
})