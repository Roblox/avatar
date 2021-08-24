return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AssetsReducer = require(Modules.AvatarExperience.Common.Reducers.Assets)
	local SetRecommendedAssetsAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedAssetsAction)
	local SetAssetInfoFromBundleItemAction = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromBundleItemAction)
	local SetAssetInfoFromCatalogItemAction = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromCatalogItemAction)
	local SetAssetResellersList = require(Modules.AvatarExperience.Catalog.Actions.SetAssetResellersList)
	local AppendAssetResellersList = require(Modules.AvatarExperience.Catalog.Actions.AppendAssetResellersList)
	local SetAssetResaleData = require(Modules.AvatarExperience.Catalog.Actions.SetAssetResaleData)
	local SetAssetInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromSortResults)
	local SetAssetInfoFromAvatarEditorRecommendedItems =
		require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromAvatarEditorRecommendedItems)
	local SetAssetOwned = require(Modules.AvatarExperience.Common.Actions.SetAssetOwned)
	local AssetInfo = require(Modules.AvatarExperience.Common.Models.AssetInfo)
	local MockId = require(Modules.NotLApp.MockId)

	local MOCK_ASSET_ID = tostring(MockId())
	local MOCK_RECOMMENDED_ASSET_ID = tostring(MockId())

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	local function makeBundleItemInfo()
		return {
			owned = false,
			id = MockId(),
			name = "",
			type = "Asset",
		}
	end

	local function mockRecommendedAssetData(assetId, assetName)
		return {
			{
				item = {
					assetId = assetId,
					name = assetName,
					price = 0,
				},
				creator = {
					creatorId = MockId(),
					name = "",
					type = "",
				}
			}
		}
	end

	it("should be empty by default", function()
		local defaultState = AssetsReducer(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AssetsReducer(nil, {})
		local newState = AssetsReducer(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetRecommendedAssetsAction", function()
		it("should preserve purity when adding a new asset", function()
			local oldState = AssetsReducer(nil, {})
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID)
			local newState = AssetsReducer(oldState, SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData))
			expect(oldState).to.never.equal(newState)
		end)

		it("should preserve purity when updating an existing asset", function()
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID)
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initialRecommendedAsset = AssetInfo.mock()
			initialRecommendedAsset.id = MOCK_RECOMMENDED_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
				[MOCK_RECOMMENDED_ASSET_ID] = initialRecommendedAsset,
			}
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(initalState, {})
			local newState = AssetsReducer(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(initialAsset)
		end)

		it("should add a new asset with a recommended list", function()
			local assetName = tostring(MockId())
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID, assetName)
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(nil, {})
			local newState = AssetsReducer(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(oldState[MOCK_ASSET_ID])

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
		end)

		it("should add a new asset with recommended list and recreate state even when existing recommended assets exist", function()
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID)
			local initialRecommendedAsset = AssetInfo.mock()
			initialRecommendedAsset.id = MOCK_RECOMMENDED_ASSET_ID
			local initalState = {
				[MOCK_RECOMMENDED_ASSET_ID] = initialRecommendedAsset,
			}
			local oldState = AssetsReducer(initalState, {})
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local newState = AssetsReducer(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(oldState[MOCK_ASSET_ID])

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
		end)

		it("should add each new recommended asset into the reducer and recreate the state when the main asset doesn't exists", function()
			local name = tostring(MockId())
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID, name)
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(nil, {})
			local newState = AssetsReducer(oldState, action)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_ASSET_ID]
			expect(newState).to.never.equal(oldState)
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(oldState[MOCK_RECOMMENDED_ASSET_ID])
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
			expect(modifiedRecommendedState.name).to.equal(name)
		end)

		it("should add each new recommended asset into the reducer and recreate the state even when the main asset already exists", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local name = tostring(MockId())
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID, name)
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(initalState, {})
			local newState = AssetsReducer(oldState, action)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_ASSET_ID]
			expect(newState).to.never.equal(oldState)
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(oldState[MOCK_RECOMMENDED_ASSET_ID])
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
			expect(modifiedRecommendedState.name).to.equal(name)
		end)

		it("should update an existing asset's recommended list", function()
			local initialRecommendedItemIds = {}
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			initialAsset.recommendedItemIds = initialRecommendedItemIds
			local initialRecommendedAsset = AssetInfo.mock()
			initialRecommendedAsset.id = MOCK_RECOMMENDED_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
				[MOCK_RECOMMENDED_ASSET_ID] = initialRecommendedAsset,
			}

			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID)
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(initalState, {})
			local newState = AssetsReducer(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(initialAsset)

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(modifiedState.recommendedItemIds).to.never.equal(initialRecommendedItemIds)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
		end)

		it("should update an existing recommended asset and update an existing asset with recommended list", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initialRecommendedAsset = AssetInfo.mock()
			initialRecommendedAsset.id = MOCK_RECOMMENDED_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
				[MOCK_RECOMMENDED_ASSET_ID] = initialRecommendedAsset,
			}

			local assetName = tostring(MockId())
			local recommendedData = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID, assetName)
			local action = SetRecommendedAssetsAction(MOCK_ASSET_ID, recommendedData)
			local oldState = AssetsReducer(initalState, {})
			local newState = AssetsReducer(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_ASSET_ID]
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(initialRecommendedAsset)
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_ASSET_ID)
			expect(modifiedRecommendedState.name).to.equal(assetName)
		end)
	end)

	describe("SetAssetInfoFromCatalogItemAction", function()
		it("should preserve purity when adding a new asset", function()
			local oldState = AssetsReducer(nil, {})
			local assetData = AssetInfo.mock()
			assetData.id = MOCK_ASSET_ID

			local newState = AssetsReducer(oldState, SetAssetInfoFromCatalogItemAction(MOCK_ASSET_ID, assetData))
			expect(oldState).to.never.equal(newState)

			local newlyAddedAsset = newState[MOCK_ASSET_ID]
			expect(newlyAddedAsset).to.never.equal(nil)
		end)

		it("should preserve purity when updating an existing asset,", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.assetId = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})

			local newAssetData = AssetInfo.mock()
			local name = tostring(MockId())
			newAssetData.id = MOCK_ASSET_ID
			newAssetData.name = name
			local newState = AssetsReducer(oldState, SetAssetInfoFromCatalogItemAction(MOCK_ASSET_ID, newAssetData))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset).to.never.equal(initialAsset)
			expect(updatedAsset.name).to.equal(name)
		end)
	end)

	describe("SetAssetInfoFromBundleItemAction", function()
		it("should preserve purity when adding a new asset", function()
			local name = tostring(MockId())
			local oldState = AssetsReducer(nil, {})
			local assetData = makeBundleItemInfo()
			assetData.id = MOCK_ASSET_ID
			assetData.name = name
			local assetsList = { [MOCK_ASSET_ID] = assetData }

			local newState = AssetsReducer(oldState, SetAssetInfoFromBundleItemAction(assetsList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.name).to.equal(name)
		end)

		it("should preserve purity when updating an existing asset", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})

			local newAssetData = makeBundleItemInfo()
			local name = tostring(MockId())
			newAssetData.id = MOCK_ASSET_ID
			newAssetData.name = name
			local newAssetsList = { [MOCK_ASSET_ID] = newAssetData }
			local newState = AssetsReducer(oldState, SetAssetInfoFromBundleItemAction(newAssetsList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset).to.never.equal(initialAsset)
			expect(updatedAsset.name).to.equal(name)
		end)
	end)

	describe("SetAssetInfoFromSortResults", function()
		it("should preserve purity when adding a new asset", function()
			local name = tostring(MockId())
			local oldState = AssetsReducer(nil, {})
			local assetData = makeBundleItemInfo()
			assetData.id = MOCK_ASSET_ID
			assetData.name = name
			local assetsList = { [MOCK_ASSET_ID] = assetData }

			local newState = AssetsReducer(oldState, SetAssetInfoFromSortResults(assetsList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.name).to.equal(name)
		end)

		it("should preserve purity when updating an existing asset", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})

			local newAssetData = makeBundleItemInfo()
			local name = tostring(MockId())
			newAssetData.id = MOCK_ASSET_ID
			newAssetData.name = name
			local newAssetsList = { [MOCK_ASSET_ID] = newAssetData }
			local newState = AssetsReducer(oldState, SetAssetInfoFromSortResults(newAssetsList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset).to.never.equal(initialAsset)
			expect(updatedAsset.name).to.equal(name)
		end)
	end)

	describe("SetAssetResellersList", function()
		it("should preserve purity when adding a new asset", function()
			local oldState = AssetsReducer(nil, {})
			local resellersList = { "A" }

			local newState = AssetsReducer(oldState, SetAssetResellersList(MOCK_ASSET_ID, resellersList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
		end)

		it("should preserve purity when updating an existing asset", function()
			local oldResellersList = { "A" }
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			initialAsset.resellerUserAssetIds = oldResellersList
			local oldState = AssetsReducer(initalState, {})

			local newResellersList = { "B" }
			local newState = AssetsReducer(oldState, SetAssetResellersList(MOCK_ASSET_ID, newResellersList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset.resellerUserAssetIds).to.never.equal(oldResellersList)
		end)

		it("should recreate and override the existing asset's resellersList", function()
			local oldResellersList = { "A" }
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			initialAsset.resellerUserAssetIds = oldResellersList
			local oldState = AssetsReducer(initalState, {})

			local newResellersList = { "B" }
			local newState = AssetsReducer(oldState, SetAssetResellersList(MOCK_ASSET_ID, newResellersList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset.resellerUserAssetIds).to.never.equal(oldResellersList)
			expect(#updatedAsset.resellerUserAssetIds).to.equal(1)
			expect(updatedAsset.resellerUserAssetIds[1]).to.equal("B")
		end)
	end)

	describe("AppendAssetResellersList", function()
		it("should preserve purity when adding a new asset", function()
			local oldState = AssetsReducer(nil, {})
			local resellersList = { "A" }

			local newState = AssetsReducer(oldState, AppendAssetResellersList(MOCK_ASSET_ID, resellersList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
		end)

		it("should preserve purity when updating an existing asset", function()
			local oldResellersList = { "A" }
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			initialAsset.resellerUserAssetIds = oldResellersList
			local oldState = AssetsReducer(initalState, {})

			local newResellersList = { "B" }
			local newState = AssetsReducer(oldState, AppendAssetResellersList(MOCK_ASSET_ID, newResellersList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset.resellerUserAssetIds).to.never.equal(oldResellersList)
		end)

		it("should recreate the existing asset's resellersList and append new data to the existing list", function()
			local oldResellersList = { "A" }
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			initialAsset.resellerUserAssetIds = oldResellersList
			local oldState = AssetsReducer(initalState, {})

			local newResellersList = { "B" }
			local newState = AssetsReducer(oldState, AppendAssetResellersList(MOCK_ASSET_ID, newResellersList))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset.resellerUserAssetIds).to.never.equal(oldResellersList)
			expect(#updatedAsset.resellerUserAssetIds).to.equal(2)
			expect(updatedAsset.resellerUserAssetIds[1]).to.equal("A")
			expect(updatedAsset.resellerUserAssetIds[2]).to.equal("B")
		end)
	end)

	describe("SetAssetResaleData", function()
		it("should preserve purity when adding a new asset", function()
			local oldState = AssetsReducer(nil, {})
			local resaleData = {
				sales = 101, -- NOTE: We rename this to "soldCount"
				recentAveragePrice = 102, -- NOTE: We rename this to "averagePrice"
				originalPrice = 103,
			 }

			local newState = AssetsReducer(oldState, SetAssetResaleData(MOCK_ASSET_ID, resaleData))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.soldCount).to.equal(101)
			expect(modifiedState.averagePrice).to.equal(102)
			expect(modifiedState.originalPrice).to.equal(103)
		end)

		it("should preserve purity when updating an existing asset", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})

			local resaleData = {
				sales = 101, -- NOTE: We rename this to "soldCount"
				recentAveragePrice = 102, -- NOTE: We rename this to "averagePrice"
				originalPrice = 103,
			}
			local newState = AssetsReducer(oldState, SetAssetResaleData(MOCK_ASSET_ID, resaleData))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(nil)
			expect(updatedAsset).to.never.equal(initialAsset)
			expect(updatedAsset.soldCount).to.equal(101)
			expect(updatedAsset.averagePrice).to.equal(102)
			expect(updatedAsset.originalPrice).to.equal(103)
		end)
	end)

	describe("SetAssetInfoFromAvatarEditorRecommendedItems", function()
		it("should set a recommended asset's information including its asset type id", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})
			local mockRecommendedAsset = mockRecommendedAssetData(MOCK_RECOMMENDED_ASSET_ID, MOCK_RECOMMENDED_ASSET_ID)
			local mockAssetTypeId = "8"

			local newState = AssetsReducer(oldState,
				SetAssetInfoFromAvatarEditorRecommendedItems(mockRecommendedAsset, mockAssetTypeId))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_RECOMMENDED_ASSET_ID]
			expect(updatedAsset).to.never.equal(mockRecommendedAsset)
			expect(updatedAsset.assetId).to.equal(mockRecommendedAsset.assetId)
			expect(updatedAsset.assetType).to.equal(mockAssetTypeId)
		end)

		it("should add new recommended assets into the state even if those assets are already in the state", function()
			local initialAsset = AssetInfo.mock()
			initialAsset.id = MOCK_ASSET_ID
			local initalState = {
				[MOCK_ASSET_ID] = initialAsset,
			}
			local oldState = AssetsReducer(initalState, {})
			local mockRecommendedAsset = mockRecommendedAssetData(MOCK_ASSET_ID, MOCK_ASSET_ID)
			local mockAssetTypeId = "8"

			local newState = AssetsReducer(oldState,
				SetAssetInfoFromAvatarEditorRecommendedItems(mockRecommendedAsset, mockAssetTypeId))
			expect(oldState).to.never.equal(newState)

			local updatedAsset = newState[MOCK_ASSET_ID]
			expect(updatedAsset).to.never.equal(initialAsset)
			expect(updatedAsset.assetId).to.equal(mockRecommendedAsset.assetId)
			expect(updatedAsset.assetType).to.equal(mockAssetTypeId)
		end)
	end)

	describe("SetAssetOwned", function()
		it("should preserve purity when adding a new asset", function()
			local name = tostring(MockId())
			local oldState = AssetsReducer(nil, {})

			local newState = AssetsReducer(oldState, SetAssetOwned(MOCK_ASSET_ID, true))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.isOwned).to.equal(true)
		end)

		it("should preserve purity when updating an existing asset ", function()
			local initialBAsset = AssetInfo.mock()
			initialBAsset.id = MOCK_ASSET_ID
			initialBAsset.isOwned = false
			local initialState = {
				[MOCK_ASSET_ID] = initialBAsset,
			}
			local oldState = AssetsReducer(initialState, {})

			local newState = AssetsReducer(oldState, SetAssetOwned(MOCK_ASSET_ID, true))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_ASSET_ID]
			expect(modifiedState).to.never.equal(initialBAsset)
			expect(modifiedState.isOwned).to.equal(true)
		end)
	end)
end