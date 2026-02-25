local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Logging = require(Modules.Packages.Logging)

local Promise = require(Modules.Packages.Promise)
local ArgCheck = require(Modules.Common.ArgCheck)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)

local SetAssetFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetAssetFavorite)

local runPromptCallbackInQueue = require(Modules.Util.runPromptCallbackInQueue)

local function keyMapper(itemId)
	return CatalogConstants.SetFavoriteAssetKey .. itemId
end

return function(userId, assetId, isFavorited)
	ArgCheck.isType(assetId, "string", "SetAssetFavorite thunk expects assetId")
	ArgCheck.isType(isFavorited, "boolean", "SetAssetFavorite thunk expects isFavorited")

	return PerformFetch.Single(keyMapper(assetId), function(store)

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local function runBundleFavorite()
					AvatarEditorService:PromptSetFavorite(tonumber(assetId), Enum.AvatarItemType.Asset, isFavorited)

					local result = AvatarEditorService.PromptSetFavoriteCompleted:Wait()

					if result == Enum.AvatarPromptResult.Success then
						store:dispatch(SetAssetFavorite(assetId, isFavorited))
						resolve()
					else
						warn("Failed, result is:", result)
						reject({HttpError = Enum.HttpError.OK})
					end
				end

				runPromptCallbackInQueue(runBundleFavorite)
			end)()
		end)
	end)
end
