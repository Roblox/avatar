local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Promise = require(Modules.Packages.Promise)
local ArgCheck = require(Modules.Common.ArgCheck)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)

local SetBundleFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetBundleFavorite)

local function keyMapper(itemId)
	return CatalogConstants.GetFavoriteBundleKey .. itemId
end

return function(userId, bundleId)
	ArgCheck.isType(bundleId, "string", "GetBundleFavorite thunk expects bundleId")

	return PerformFetch.Single(keyMapper(bundleId), function(store)

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local success, err = pcall(function()
					local isFavorited = AvatarEditorService:GetFavorite(tonumber(bundleId), Enum.AvatarItemType.Bundle)

					store:dispatch(SetBundleFavorite(bundleId, isFavorited))
					resolve()
				end)

				if not success then
					print(err)
					reject()
				end
			end)()
		end)
	end)
end
