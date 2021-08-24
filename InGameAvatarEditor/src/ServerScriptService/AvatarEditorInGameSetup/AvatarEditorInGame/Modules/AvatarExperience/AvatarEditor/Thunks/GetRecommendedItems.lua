local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AvatarEditorService = game:GetService("AvatarEditorService")

local Logging = require(Modules.Packages.Logging)
local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetBundleInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromSortResults)
local SetRecommendedItems = require(Modules.AvatarExperience.AvatarEditor.Actions.SetRecommendedItems)
local SetAssetInfoFromAvatarEditorRecommendedItems =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromAvatarEditorRecommendedItems)
local Constants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local avatarAssetTypeFromTypeId = require(Modules.Util.avatarAssetTypeFromTypeId)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local catalogSearchParamsFromCategory = require(Modules.Util.catalogSearchParamsFromCategory)

local FEATURED = "Featured"
local BODY_PARTS = "BodyParts"
local BUNDLES = "Bundles"
local ANIMATION_BUNDLES = "AnimationBundles"

local function keyMapper(assetTypeId)
	return Constants.RecommendedItemsKey ..tostring(assetTypeId)
end

return function(assetTypeId)
	return function(store)
		local categoryIndex = store:getState().AvatarExperience.AvatarEditor.Categories.category
		local subcategoryIndex = store:getState().AvatarExperience.AvatarEditor.Categories.subcategory
		local page = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)

		if page.RecommendationsType and page.RecommendationsType == AvatarEditorConstants.RecommendationsType.Asset then
			return PerformFetch.Single(keyMapper(assetTypeId), function(store)
				return Promise.new(function(resolve, reject)
					coroutine.wrap(function()
						local data
						pcall(function()
							data = AvatarEditorService:GetRecommendedAssets(avatarAssetTypeFromTypeId(assetTypeId))
						end)

						if data then
							data = tableToCamelCaseKeys(data)

							store:dispatch(SetAssetInfoFromAvatarEditorRecommendedItems(data, assetTypeId))
							store:dispatch(SetRecommendedItems(data, assetTypeId))

							return Promise.resolve(data)
						else
							Logging.warn("Response from GetRecommendedItems with assetTypeId of " ..tostring(assetTypeId) .." is malformed!")
							return Promise.reject({HttpError = Enum.HttpError.OK})
						end
					end)()
				end)
			end)(store)
		elseif page.RecommendationsType
			and (page.RecommendationsType == AvatarEditorConstants.RecommendationsType.BodyParts
			or page.RecommendationsType == AvatarEditorConstants.RecommendationsType.AvatarAnimations) then

			local key = page.RecommendationsType
			local category = key == AvatarEditorConstants.RecommendationsType.BodyParts and BODY_PARTS or FEATURED
			local subcategory = key == AvatarEditorConstants.RecommendationsType.BodyParts and BUNDLES or ANIMATION_BUNDLES

			return PerformFetch.Single(keyMapper(key), function(store)

				return Promise.new(function(resolve, reject)
					coroutine.wrap(function()

						local pagesObject

						local success, err = pcall(function()
							local searchParams = catalogSearchParamsFromCategory(category)

							pagesObject = AvatarEditorService:SearchCatalog(searchParams)
						end)

						if success then
							local data = pagesObject:GetCurrentPage()

							data = tableToCamelCaseKeys(data)

							local bundleData = {}
							for _, itemData in pairs(data) do
								if itemData.itemType == CatalogConstants.ItemType.Bundle then
									table.insert(bundleData, itemData)
								end
							end

							if #bundleData > 0 then
								store:dispatch(SetBundleInfoFromSortResults(bundleData))
								store:dispatch(SetRecommendedItems(bundleData, key))
							end

							return resolve(data)

						else
							warn("Error in GetRecommendedItems" .. err)
							reject()
						end
					end)
				end)
			end)(store)
		else
			return nil
		end
	end
end
