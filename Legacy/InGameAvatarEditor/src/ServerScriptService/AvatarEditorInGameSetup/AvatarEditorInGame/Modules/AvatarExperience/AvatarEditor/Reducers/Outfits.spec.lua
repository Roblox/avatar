return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local Outfits = require(script.Parent.Outfits)
	local SetOutfitInfo = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOutfitInfo)
	local RevokeOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeOutfit)
	local UpdateOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.UpdateOutfit)
	local OutfitInfo = require(Modules.AvatarExperience.AvatarEditor.Models.OutfitInfo)

	it("should be unchanged by other actions", function()
		local oldState = Outfits(nil, {})
		local newState = Outfits(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should save an outfit's info (list of assets and body colors)", function()
		local outfit = OutfitInfo.mock()
		outfit.assets = { 1, 2, 3 }

		local oldState = Outfits(nil, {})
		local newState = Outfits(oldState, SetOutfitInfo(outfit))

		expect(newState[outfit.outfitId]).to.equal(outfit)

	end)

	it("should save multiple outfits, without changing other outfits.", function()
		local outfit = OutfitInfo.mock()
		outfit.assets = { 1, 2, 3 }
		local outfit2 = OutfitInfo.mock()

		local oldState = Outfits(nil, {})
		local newState = Outfits(oldState, SetOutfitInfo(outfit))
		expect(newState[outfit.outfitId]).to.equal(outfit)

		newState = Outfits(newState, SetOutfitInfo(outfit2))
		expect(newState[outfit.outfitId]).to.equal(outfit)
		expect(newState[outfit2.outfitId]).to.equal(outfit2)
	end)

	it("Should remove an outfit's information, without changing other outfits.", function()
			local outfit = OutfitInfo.mock()
			outfit.assets = { 1, 2, 3 }
			local outfit2 = OutfitInfo.mock()

			Outfits(nil, SetOutfitInfo(outfit))
			local oldState = Outfits(newState, SetOutfitInfo(outfit2))
			local newState = Outfits(oldState, RevokeOutfit(outfit.outfitId))
			expect(newState[outfit.outfitId]).to.equal(nil)
			expect(newState[outfit2.outfitId]).to.equal(outfit2)

			newState = Outfits(oldState, UpdateOutfit(outfit2.outfitId))
			expect(newState[outfit2.outfitId]).to.equal(nil)
	end)
end