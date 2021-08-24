return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AvatarEditor = require(Modules.AvatarExperience.AvatarEditor.Reducers.AvatarEditor)

	it("has the expected fields, and only the expected fields", function()
		local state = AvatarEditor(nil, {})

		local expectedKeys = {
			PageLoaded = true,
			Character = true,
			Categories = true,
			EquippedEmotes = true,
			Outfits = true,
			AvatarSettings = true,
			DefaultClothingIds = true,
			DefaultBodyColors = true,
			AssetTypeCursor = true,
			FullView = true,
			UIFullView = true,
			RecommendedItems = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end