local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetAssetFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetAssetFavorite)

local default = {}

return Rodux.createReducer(default, {
	[SetAssetFavorite.name] = function(state, action)
		local assetId = action.assetId

		return Cryo.Dictionary.join(state, {
			[assetId] = action.isFavorited,
		})
    end,
})