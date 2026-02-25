return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local PriceRange = require(script.Parent.PriceRange)
	local SetPriceRange = require(Modules.AvatarExperience.Catalog.Actions.SetPriceRange)

	it("has the expected fields, and only the expected fields", function()
		local state = PriceRange(nil, {})

		local expectedKeys = {
			minPrice = true,
			maxPrice = true,
		}

		for key in pairs(expectedKeys) do
			expect(state[key]).to.never.equal(nil)
		end

		for key in pairs(state) do
			expect(expectedKeys[key]).to.never.equal(nil)
		end
	end)

	it("should be unchanged by other actions", function()
		local oldState = PriceRange(nil, {})
		local newState = PriceRange(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetPriceRange", function()
		it("should preserve purity", function()
			local oldState = PriceRange(nil, {})
			local newState = PriceRange(oldState, SetPriceRange(42, 512))
			expect(oldState).to.never.equal(newState)
		end)

		it("should change both minPrice and maxPrice", function()
			local oldState = PriceRange(nil, {})
			local newState = PriceRange(oldState, SetPriceRange(42, 512))

			expect(newState).to.never.equal(nil)
			expect(newState.minPrice).to.equal(42)
			expect(newState.maxPrice).to.equal(512)
		end)
	end)
end