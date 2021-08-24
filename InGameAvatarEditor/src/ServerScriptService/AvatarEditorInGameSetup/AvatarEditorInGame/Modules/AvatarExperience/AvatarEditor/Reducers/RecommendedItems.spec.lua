return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local RecommendedItems = require(script.Parent.RecommendedItems)
	local SetRecommendedItems = require(Modules.AvatarExperience.AvatarEditor.Actions.SetRecommendedItems)

	local MOCK_ASSET_TYPE_ID_1 = "1"
	local MOCK_ASSET_TYPE_ID_2 = "2"
	local MOCK_ASSETS_1 = {
		[1] = {
			item = {
				assetId = "1"
			},
		},
		[2] = {
			item = {
				assetId = "2"
			},
		},
		[3] = {
			item = {
				assetId = "3"
			},
		},
	}
	local MOCK_ASSETS_2 = {
		[1] = {
			item = {
				assetId = "4"
			},
		},
	}

	it("should be unchanged by other actions", function()
		local oldState = RecommendedItems(nil, {})
		local newState = RecommendedItems(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetRecommendedItems", function()
		it("should set the recommended items for a given asset type id", function()
			local state = RecommendedItems(nil, SetRecommendedItems(MOCK_ASSETS_1, MOCK_ASSET_TYPE_ID_1))
			expect(state[MOCK_ASSET_TYPE_ID_1][1]).to.equal(MOCK_ASSETS_1[1].item.assetId)
			expect(state[MOCK_ASSET_TYPE_ID_1][2]).to.equal(MOCK_ASSETS_1[2].item.assetId)

			state = RecommendedItems(nil, SetRecommendedItems(MOCK_ASSETS_2, MOCK_ASSET_TYPE_ID_2))
			expect(state[MOCK_ASSET_TYPE_ID_2][1]).to.equal(MOCK_ASSETS_2[1].item.assetId)
		end)

		it("should overwrite the recommended items for a given asset type id", function()
			local state = RecommendedItems(nil, SetRecommendedItems(MOCK_ASSETS_1, MOCK_ASSET_TYPE_ID_1))
			expect(state[MOCK_ASSET_TYPE_ID_1][1]).to.equal(MOCK_ASSETS_1[1].item.assetId)
			expect(#state[MOCK_ASSET_TYPE_ID_1]).to.equal(#MOCK_ASSETS_1)

			state = RecommendedItems(nil, SetRecommendedItems(MOCK_ASSETS_2, MOCK_ASSET_TYPE_ID_1))
			expect(state[MOCK_ASSET_TYPE_ID_1][1]).to.equal(MOCK_ASSETS_2[1].item.assetId)
			expect(#state[MOCK_ASSET_TYPE_ID_1]).to.equal(#MOCK_ASSETS_2)
		end)
	end)
end