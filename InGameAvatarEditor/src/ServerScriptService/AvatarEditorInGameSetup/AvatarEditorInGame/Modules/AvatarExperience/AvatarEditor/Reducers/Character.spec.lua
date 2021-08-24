return function()
	local Character = require(script.Parent.Character)

	it("has the expected fields, and only the expected fields", function()
		local state = Character(nil, {})

		local expectedKeys = {
			AvatarType = true,
			AvatarScales = true,
			BodyColors = true,
			OwnedAssets = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end