return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local CurrentlySellingAssets = require(script.Parent.CurrentlySellingAssets)
	local SetCurrentlySellingAssetsFromFetchSellData = require(Modules.AvatarExperience.Catalog.Actions.SetCurrentlySellingAssetsFromFetchSellData)
	local AddCurrentlySellingAsset = require(Modules.AvatarExperience.Catalog.Actions.AddCurrentlySellingAsset)
	local RemoveCurrentlySellingAsset = require(Modules.AvatarExperience.Catalog.Actions.RemoveCurrentlySellingAsset)
	local MockId = require(Modules.NotLApp.MockId)

	local DUMMY_ASSET_ID = tostring(MockId())

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	it("should be empty by default", function()
		local defaultState = CurrentlySellingAssets(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = CurrentlySellingAssets(nil, {})
		local newState = CurrentlySellingAssets(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetCurrentlySellingAssetsFromFetchSellData", function()
		it("should preserve purity", function()
			local oldState = CurrentlySellingAssets(nil, {})
			local userAssetIdList = { "A" }

			local newState = CurrentlySellingAssets(oldState, SetCurrentlySellingAssetsFromFetchSellData(DUMMY_ASSET_ID, userAssetIdList))
			expect(oldState).to.never.equal(newState)
		end)

		it("should recreate the entire state when adding a new assetId", function()
			local userAssetIdList = { "A" }
			local oldState = CurrentlySellingAssets(nil, {})
			local newState = CurrentlySellingAssets(oldState, SetCurrentlySellingAssetsFromFetchSellData(DUMMY_ASSET_ID, userAssetIdList))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("A")
		end)

		it("should recreate the entire state when updating an existing assetId, and recreate the list", function()
			local initialList = { "A" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = CurrentlySellingAssets(initialState, {})

			local newUserAssetIdList = { "B" }
			local newState = CurrentlySellingAssets(oldState, SetCurrentlySellingAssetsFromFetchSellData(DUMMY_ASSET_ID, newUserAssetIdList))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("B")
		end)
	end)

	describe("AddCurrentlySellingAsset", function()
		it("should preserve purity", function()
			local oldState = CurrentlySellingAssets(nil, {})
			local userAssetId = "A"

			local newState = CurrentlySellingAssets(oldState, AddCurrentlySellingAsset(DUMMY_ASSET_ID, userAssetId))
			expect(oldState).to.never.equal(newState)
		end)

		it("should recreate the entire state when adding a new assetId", function()
			local userAssetId = "A"
			local oldState = CurrentlySellingAssets(nil, {})
			local newState = CurrentlySellingAssets(oldState, AddCurrentlySellingAsset(DUMMY_ASSET_ID, userAssetId))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal(userAssetId)
		end)

		it("should append the item to an existing list and recreate the list, and recreate the entire state", function()
			local initialList = { "A" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = CurrentlySellingAssets(initialState, {})

			local newUserAssetId = "B"
			local newState = CurrentlySellingAssets(oldState, AddCurrentlySellingAsset(DUMMY_ASSET_ID, newUserAssetId))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal(initialList[1])
			expect(newState[DUMMY_ASSET_ID][2]).to.equal(newUserAssetId)
		end)
	end)

	describe("RemoveCurrentlySellingAsset", function()
		it("should remove the item from the existing list and recreate the list, and recreate the entire state", function()
			local initialList = { "A", "B" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = CurrentlySellingAssets(initialState, {})

			local userAssetIdToRemove = "A"
			local newState = CurrentlySellingAssets(oldState, RemoveCurrentlySellingAsset(DUMMY_ASSET_ID, userAssetIdToRemove))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID][1]).to.never.equal(userAssetIdToRemove)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("B")
			expect(newState[DUMMY_ASSET_ID][2]).to.equal(nil)
		end)
	end)
end