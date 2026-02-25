return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AssetFavorites = require(script.Parent.AssetFavorites)
	local SetAssetFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetAssetFavorite)
	local MockId = require(Modules.NotLApp.MockId)

	local MOCK_ID = tostring(MockId())

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	it("should be empty by default", function()
		local defaultState = AssetFavorites(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AssetFavorites(nil, {})
		local newState = AssetFavorites(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetAssetFavorite", function()
		it("should add a new asset favorite and recreate the entire state", function()
			local oldState = AssetFavorites(nil, {})
			local newState = AssetFavorites(oldState, SetAssetFavorite(MOCK_ID, true))
			expect(oldState).to.never.equal(newState)
			expect(newState[MOCK_ID]).to.equal(true)
		end)

		it("should update an existing favorite asset and recreate the state", function()
			local oldState = AssetFavorites(nil, SetAssetFavorite(MOCK_ID, true))
			expect(oldState[MOCK_ID]).to.equal(true)

			local newState = AssetFavorites(oldState, SetAssetFavorite(MOCK_ID, false))
			expect(oldState).to.never.equal(newState)
			expect(newState[MOCK_ID]).to.equal(false)
		end)
	end)
end