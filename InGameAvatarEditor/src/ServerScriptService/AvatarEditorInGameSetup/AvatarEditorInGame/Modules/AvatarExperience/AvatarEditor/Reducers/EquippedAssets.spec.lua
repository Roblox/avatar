return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local EquippedAssets = require(script.Parent.EquippedAssets)
	local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleEquipAsset)
	local EquipOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.EquipOutfit)
	local Constants = require(Modules.AvatarExperience.Common.Constants)

	local HAT_ASSET_TYPE_ID = Constants.AssetTypes.Hat

	it("should be unchanged by other actions", function()
		local oldState = EquippedAssets(nil, {})
		local newState = EquippedAssets(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("ToggleEquipAsset", function()
		it("should equip an asset with ToggleEquipAsset", function()
			local newState = EquippedAssets(nil, ToggleEquipAsset("1", "333"))
			expect(newState["1"][1]).to.equal("333")
		end)

		it("should unequip an asset with ToggleEquipAsset", function()
			local newState = EquippedAssets(nil, ToggleEquipAsset("1", "333"))

			expect(newState["1"][1]).to.equal("333")

			newState = EquippedAssets(newState, ToggleEquipAsset("1", "333"))
			expect(newState["1"][1]).never.to.be.ok()
		end)
	end)

	describe("EquipOutfit", function()
		it("should equip an outfit with EquipOutfit", function()
			local outfit = {
				["1"] = {"1"},
				["2"] = {"2"},
				["3"] = {"3"},
			}
			local newState = EquippedAssets(nil, EquipOutfit(outfit))

			expect(newState["1"][1]).to.equal("1")
			expect(newState["2"][1]).to.equal("2")
			expect(newState["3"][1]).to.equal("3")
		end)

		it("if this is not a full reset, it should replace any existing outfit parts and keep the others.", function()
			local outfit = {
				["1"] = {"1"},
				["2"] = {"2"},
				["3"] = {"3"},
			}
			local newState = EquippedAssets(nil, EquipOutfit(outfit, false))

			local newOutfit = {
				["1"] = {"1"},
				["5"] = {"2"},
			}

			newState = EquippedAssets(newState, EquipOutfit(newOutfit, false))

			expect(newState["1"][1]).to.equal("1")
			expect(newState["2"][1]).to.equal("2")
			expect(newState["3"][1]).to.equal("3")
			expect(newState["5"][1]).to.equal("2")
		end)

		it("should replace all parts of an outfit on a full reset.", function()
			local outfit = {
				["1"] = {"1"},
				["2"] = {"2"},
				["3"] = {"3"},
			}
			local newState = EquippedAssets(nil, EquipOutfit(outfit, true))

			local newOutfit = {
				["1"] = {"5"},
				["2"] = {"6"},
				["3"] = {"3"},
			}

			newState = EquippedAssets(newState, EquipOutfit(newOutfit, true))

			expect(newState["1"][1]).to.equal("5")
			expect(newState["2"][1]).to.equal("6")
			expect(newState["3"][1]).to.equal("3")
		end)
	end)

	describe("EquipOutfit and ToggleEquipAsset", function()
		it("should equip multiple hats, and only keep 3", function()
			local hatsAssetType = tostring(HAT_ASSET_TYPE_ID)
			local hats = {
				[HAT_ASSET_TYPE_ID] = {"1", "2", "3"}
			}

			local newState = EquippedAssets(nil, EquipOutfit(hats))
			expect(#newState[hatsAssetType]).to.equal(3)

			-- Max number of hats are equipped, state shouldn't change
			newState = EquippedAssets(newState, ToggleEquipAsset(HAT_ASSET_TYPE_ID, "4"))
			expect(#newState[hatsAssetType]).to.equal(3)
			expect(newState[hatsAssetType][1]).to.equal("1")
			expect(newState[hatsAssetType][2]).to.equal("2")
			expect(newState[hatsAssetType][3]).to.equal("3")

			-- Unequip a hat
			newState = EquippedAssets(newState, ToggleEquipAsset(HAT_ASSET_TYPE_ID, "1"))
			expect(#newState[hatsAssetType]).to.equal(2)
			expect(newState[hatsAssetType][1]).to.equal("2")

			-- Equip should succeed after a hat is unequipped
			newState = EquippedAssets(newState, ToggleEquipAsset(HAT_ASSET_TYPE_ID, "4"))
			expect(#newState[hatsAssetType]).to.equal(3)
			expect(newState[hatsAssetType][1]).to.equal("4")
		end)
	end)
end