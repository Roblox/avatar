local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetResellerCursor = require(Modules.AvatarExperience.Catalog.Actions.SetResellerCursor)

local default = {
	nextPageCursor = nil,
	hasMoreRows = nil,
}

return Rodux.createReducer(default, {
	[SetResellerCursor.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
			nextPageCursor = action.cursor,
			hasMoreRows = action.cursor ~= nil,
		})
    end,
})