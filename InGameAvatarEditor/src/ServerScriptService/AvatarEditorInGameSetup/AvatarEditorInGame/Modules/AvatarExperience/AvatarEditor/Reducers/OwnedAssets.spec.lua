return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local OwnedAssets = require(script.Parent.OwnedAssets)
	local SetOwnedAssets = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOwnedAssets)
	local GrantAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantAsset)
	local RevokeAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeAsset)
	local GrantOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantOutfit)
	local RevokeOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeOutfit)
	local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
	local MockId = require(Modules.NotLApp.MockId)

	describe("SetOwnedAssets", function()
		it("should be unchanged by other actions", function()
			local oldState = OwnedAssets(nil, {})
			local newState = OwnedAssets(oldState, { type = "not a real action" })
			expect(oldState).to.equal(newState)
		end)

		it("should set the assets a player owns", function()
			local assets = { 1, 2, 3 }
			local assets2 = { 4, 5, 6 }
			local newState = OwnedAssets(nil, SetOwnedAssets(1, assets))
			newState = OwnedAssets(newState, SetOwnedAssets(2, assets2))
			expect(#newState[1]).to.equal(3)
		end)

		it("should not duplicate any owned assets", function()
			local assets = { 1, 2, 3 }
			local newState = OwnedAssets(nil, SetOwnedAssets(1, assets))
			newState = OwnedAssets(newState, SetOwnedAssets(1, assets))

			expect(#newState[1]).to.equal(3)
			expect(newState[1][1]).never.to.equal(newState[1][2])
			expect(newState[1][1]).never.to.equal(newState[1][3])
		end)
	end)

	describe("GrantAsset", function()
		it("should grant an asset and move it to the front of its respective list.", function()
			local assets = { "1", "2", "3" }
			local newAsset = "5"
			local assetTypeId = "1"
			local newState = OwnedAssets(nil, SetOwnedAssets(assetTypeId, assets))

			newState = OwnedAssets(newState, GrantAsset(assetTypeId, newAsset))
			expect(newState["1"][1]).to.equal(newAsset)
			expect(#newState["1"]).to.equal(4)
		end)

		it("should not grant assets that are already owned.", function()
			local assets = { 1, 2, 3 }
			local dupAsset = 1
			local assetTypeId = 1
			local newState = OwnedAssets(nil, SetOwnedAssets(assetTypeId, assets))

			newState = OwnedAssets(newState, GrantAsset(assetTypeId, dupAsset))
			expect(#newState[1]).to.equal(3)
		end)
	end)

	describe("RevokeAsset", function()
		it("should remove an asset.", function()
			local assets = { "1", "2", "3" }
			local revokeAssetId = "1"
			local assetTypeId = "1"
			local newState = OwnedAssets(nil, SetOwnedAssets(assetTypeId, assets))
			newState = OwnedAssets(newState, RevokeAsset(assetTypeId, revokeAssetId))

			expect(#newState["1"]).to.equal(2)
			expect(newState["1"][1]).never.to.equal(revokeAssetId)
		end)
	end)

	describe("GrantOutfit", function()
		it("should grant a outfit.", function()
			local outfitId = MockId();
			local newState = OwnedAssets(nil, GrantOutfit(outfitId))
			expect(newState[AvatarEditorConstants.CharacterKey][1]).to.equal(outfitId)
		end)
		it("should not grant costumes that are already owned.", function()
			local outfitId = MockId();
			local newState = OwnedAssets(nil, GrantOutfit(outfitId))

			newState = OwnedAssets(newState, GrantOutfit(outfitId))
			expect(newState[AvatarEditorConstants.CharacterKey][1]).to.equal(outfitId)
			expect(newState[AvatarEditorConstants.CharacterKey][2]).to.equal(nil)
		end)
	end)

	describe("RevokeOutfit", function()
		it("should remove an outfit.", function()
			local outfitId = MockId();
			local newState = OwnedAssets(nil, GrantOutfit(outfitId))
			newState = OwnedAssets(newState, RevokeOutfit(outfitId))

			expect(newState[AvatarEditorConstants.CharacterKey][1]).to.equal(nil)
			expect(newState[AvatarEditorConstants.CharacterKey][1]).never.to.equal(outfitId)
		end)
	end)
end