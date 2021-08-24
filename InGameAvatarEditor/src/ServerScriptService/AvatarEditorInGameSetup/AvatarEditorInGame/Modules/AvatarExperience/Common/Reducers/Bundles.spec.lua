return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local Bundles = require(Modules.AvatarExperience.Common.Reducers.Bundles)
	local BundleInfo = require(Modules.AvatarExperience.Common.Models.BundleInfo)
	local SetBundleInfoAction = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfo)
	local SetRecommendedBundlesAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedBundlesAction)
	local SetBundleInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromSortResults)
	local SetBundleInfoFromCatalogItemAction = require(Modules.AvatarExperience.Catalog.Actions.SetBundleInfoFromCatalogItemAction)
	local SetBundleOwned = require(Modules.AvatarExperience.Common.Actions.SetBundleOwned)
	local MockId = require(Modules.NotLApp.MockId)

	local MOCK_BUNDLE_ID = "BUNDLE_123"
	local MOCK_RECOMMENDED_BUNDLE_ID = "RECOMMENDED_123"

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	local function mockRecommendedBundleData(bundleId, name)
		return {
			{
				id = bundleId,
				name = name,
				description = "",
				bundleType = "",
				items = {
					{
						owned = false,
						id = MockId(),
						name = "",
						type = "Asset",
					},
				},
				creator = {
					creatorId = MockId(),
					name = "",
					type = "",
				},
				product = {
					id = "",
					type = "",
					isForSale = true,
				}
			}
		}
	end

	it("should be empty by default", function()
		local defaultState = Bundles(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = Bundles(nil, {})
		local newState = Bundles(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetBundleInfoAction", function()

		it("should preserve purity when adding a new bundle", function()
			local name = tostring(MockId())
			local oldState = Bundles(nil, {})
			local bundleData = BundleInfo.mock()
			bundleData.id = MOCK_BUNDLE_ID
			bundleData.name = name
			local bundlesList = { [MOCK_BUNDLE_ID] = bundleData }

			local newState = Bundles(oldState, SetBundleInfoAction(bundlesList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.name).to.equal(name)
		end)

		it("should preserve purity when updating an existing bundle ", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initialState = {
				[MOCK_BUNDLE_ID] = initialBundle,
			}
			local oldState = Bundles(initialState, {})

			local bundleInfo = BundleInfo.mock()
			local name = tostring(MockId())
			bundleInfo.id = MOCK_BUNDLE_ID
			bundleInfo.name = name
			local bundleData = { [MOCK_BUNDLE_ID] = bundleInfo }
			local newState = Bundles(oldState, SetBundleInfoAction(bundleData))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(initialBundle)
			expect(modifiedState.name).to.equal(name)
		end)
	end)

	describe("SetRecommendedBundlesAction", function()
		it("should preserve purity when adding a new bundle", function()
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID)
			local oldState = Bundles(nil, {})
			local newState = Bundles(oldState, SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData))
			expect(oldState).to.never.equal(newState)
		end)

		it("should preserve purity when updating an existing bundle", function()
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID)
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initialRecommendedBundle = BundleInfo.mock()
			initialRecommendedBundle.id = MOCK_RECOMMENDED_BUNDLE_ID
			local initalState = {
				[MOCK_BUNDLE_ID] = initialBundle,
				[MOCK_RECOMMENDED_BUNDLE_ID] = initialRecommendedBundle,
			}
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(initalState, {})
			local newState = Bundles(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(initialBundle)
		end)

		it("should add a new bundle with a recommended list", function()
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID)
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(nil, {})
			local newState = Bundles(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(oldState[MOCK_BUNDLE_ID])

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
		end)

		it("should add a new bundle with recommended list and recreate state even when existing recommended bundles exist", function()
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID)
			local initialRecommendedAsset = BundleInfo.mock()
			initialRecommendedAsset.id = MOCK_RECOMMENDED_BUNDLE_ID
			local initalState = {
				[MOCK_RECOMMENDED_BUNDLE_ID] = initialRecommendedAsset,
			}
			local oldState = Bundles(initalState, {})
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local newState = Bundles(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(oldState[MOCK_BUNDLE_ID])

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
		end)

		it("should add each new recommended bundles into the reducer and recreate the state when the main asset doesn't exists", function()
			local name = tostring(MockId())
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID, name)
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(nil, {})
			local newState = Bundles(oldState, action)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_BUNDLE_ID]
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(oldState[MOCK_RECOMMENDED_BUNDLE_ID])
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
			expect(modifiedRecommendedState.name).to.equal(name)
		end)

		it("should add each new recommended asset into the reducer and recreate the state even when the main asset already exists", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initalState = {
				[MOCK_BUNDLE_ID] = initialBundle,
			}
			local name = tostring(MockId())
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID, name)
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(initalState, {})
			local newState = Bundles(oldState, action)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_BUNDLE_ID]
			expect(newState).to.never.equal(oldState)
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(oldState[MOCK_RECOMMENDED_BUNDLE_ID])
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
			expect(modifiedRecommendedState.name).to.equal(name)
		end)

		it("should update an existing bundle's recommended list", function()
			local initialRecommendedItemIds = {}
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			initialBundle.recommendedItemIds = initialRecommendedItemIds
			local initialRecommendedBundle = BundleInfo.mock()
			initialRecommendedBundle.id = MOCK_RECOMMENDED_BUNDLE_ID
			local initalState = {
				[MOCK_BUNDLE_ID] = initialBundle,
				[MOCK_RECOMMENDED_BUNDLE_ID] = initialRecommendedBundle,
			}

			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID)
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(initalState, {})
			local newState = Bundles(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState).to.never.equal(initialBundle)

			expect(modifiedState.recommendedItemIds).to.never.equal(nil)
			expect(modifiedState.recommendedItemIds).to.never.equal(initialRecommendedItemIds)
			expect(#modifiedState.recommendedItemIds).to.equal(1)
			expect(modifiedState.recommendedItemIds[1].id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
		end)

		it("should update existing recommended bundles and update the existing main bundle's recommended list", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initialRecommendedBundle = BundleInfo.mock()
			initialRecommendedBundle.id = MOCK_RECOMMENDED_BUNDLE_ID
			local initalState = {
				[MOCK_BUNDLE_ID] = initialBundle,
				[MOCK_RECOMMENDED_BUNDLE_ID] = initialRecommendedBundle,
			}

			local name = tostring(MockId())
			local recommendedData = mockRecommendedBundleData(MOCK_RECOMMENDED_BUNDLE_ID, name)
			local action = SetRecommendedBundlesAction(MOCK_BUNDLE_ID, recommendedData)
			local oldState = Bundles(initalState, {})
			local newState = Bundles(oldState, action)
			expect(oldState).to.never.equal(newState)

			local modifiedRecommendedState = newState[MOCK_RECOMMENDED_BUNDLE_ID]
			expect(modifiedRecommendedState).to.never.equal(nil)
			expect(modifiedRecommendedState).to.never.equal(initialRecommendedBundle)
			expect(modifiedRecommendedState.id).to.equal(MOCK_RECOMMENDED_BUNDLE_ID)
			expect(modifiedRecommendedState.name).to.equal(name)
		end)
	end)

	describe("SetBundleInfoFromCatalogItemAction", function()
		it("should preserve purity when adding a new bundle", function()
			local name = tostring(MockId())
			local oldState = Bundles(nil, {})
			local bundleData = BundleInfo.mock()
			bundleData.id = MOCK_BUNDLE_ID
			bundleData.name = name

			local newState = Bundles(oldState, SetBundleInfoFromCatalogItemAction(MOCK_BUNDLE_ID, bundleData))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.name).to.equal(name)
		end)

		it("should preserve purity when updating an existing bundle ", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initialState = {
				[MOCK_BUNDLE_ID] = initialBundle,
			}
			local oldState = Bundles(initialState, {})

			local bundleInfo = BundleInfo.mock()
			local name = tostring(MockId())
			bundleInfo.id = MOCK_BUNDLE_ID
			bundleInfo.name = name
			local newState = Bundles(oldState, SetBundleInfoFromCatalogItemAction(MOCK_BUNDLE_ID, bundleInfo))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(initialBundle)
			expect(modifiedState.name).to.equal(name)
		end)
	end)

	describe("SetBundleInfoFromSortResults", function()
		it("should preserve purity when adding a new bundle", function()
			local name = tostring(MockId())
			local oldState = Bundles(nil, {})
			local bundleData = BundleInfo.mock()
			bundleData.id = MOCK_BUNDLE_ID
			bundleData.name = name
			local bundlesList = { [MOCK_BUNDLE_ID] = bundleData }

			local newState = Bundles(oldState, SetBundleInfoFromSortResults(bundlesList))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.name).to.equal(name)
		end)

		it("should preserve purity when updating an existing bundle ", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			local initialState = {
				[MOCK_BUNDLE_ID] = initialBundle,
			}
			local oldState = Bundles(initialState, {})

			local bundleInfo = BundleInfo.mock()
			local name = tostring(MockId())
			bundleInfo.id = MOCK_BUNDLE_ID
			bundleInfo.name = name
			local bundleData = { [MOCK_BUNDLE_ID] = bundleInfo }
			local newState = Bundles(oldState, SetBundleInfoFromSortResults(bundleData))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(initialBundle)
			expect(modifiedState.name).to.equal(name)
		end)
	end)

	describe("SetBundleOwned", function()
		it("should preserve purity when adding a new bundle", function()
			local name = tostring(MockId())
			local oldState = Bundles(nil, {})

			local newState = Bundles(oldState, SetBundleOwned(MOCK_BUNDLE_ID, true))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.isOwned).to.equal(true)
		end)

		it("should preserve purity when updating an existing bundle ", function()
			local initialBundle = BundleInfo.mock()
			initialBundle.id = MOCK_BUNDLE_ID
			initialBundle.isOwned = false
			local initialState = {
				[MOCK_BUNDLE_ID] = initialBundle,
			}
			local oldState = Bundles(initialState, {})

			local newState = Bundles(oldState, SetBundleOwned(MOCK_BUNDLE_ID, true))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState[MOCK_BUNDLE_ID]
			expect(modifiedState).to.never.equal(initialBundle)
			expect(modifiedState.isOwned).to.equal(true)
		end)
	end)
end