return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local Catalog = require(Modules.AvatarExperience.Catalog.Reducers.Catalog)

	it("has the expected fields, and only the expected fields", function()
		local state = Catalog(nil, {})

		local expectedKeys = {
			AssetFavorites = true,
			BundleFavorites = true,
			Categories = true,
			FullView = true,
			UIFullView = true,
			MarketplaceFee = true,
			Sell = true,
			SortsContents = true,
			ResellerCursor = true,
			UserAssets = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end