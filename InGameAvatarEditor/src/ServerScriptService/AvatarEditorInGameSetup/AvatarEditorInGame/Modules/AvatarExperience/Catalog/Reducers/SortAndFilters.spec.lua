return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local SortAndFilters = require(Modules.AvatarExperience.Catalog.Reducers.SortAndFilters)

	it("has the expected fields, and only the expected fields", function()
		local state = SortAndFilters(nil, {})

		local expectedKeys = {
			CategoryFilters = true,
		}

		for key in pairs(expectedKeys) do
			expect(state[key]).to.never.equal(nil)
		end

		for key in pairs(state) do
			expect(expectedKeys[key]).to.never.equal(nil)
		end
	end)
end