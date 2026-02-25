local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)

local AvatarEditorService = game:GetService("AvatarEditorService")

local SetBundleInfo = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfo)
local Promise = require(Modules.Packages.Promise)
local Result = require(Modules.Packages.Result)
local ArgCheck = require(Modules.Common.ArgCheck)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetAssetInfoFromBundleItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromBundleItemAction)
local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function convertToId(value)
	if type(value) ~= "number" and type(value) ~= "string" then
		return Result.error("convertToId expects value passed in to be a number or a string")
	end
	return Result.success(tostring(value))
end

local function keyMapper(bundleId)
	return CatalogConstants.FetchBundleInfoKey .. tostring(bundleId)
end

local function checkAssetExists(state, assetId)
	local existingInfo = state.AvatarExperience.Common.Assets[assetId]

	if existingInfo and existingInfo.receivedFromBundleItemData then
		return true
	end

	return false
end

return function(bundleIds)
	return function(store)
		ArgCheck.isType(bundleIds, "table", "FetchBundleInfo thunk expects bundleIds to be a table")
		ArgCheck.isNonNegativeNumber(#bundleIds, "FetchBundleInfo thunk expects bundleIds count to be greater than 0")
		local currentBundles = store:getState().AvatarExperience.Common.Bundles
		local bundleIdsToGet = {}
		for _,bundleId in pairs(bundleIds) do
			local currBundle = currentBundles[tostring(bundleId)]
			if currBundle == nil or not currBundle.receivedBundleDetails then
				table.insert(bundleIdsToGet, bundleId)
			end
		end

		-- Don't call the webApi for thumbnails we already have
		if #bundleIdsToGet == 0 then
			return Promise.resolve("We already have the bundleIds")
		end

		return PerformFetch.Batch(bundleIds, keyMapper, function(store, filteredBundleIds)

			return Promise.new(function(resovle, reject)
				coroutine.wrap(function()
					local results = {}
					for _, bundleId in ipairs(filteredBundleIds) do
						results[keyMapper(bundleId)] = Result.new(false, nil)
					end

					local bundles = {}
					local includedAssets = {}

					for _, bundleId in ipairs(bundleIds) do
						local bundleInfo = AvatarEditorService:GetItemDetails(bundleId, Enum.AvatarItemType.Bundle)

						bundleInfo = tableToCamelCaseKeys(bundleInfo)

						local state = store:getState()

						if bundleInfo.bundledItems then
							for _, includedAsset in pairs(bundleInfo.bundledItems) do
								local assetId = tostring(includedAsset.id)
								if includedAsset.type == CatalogConstants.ItemType.Asset and not checkAssetExists(state, assetId) then
									table.insert(includedAssets, includedAsset)
								end
							end
						end

						local convertToIdResult = convertToId(bundleInfo.id)
						convertToIdResult:match(function(id)
							bundles[id] = bundleInfo
							results[keyMapper(tostring(bundleInfo.id))] = Result.new(true, nil)
						end):matchError(function(decodeError)
							warn(decodeError)
						end)

					end

					if #includedAssets > 0 then
						store:dispatch(SetAssetInfoFromBundleItemAction(includedAssets))
					end
					store:dispatch(SetBundleInfo(bundles))

					resovle(results)
				end)()
			end)
		end)(store)
	end
end
