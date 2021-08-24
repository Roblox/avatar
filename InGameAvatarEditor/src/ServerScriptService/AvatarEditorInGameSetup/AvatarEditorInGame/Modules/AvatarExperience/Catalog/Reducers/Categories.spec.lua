return function()
	local Players = game:GetService("Players")

	local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local Categories = require(script.Parent.Categories)
	local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Actions.SetCategoryAndSubcategory)

	local DEFAULT_CATEGORY = 1
	local DEFAULT_SUBCATEGORY = 0

	it("has the expected fields, and only the expected fields", function()
		local state = Categories(nil, {})

		local expectedKeys = {
			category = true,
			subcategory = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)

	it("should be unchanged by other actions", function()
		local oldState = Categories(nil, {})
		local newState = Categories(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("Catalog SetCategoryAndSubcategory", function()
		it("should change both category and subcategory", function()
			local oldState = Categories(nil, {})
			local newState = Categories(oldState, SetCategoryAndSubcategory(3, 4))

			expect(newState).to.never.equal(nil)
			expect(newState.category).to.equal(3)
			expect(newState.subcategory).to.equal(4)
		end)

		it("should change category and set default subcategory", function()
			local oldState = Categories(nil, {})
			local newState = Categories(oldState, SetCategoryAndSubcategory(3, nil))

			expect(newState).to.never.equal(nil)
			expect(newState.category).to.equal(3)
			expect(newState.subcategory).to.equal(DEFAULT_SUBCATEGORY)
		end)

		it("should change subcategory and keep currently selected category", function()
			local oldState = Categories(nil, {})
			local newState = Categories(oldState, SetCategoryAndSubcategory(nil, 3))

			expect(newState).to.never.equal(nil)
			expect(newState.category).to.equal(DEFAULT_CATEGORY)
			expect(newState.subcategory).to.equal(3)
		end)
	end)
end