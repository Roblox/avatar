local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local ToggleUIFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleUIFullView)

local UIFullView = Rodux.createReducer(false, {
	[ToggleUIFullView.name] = function(state, action)
		return not state
	end,
})

return UIFullView