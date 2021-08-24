local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local SetAvatarSettings = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarSettings)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

local initialState = {
    ObtainedAvatarRules = false,
    [AvatarEditorConstants.AvatarSettings.minDeltaBodyColorDifference] = 0,
    [AvatarEditorConstants.AvatarSettings.scalesRules] = {
        height = {
            min = 0.9,
            max = 1.05,
            increment = 0.01,
        },
        width = {
            min = 0.7,
            max = 1.0,
            increment = 0.01,
        },
        head = {
            min = 0.95,
            max = 1.0,
            increment = 0.01,
        },
        proportion = {
            min = 0.0,
            max = 1.0,
            increment = 0.01,
        },
        bodyType = {
            min = 0.0,
            max = 1,
            increment = 0.01,
        }
    },
}

return Rodux.createReducer(initialState, {
    [SetAvatarSettings.name] = function(state, action)
        return {
            ObtainedAvatarRules = true,
            [AvatarEditorConstants.AvatarSettings.scalesRules] = action.scalesRules,
            [AvatarEditorConstants.AvatarSettings.minDeltaBodyColorDifference] = action.minimumDeltaEBodyColorDifference
        }
	end,
})
