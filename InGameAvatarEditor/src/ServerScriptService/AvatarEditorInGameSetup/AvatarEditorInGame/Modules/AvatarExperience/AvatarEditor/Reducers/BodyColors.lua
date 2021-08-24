local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local SetBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetBodyColors)
local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)

local MEDIUM_STONE_GREY = 194

local initialState = {
    headColorId = MEDIUM_STONE_GREY,
    leftArmColorId = MEDIUM_STONE_GREY,
    leftLegColorId = MEDIUM_STONE_GREY,
    rightArmColorId = MEDIUM_STONE_GREY,
    rightLegColorId = MEDIUM_STONE_GREY,
    torsoColorId = MEDIUM_STONE_GREY,
}

return Rodux.createReducer(initialState, {
	[SetBodyColors.name] = function(state, action)
        local bodyColors = {}
        for key, value in pairs(action.bodyColors) do
            bodyColors[key] = value
        end

        return bodyColors
    end,
    [ReceivedAvatarData.name] = function(state, action)
        local bodyColorsData = action.avatarData["bodyColors"]
		local bodyColors = {}

		for name, color in pairs(bodyColorsData) do
			bodyColors[name] = color
		end

		return bodyColors
    end,
})