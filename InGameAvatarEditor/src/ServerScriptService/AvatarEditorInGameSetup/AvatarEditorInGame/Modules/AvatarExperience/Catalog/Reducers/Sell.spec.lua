return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local SellReducer = require(Modules.AvatarExperience.Catalog.Reducers.Sell)

	it("has the expected fields, and only the expected fields", function()
		local state = SellReducer(nil, {})

		local expectedKeys = {
			AvailableToSellAssets = true,
			CurrentlySellingAssets = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end