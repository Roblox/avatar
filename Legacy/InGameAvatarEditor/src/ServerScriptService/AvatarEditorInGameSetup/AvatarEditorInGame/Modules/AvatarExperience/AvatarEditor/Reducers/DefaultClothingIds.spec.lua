return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local DefaultClothingIds = require(script.Parent.DefaultClothingIds)
	local SetDefaultClothingIds = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultClothingIds)
	local AEConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

	it("should be unchanged by other actions", function()
		local oldState = DefaultClothingIds(nil, {})
		local newState = DefaultClothingIds(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should store shirt and pants ids", function()
		local defaultClothingIds = {
			defaultShirtAssetIds = {
				"1",
				"2",
				"3",
			},
			defaultPantAssetIds = {
				"4",
				"5",
				"6",
			}
		}

		local state = DefaultClothingIds(nil, SetDefaultClothingIds(defaultClothingIds))

		expect(#state.defaultShirtAssetIds).to.equal(3)
		expect(#state.defaultPantAssetIds).to.equal(3)
		expect(state.defaultPantAssetIds[2]).to.equal("5")
	end)
end