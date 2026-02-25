local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Promise = require(Modules.Packages.Promise)
local ArgCheck = require(Modules.Common.ArgCheck)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetBundleInfoFromCatalogItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromCatalogItemAction)
local SetAssetInfoFromCatalogItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromCatalogItemAction)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetAssetInfoFromBundleItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromBundleItemAction)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function keyMapper(itemId, itemType)
	return CatalogUtils.GetItemDetailsKey(itemId, itemType)
end

local function checkIfReceivedFromBundleItemData(state, assetId)
	local existingInfo = state.AvatarExperience.Common.Assets[assetId]
	if existingInfo and existingInfo.receivedFromBundleItemData then
		return true
	end
	return false
end

return function(itemId, itemType)
	return function(store)
		ArgCheck.isType(itemId, "string", "FetchItemData request expects itemId")
		ArgCheck.isType(itemType, "string", "FetchItemData request expects itemType")
		local startTime = tick()
		local state = store:getState()

		local currItem
		local itemTypeEnum
		if itemType == CatalogConstants.ItemType.Asset then
			currItem = state.AvatarExperience.Common.Assets[itemId]
			itemTypeEnum = Enum.AvatarItemType.Asset
		elseif itemType == CatalogConstants.ItemType.Bundle then
			currItem = state.AvatarExperience.Common.Bundles[itemId]
			itemTypeEnum = Enum.AvatarItemType.Bundle
		end

		-- Don't call the webApi for items we already have
		if currItem ~= nil and currItem.receivedCatalogData then
			return Promise.resolve()
		end

		return PerformFetch.Single(keyMapper(itemId, itemType), function(store)
			return Promise.new(function(resolve, reject)
				coroutine.wrap(function()
					local data
					local success, err = pcall(function()
						print("getting item details!")
						data = AvatarEditorService:GetItemDetails(tonumber(itemId), itemTypeEnum)
					end)
					if not success then
						warn("error in GetItemDetails" .. err)
						resolve()
						return
					end

					data = tableToCamelCaseKeys(data)

					if itemType == CatalogConstants.ItemType.Bundle then
						store:dispatch(SetBundleInfoFromCatalogItemAction(itemId, data))

						local includedAssets = {}
						if data.bundledItems then
							for _, includedAsset in pairs(data.bundledItems) do
								local assetId = tostring(includedAsset.id)
								if includedAsset.type == CatalogConstants.ItemType.Asset and not checkIfReceivedFromBundleItemData(state, assetId) then
									table.insert(includedAssets, includedAsset)
								end
							end

							if #includedAssets > 0 then
								store:dispatch(SetAssetInfoFromBundleItemAction(includedAssets))
							end
						end

					elseif itemType == CatalogConstants.ItemType.Asset then
						store:dispatch(SetAssetInfoFromCatalogItemAction(itemId, data))
					end

					resolve()
				end)()
			end)
		end)(store)
	end
end
