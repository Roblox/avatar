local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Promise = require(Modules.Packages.Promise)

local AppendSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.AppendSearchInCatalog)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.SetSearchInCatalog)
local SetSearchInCatalogStatus = require(Modules.AvatarExperience.Catalog.Actions.SetSearchInCatalogStatus)
local SetAssetInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromSortResults)
local SetBundleInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromSortResults)
local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local SearchRetrievalStatus = require(Modules.NotLApp.Enum.SearchRetrievalStatus)
local SortResults = require(Modules.AvatarExperience.Catalog.Models.SortResults)

return function(searchArguments)
	return function(store)
		local searchKeyword = searchArguments.searchKeyword
		local searchUuid = searchArguments.searchUuid

		if not searchUuid then
			print("Search UUID reject")

			return Promise.reject("Must have a searchUuid.")
		end

		if not searchKeyword and not searchArguments.nextPageCursor then
			print("SearchKeyword reject")
			return Promise.reject("Must have a searchKeyword to search with.")
		end

		local searchesInCatalogStatus = store:getState().RequestsStatus.SearchesInCatalogStatus
		local searchStatus = searchesInCatalogStatus[searchUuid]

		if searchStatus == SearchRetrievalStatus.Fetching then
			return Promise.resolve("Search with Uuid "..searchUuid.." has been debounced")
		end

		store:dispatch(SetSearchInCatalogStatus(searchUuid, SearchRetrievalStatus.Fetching))

		local pagesObject = searchArguments.nextPageCursor

		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()

				local success, err = pcall(function()
					if pagesObject then
						pagesObject:AdvanceToNextPageAsync()
					else
						local searchParams = CatalogSearchParams.new()
						searchParams.SearchKeyword = searchKeyword

						pagesObject = AvatarEditorService:SearchCatalog(searchParams)
					end

					local data = {
						nextPageCursor = not pagesObject.IsFinished and pagesObject or nil,
						data = tableToCamelCaseKeys(pagesObject:GetCurrentPage()),
					}

					searchesInCatalogStatus = store:getState().RequestsStatus.SearchesInCatalogStatus
					searchStatus = searchesInCatalogStatus[searchUuid]

					if searchStatus == SearchRetrievalStatus.Removed then
						resolve("Search with Uuid " ..searchUuid.. " has been terminated")
						return
					end

					local sortResults = SortResults.fromSearchItemsDetails(data)
					if searchArguments.nextPageCursor then
						store:dispatch(AppendSearchInCatalog(searchUuid, sortResults))
					else
						store:dispatch(SetSearchInCatalog(searchUuid, sortResults))
					end

					local assetData = {}
					local bundleData = {}
					for _, itemData in pairs(data.data) do
						if itemData.itemType == CatalogConstants.ItemType.Asset then
							table.insert(assetData, itemData)
						elseif itemData.itemType == CatalogConstants.ItemType.Bundle then
							table.insert(bundleData, itemData)
						end
					end

					if #assetData > 0 then
						store:dispatch(SetAssetInfoFromSortResults(assetData))
					end
					if #bundleData > 0 then
						store:dispatch(SetBundleInfoFromSortResults(bundleData))
					end

					store:dispatch(SetSearchInCatalogStatus(searchUuid, SearchRetrievalStatus.Done))

					resolve()
				end)

				if not success then
					print(err)
					reject()
				end
			end)()
		end)
	end
end
