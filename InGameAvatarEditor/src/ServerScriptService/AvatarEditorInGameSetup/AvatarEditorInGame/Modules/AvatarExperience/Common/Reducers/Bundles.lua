local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Common.ArgCheck)
local Cryo = require(Modules.Packages.Cryo)

local BundleInfo = require(Modules.AvatarExperience.Common.Models.BundleInfo)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local SetBundleInfo = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfo)
local SetRecommendedBundlesAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedBundlesAction)
local SetBundleInfoFromCatalogItemAction =
    require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromCatalogItemAction)
local SetBundleInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromSortResults)
local SetBundleOwned = require(Modules.AvatarExperience.Common.Actions.SetBundleOwned)

return function(state, action)
    state = state or {}

    if action.type == SetBundleInfo.name then
        local changedBundles = {}

        for key, bundleData in pairs(action.bundles) do
            local bundleId = tostring(key)
            local bundleDataInfo = BundleInfo.fromMultigetBundle(bundleData)

            local existingInfo = state[bundleId]
            if existingInfo then
                changedBundles[bundleId] = Cryo.Dictionary.join(existingInfo, bundleDataInfo)
            else
                changedBundles[bundleId] = bundleDataInfo
            end
        end

        return Cryo.Dictionary.join(state, changedBundles)

    elseif action.type == SetBundleInfoFromCatalogItemAction.name then
        ArgCheck.isType(action.bundleId, "string", "bundleId must be a string.")
        ArgCheck.isType(action.bundleData, "table", "bundleData must be a table.")

		local bundleId = tostring(action.bundleId)
		local bundleDataInfo = BundleInfo.fromGetCatalogItemData(action.bundleData)

		local existingInfo = state[bundleId]
		if existingInfo then
			local newData = Cryo.Dictionary.join(existingInfo, bundleDataInfo)
			return Cryo.Dictionary.join(state, { [bundleId] = newData })
		else
			return Cryo.Dictionary.join(state, { [bundleId] = bundleDataInfo })
		end

    elseif action.type == SetBundleInfoFromSortResults.name then
        ArgCheck.isType(action.sortResults, "table", "sortResults must be a table.")

        local changedBundles = {}

        for _, bundleData in pairs(action.sortResults) do
            local bundleId = tostring(bundleData.id)
            local bundleDataInfo = BundleInfo.fromSortResults(bundleData)

            local existingInfo = state[bundleId]
            if existingInfo then
                changedBundles[bundleId] = Cryo.Dictionary.join(existingInfo, bundleDataInfo)
            else
                changedBundles[bundleId] = bundleDataInfo
            end
        end

		return Cryo.Dictionary.join(state, changedBundles)

	elseif action.type == SetRecommendedBundlesAction.name then
		ArgCheck.isType(action.recommendedItems, "table", "recommendedItems must be a table.")
		local bundleId = tostring(action.bundleId)

        local changedBundles = {}
        local recommendedBundles = {}

        for _, recommendedItem in pairs(action.recommendedItems) do
            local recommendedId = tostring(recommendedItem.id)
            local recommenedItemInfo = BundleInfo.fromGetRecommendedBundleItemsData(recommendedItem)

            local existingInfo = state[recommendedId]
            if not existingInfo then
                changedBundles[recommendedId] = recommenedItemInfo
            elseif not existingInfo.receivedFromRecommendedData and not existingInfo.receivedCatalogData then
                changedBundles[recommendedId] = Cryo.Dictionary.join(existingInfo, recommenedItemInfo)
            end

            recommendedBundles[#recommendedBundles + 1] = {
                id = recommendedId,
                type = CatalogConstants.ItemType.Bundle,
            }
		end

        local bundleRecommnededInfo = BundleInfo.fromGetRecommendedItems(recommendedBundles)

		-- Update the bundles's recommended id list
        local existingInfo = state[bundleId]
        if existingInfo then
			changedBundles[bundleId] = Cryo.Dictionary.join(existingInfo, bundleRecommnededInfo)
        else
            changedBundles[bundleId] = bundleRecommnededInfo
        end

		return Cryo.Dictionary.join(state, changedBundles)

    elseif action.type == SetBundleOwned.name then
        ArgCheck.isType(action.bundleId, "string", "bundleId must be a string.")
        ArgCheck.isType(action.isOwned, "boolean", "isOwned must be a bool.")

		local bundleId = tostring(action.bundleId)
		local bundleDataInfo = BundleInfo.fromIsOwned(action.isOwned)

		local existingInfo = state[bundleId]
		if existingInfo then
			local newData = Cryo.Dictionary.join(existingInfo, bundleDataInfo)
			return Cryo.Dictionary.join(state, { [bundleId] = newData })
		else
			return Cryo.Dictionary.join(state, { [bundleId] = bundleDataInfo })
		end
	end

    return state
end