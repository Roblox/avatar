local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AvatarEditorService = game:GetService("AvatarEditorService")

local Logging = require(Modules.Packages.Logging)
local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetRecommendedAssetsAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedAssetsAction)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local avatarAssetTypeFromTypeId = require(Modules.Util.avatarAssetTypeFromTypeId)

local function keyMapper(assetId)
	return CatalogConstants.RecommendedItemsForAssetsKey ..tostring(assetId)
end

return function(assetId, assetTypeId)
	return PerformFetch.Single(keyMapper(assetId), function(store)
		local assetInfo = store:getState().AvatarExperience.Common.Assets[tostring(assetId)]
		if assetInfo ~= nil and assetInfo.receivedRecommendedData then
			return Promise.resolve()
		end

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local assetType = avatarAssetTypeFromTypeId(assetTypeId)

				local data
				pcall(function()
					data = AvatarEditorService:GetRecommendedAssets(assetType, assetId)
				end)

				if data then
					data = tableToCamelCaseKeys(data)

					store:dispatch(SetRecommendedAssetsAction(assetId, data, assetTypeId))

					local recommendedAssetIds = {}
					for _,assetItem in pairs(data) do
						table.insert(recommendedAssetIds, assetItem.item.assetId)
					end

					resolve(data)
				else
					Logging.warn("Response from GetRecommendedAssets is malformed!")
					reject({HttpError = Enum.HttpError.OK})
				end
			end)()
		end)
	end)
end
