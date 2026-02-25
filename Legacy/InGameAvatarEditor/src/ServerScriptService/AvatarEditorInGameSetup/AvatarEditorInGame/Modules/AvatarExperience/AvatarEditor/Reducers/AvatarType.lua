local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarType)
local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)

return Rodux.createReducer(Constants.AvatarType.R15, {
	[ReceivedAvatarData.name] = function(state, action)
		local avatarType = action.avatarData["playerAvatarType"]
		if avatarType and Constants.AvatarType[avatarType] == avatarType then
			return avatarType
		else
			return state
		end
    end,
    [SetAvatarType.name] = function(state, action)
        return action.avatarType
    end,
})