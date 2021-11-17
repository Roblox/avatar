local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Promise = require(Modules.Packages.Promise)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)

local SetAssetInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromSortResults)
local SetBundleInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromSortResults)
local CatalogAppendSortData = require(Modules.AvatarExperience.Catalog.Actions.CatalogAppendSortData)
local CatalogDataReceived = require(Modules.AvatarExperience.Catalog.Actions.CatalogDataReceived)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetCatalogSortDataStatus = require(Modules.AvatarExperience.Catalog.Actions.SetCatalogSortDataStatus)
local Categories = require(Modules.AvatarExperience.Catalog.Categories)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local SortResults = require(Modules.AvatarExperience.Catalog.Models.SortResults)

local catalogSearchParamsFromCategory = require(Modules.Util.catalogSearchParamsFromCategory)


local function checkItemInfoExists(state, itemType, itemId)
	local existingInfo

	if itemType == CatalogConstants.ItemType.Asset then
		existingInfo = state.AvatarExperience.Common.Assets[tostring(itemId)]
	elseif itemType == CatalogConstants.ItemType.Bundle then
		existingInfo = state.AvatarExperience.Common.Bundles[tostring(itemId)]
	end

	if existingInfo and existingInfo.receivedFromSortResults then
		return true
	end

	return false
end

return function(categoryIndex, subcategoryIndex, nextPageCursor)
	return function(store)
		local state = store:getState()
		if not categoryIndex then
			categoryIndex = state.AvatarExperience.Catalog.Categories.category
		end

		if not subcategoryIndex then
			subcategoryIndex = state.AvatarExperience.Catalog.Categories.subcategory
		end

		local dataStatus = state.AvatarExperience.Catalog.SortsContents.DataStatus[categoryIndex]
		if dataStatus and dataStatus[subcategoryIndex] == RetrievalStatus.Fetching then
			return Promise.resolve("Sort data is already fetching")
		end

		store:dispatch(SetCatalogSortDataStatus(categoryIndex, subcategoryIndex, RetrievalStatus.Fetching))

		local categoryInfo = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)
		local category = categoryInfo.ApiCategory
		local subcategory = categoryInfo.ApiSubcategory
		local extraAssetTypes = categoryInfo.ExtraAssetTypes
		local extraBundleTypes = categoryInfo.ExtraBundleTypes

		if categoryInfo.Subcategories then
			local subcategoryInfo = categoryInfo.Subcategories[subcategoryIndex]
			if subcategoryInfo then
				category = subcategoryInfo.ApiCategory or category
				subcategory = subcategoryInfo.ApiSubcategory or subcategory
				extraAssetTypes = subcategoryInfo.ExtraAssetTypes
				extraBundleTypes = subcategoryInfo.ExtraBundleTypes
			end
		end

		return Promise.new(function(resolve, _reject)
			coroutine.wrap(function()
				local pagesObject = nextPageCursor
				if pagesObject then
					pagesObject:AdvanceToNextPageAsync()
				else
					local searchParams = catalogSearchParamsFromCategory(category, extraAssetTypes, extraBundleTypes)

					pagesObject = AvatarEditorService:SearchCatalog(searchParams)
				end

				local data = {
					nextPageCursor = not pagesObject.IsFinished and pagesObject or nil,
					data = tableToCamelCaseKeys(pagesObject:GetCurrentPage()),
				}

				state = store:getState()
				local sortResults = SortResults.fromSearchItemsDetails(data)
				if nextPageCursor then
					store:dispatch(CatalogAppendSortData(categoryIndex, subcategoryIndex, sortResults))
				else
					store:dispatch(CatalogDataReceived(categoryIndex, subcategoryIndex, sortResults))
				end

				local assetData = {}
				local bundleData = {}
				for _, itemData in pairs(data.data) do
					if not checkItemInfoExists(state, itemData.itemType, itemData.id) then
						if itemData.itemType == CatalogConstants.ItemType.Asset then
							table.insert(assetData, itemData)
						elseif itemData.itemType == CatalogConstants.ItemType.Bundle then
							table.insert(bundleData, itemData)
						end
					end
				end

				if #assetData > 0 then
					store:dispatch(SetAssetInfoFromSortResults(assetData))
				end

				if #bundleData > 0 then
					store:dispatch(SetBundleInfoFromSortResults(bundleData))
				end

				store:dispatch(SetCatalogSortDataStatus(categoryIndex, subcategoryIndex, RetrievalStatus.Done))

				resolve()
			end)()
		end)
	end
end
