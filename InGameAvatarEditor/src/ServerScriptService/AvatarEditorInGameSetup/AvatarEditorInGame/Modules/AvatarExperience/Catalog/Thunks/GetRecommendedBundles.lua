local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local AvatarEditorService = game:GetService("AvatarEditorService")

local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetRecommendedBundlesAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedBundlesAction)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function keyMapper(bundleId)
	return CatalogConstants.RecommendedItemsForBundlesKey ..tostring(bundleId)
end

return function(bundleId)
	return PerformFetch.Single(keyMapper(bundleId), function(store)
		local bundleInfo = store:getState().AvatarExperience.Common.Bundles[tostring(bundleId)]
		if bundleInfo ~= nil and bundleInfo.receivedRecommendedData then
			return Promise.resolve()
		end

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local data

				local success, err = pcall(function()
					data = AvatarEditorService:GetRecommendedBundles(tonumber(bundleId))
				end)

				if success then
					data = tableToCamelCaseKeys(data)

					store:dispatch(SetRecommendedBundlesAction(bundleId, data))
					resolve(data)
				else
					warn(err)
					reject({HttpError = Enum.HttpError.OK})
				end
			end)()
		end)
	end)
end
