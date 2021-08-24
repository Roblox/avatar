return function()
	local Players = game:GetService("Players")

	local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local TryOn = require(script.Parent.TryOn)

	local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
	local SetSelectedItem = require(Modules.AvatarExperience.Common.Actions.SetSelectedItem)
	local ClearAnimationPreview = require(Modules.AvatarExperience.Common.Actions.ClearAnimationPreview)
	local SetAnimationPreview = require(Modules.AvatarExperience.Common.Actions.SetAnimationPreview)

	local MOCK_ITEM_ID = "ItemId"
	local MOCK_ITEM_TYPE = "ItemType"
	local MOCK_ITEM_SUB_TYPE = "ItemSubType"

	it("should be empty by default", function()
		local defaultState = TryOn(nil, {})
		expect(defaultState.AnimationPreview).to.equal(nil)
		expect(type(defaultState.SelectedItem)).to.equal("table")
		expect(next(defaultState.SelectedItem)).to.equal(nil)
	end)

	it("should be unchanged by other actions", function()
		local oldState = TryOn(nil, {})
		local newState = TryOn(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetSelectedItem", function()
		it("should preserve purity when selecting an item", function()
			local oldState = TryOn(nil, {})
			local newState = TryOn(oldState, SetSelectedItem(MOCK_ITEM_ID, MOCK_ITEM_TYPE, MOCK_ITEM_SUB_TYPE))
			expect(oldState).to.never.equal(newState)

			local modifiedState = newState.SelectedItem
			expect(modifiedState).to.never.equal(nil)
			expect(modifiedState.itemId).to.equal(MOCK_ITEM_ID)
		end)
	end)

	describe("ClearSelectedItem", function()
		it("should unselect a selected item", function()
			local oldState = TryOn(nil, SetSelectedItem(MOCK_ITEM_ID, MOCK_ITEM_TYPE, MOCK_ITEM_SUB_TYPE))

			local newState = TryOn(oldState, ClearSelectedItem())
			expect(oldState).to.never.equal(newState)

			expect(type(newState.SelectedItem)).to.equal("table")
			expect(next(newState.SelectedItem)).to.equal(nil)
		end)
	end)

	describe("SetAnimationPreview", function()
		it("should preserve purity when setting animation preview", function()
			local oldState = TryOn(nil, {})
			local newState = TryOn(oldState, SetAnimationPreview(MOCK_ITEM_ID))
			expect(oldState).to.never.equal(newState)

			expect(newState.AnimationPreview).to.equal(MOCK_ITEM_ID)
		end)
	end)

	describe("ClearAnimationPreview", function()
		it("should clear animation preview", function()
			local oldState = TryOn(nil, SetAnimationPreview(MOCK_ITEM_ID))
			expect(oldState.AnimationPreview).to.equal(MOCK_ITEM_ID)

			local newState = TryOn(oldState, ClearAnimationPreview())
			expect(oldState).to.never.equal(newState)
			expect(newState.AnimationPreview).to.equal(nil)
		end)
	end)
end