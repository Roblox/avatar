local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetBundleFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetBundleFavorite)

local default = {}

return Rodux.createReducer(default, {
	[SetBundleFavorite.name] = function(state, action)
		local bundleId = action.bundleId

		return Cryo.Dictionary.join(state, {
			[bundleId] = action.isFavorited,
		})
    end,
})