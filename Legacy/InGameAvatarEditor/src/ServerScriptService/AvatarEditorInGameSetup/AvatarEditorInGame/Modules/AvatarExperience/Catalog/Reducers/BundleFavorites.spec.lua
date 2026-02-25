return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local BundleFavorites = require(script.Parent.BundleFavorites)
	local SetBundleFavorite = require(Modules.AvatarExperience.Catalog.Actions.SetBundleFavorite)
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
		local defaultState = BundleFavorites(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = BundleFavorites(nil, {})
		local newState = BundleFavorites(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetBundleFavorite", function()
		it("should add a new bundle favorite and recreate the entire state", function()
			local oldState = BundleFavorites(nil, {})
			local newState = BundleFavorites(oldState, SetBundleFavorite(MOCK_ID, true))
			expect(oldState).to.never.equal(newState)
			expect(newState[MOCK_ID]).to.equal(true)
		end)

		it("should update an existing favorite bundle and recreate the entire state", function()
			local oldState = BundleFavorites(nil, SetBundleFavorite(MOCK_ID, true))
			expect(oldState[MOCK_ID]).to.equal(true)

			local newState = BundleFavorites(oldState, SetBundleFavorite(MOCK_ID, false))
			expect(oldState).to.never.equal(newState)
			expect(newState[MOCK_ID]).to.equal(false)
		end)
	end)
end