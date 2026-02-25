local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local SetDefaultBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultBodyColors)

local DefaultBodyColorsReducer = Rodux.createReducer({}, {
	[SetDefaultBodyColors.name] = function(state, action)
        return action.defaultBodyColors
    end,
})

return DefaultBodyColorsReducer