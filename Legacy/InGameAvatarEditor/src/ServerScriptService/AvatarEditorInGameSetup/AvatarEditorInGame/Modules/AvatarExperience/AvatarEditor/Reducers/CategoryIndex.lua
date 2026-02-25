local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local SelectCategory = require(Modules.AvatarExperience.AvatarEditor.Actions.SelectCategory)

local CategoryIndexReducer = Rodux.createReducer(1, {
	[SelectCategory.name] = function(state, action)
		return action.categoryIndex
    end,
})

return CategoryIndexReducer