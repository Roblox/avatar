return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AvailableToSellAssets = require(script.Parent.AvailableToSellAssets)
	local SetAvailableToSellAssetsFromFetchSellData = require(Modules.AvatarExperience.Catalog.Actions.SetAvailableToSellAssetsFromFetchSellData)
	local AddAvailableToSellAsset = require(Modules.AvatarExperience.Catalog.Actions.AddAvailableToSellAsset)
	local RemoveAvailableToSellAsset = require(Modules.AvatarExperience.Catalog.Actions.RemoveAvailableToSellAsset)
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
		local defaultState = AvailableToSellAssets(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AvailableToSellAssets(nil, {})
		local newState = AvailableToSellAssets(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetAvailableToSellAssetsFromFetchSellData", function()
		it("should preserve purity", function()
			local oldState = AvailableToSellAssets(nil, {})
			local userAssetIdList = { "A" }

			local newState = AvailableToSellAssets(oldState, SetAvailableToSellAssetsFromFetchSellData(DUMMY_ASSET_ID, userAssetIdList))
			expect(oldState).to.never.equal(newState)
		end)

		it("should recreate the entire state when adding a new assetId", function()
			local userAssetIdList = { "A" }
			local oldState = AvailableToSellAssets(nil, {})
			local newState = AvailableToSellAssets(oldState, SetAvailableToSellAssetsFromFetchSellData(DUMMY_ASSET_ID, userAssetIdList))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("A")
		end)

		it("should recreate the entire state when updating an existing assetId and recreate the list", function()
			local initialList = { "A" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = AvailableToSellAssets(initialState, {})

			local newUserAssetIdList = { "B" }
			local newState = AvailableToSellAssets(oldState, SetAvailableToSellAssetsFromFetchSellData(DUMMY_ASSET_ID, newUserAssetIdList))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("B")
		end)
	end)

	describe("AddAvailableToSellAsset", function()
		it("should preserve purity", function()
			local oldState = AvailableToSellAssets(nil, {})
			local userAssetId = "A"

			local newState = AvailableToSellAssets(oldState, AddAvailableToSellAsset(DUMMY_ASSET_ID, userAssetId))
			expect(oldState).to.never.equal(newState)
		end)

		it("should recreate the entire state when adding a new assetId", function()
			local userAssetId = "A"
			local oldState = AvailableToSellAssets(nil, {})
			local newState = AvailableToSellAssets(oldState, AddAvailableToSellAsset(DUMMY_ASSET_ID, userAssetId))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal(userAssetId)
		end)

		it("should append the item to an existing list and recreate the list, and recreate the entire state", function()
			local initialList = { "A" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = AvailableToSellAssets(initialState, {})

			local newUserAssetId = "B"
			local newState = AvailableToSellAssets(oldState, AddAvailableToSellAsset(DUMMY_ASSET_ID, newUserAssetId))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal(initialList[1])
			expect(newState[DUMMY_ASSET_ID][2]).to.equal(newUserAssetId)
		end)
	end)

	describe("RemoveAvailableToSellAsset", function()
		it("should remove the item from the existing list and recreate the list, and recreate the entire state", function()
			local initialList = { "A", "B" }
			local initialState = {
				[DUMMY_ASSET_ID] = initialList
			}
			local oldState = AvailableToSellAssets(initialState, {})

			local userAssetIdToRemove = "A"
			local newState = AvailableToSellAssets(oldState, RemoveAvailableToSellAsset(DUMMY_ASSET_ID, userAssetIdToRemove))
			expect(oldState).to.never.equal(newState)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(nil)
			expect(newState[DUMMY_ASSET_ID]).to.never.equal(initialList)
			expect(newState[DUMMY_ASSET_ID][1]).to.never.equal(userAssetIdToRemove)
			expect(newState[DUMMY_ASSET_ID][1]).to.equal("B")
			expect(newState[DUMMY_ASSET_ID][2]).to.equal(nil)
		end)
	end)
end