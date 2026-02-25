local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local PlayingSwimAnimation = require(Modules.AvatarExperience.Common.Actions.PlayingSwimAnimation)

return Rodux.createReducer(false, {
    [PlayingSwimAnimation.name] = function(state, action)
        return action.playingSwimAnimation
    end,
})