return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local CategoryFilters = require(script.Parent.CategoryFilters)

	local SelectCategoryFilters = require(Modules.AvatarExperience.Catalog.Actions.SelectCategoryFilters)

	it("should be empty by default", function()
		local defaultState = CategoryFilters(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(next(defaultState)).to.equal(nil)
	end)

	it("should be unchanged by other actions", function()
		local oldState = CategoryFilters(nil, {})
		local newState = CategoryFilters(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SelectCategoryFilters", function()
		it("should preserve purity", function()
			local oldState = CategoryFilters(nil, {})
			local newState = CategoryFilters(oldState, SelectCategoryFilters({ some_filter = true }))
			expect(oldState).to.never.equal(newState)
		end)

		it("should set categoryFilters", function()
			local categoryFilters = { some_filter = true, some_other_filter = false }
			local newState = CategoryFilters(nil, SelectCategoryFilters(categoryFilters))
			expect(newState).to.equal(categoryFilters)
		end)

		it("should clear categoryFilters", function()
			local categoryFilters = { some_filter = true }
			local oldState = CategoryFilters(nil, categoryFilters)
			local state = CategoryFilters(oldState, SelectCategoryFilters({}))
			expect(newState).to.equal({})
		end)
	end)
end