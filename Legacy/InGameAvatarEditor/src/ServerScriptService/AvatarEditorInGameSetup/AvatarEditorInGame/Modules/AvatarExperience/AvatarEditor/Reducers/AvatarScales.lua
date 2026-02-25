local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)
local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)

local initialState = {
    height = 1.00,
    width = 1.00,
    depth = 1.00,
    head = 1.00,
    bodyType = 0.00,
    proportion = 0.00,
}

return Rodux.createReducer(initialState, {
    [SetAvatarScales.name] = function(state, action)
        return Cryo.Dictionary.join(state, action.scales)
    end,
    [ReceivedAvatarData.name] = function(state, action)
        if not action.avatarData then
			return state
		end

		return action.avatarData["scales"]
    end,
})