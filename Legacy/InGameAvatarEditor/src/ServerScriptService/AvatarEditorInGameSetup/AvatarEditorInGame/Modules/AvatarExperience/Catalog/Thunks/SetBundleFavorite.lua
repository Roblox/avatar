local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Common.ArgCheck)

local Promise = require(Modules.Packages.Promise)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)

local SetBundleFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetBundleFavorite)

local runPromptCallbackInQueue = require(Modules.Util.runPromptCallbackInQueue)

local function keyMapper(itemId)
	return CatalogConstants.SetFavoriteBundleKey .. itemId
end

return function(userId, bundleId, isFavorited)
	ArgCheck.isType(bundleId, "string", "SetBundleFavorite thunk expects bundleId")
	ArgCheck.isType(isFavorited, "boolean", "SetBundleFavorite thunk expects isFavorited")

	return PerformFetch.Single(keyMapper(bundleId), function(store)

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local function runBundleFavorite()
					AvatarEditorService:PromptSetFavorite(tonumber(bundleId), Enum.AvatarItemType.Bundle, isFavorited)

					local result = AvatarEditorService.PromptSetFavoriteCompleted:Wait()

					if result == Enum.AvatarPromptResult.Success then
						store:dispatch(SetBundleFavorite(bundleId, isFavorited))
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
