local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Promise = require(Modules.Packages.Promise)
local ArgCheck = require(Modules.Common.ArgCheck)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)

local SetAssetFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetAssetFavorite)

local function keyMapper(itemId)
	return CatalogConstants.GetFavoriteAssetKey .. itemId
end

return function(userId, assetId)
	ArgCheck.isType(assetId, "string", "GetAssetFavorite thunk expects assetId")

	return PerformFetch.Single(keyMapper(assetId), function(store)

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local success, err = pcall(function()
					local isFavorited = AvatarEditorService:GetFavorite(tonumber(assetId), Enum.AvatarItemType.Asset)

					store:dispatch(SetAssetFavorite(assetId, isFavorited))
					resolve()

				end)

				if not success then
					warn(err)
					reject()
				end
			end)()
		end)
	end)
end
