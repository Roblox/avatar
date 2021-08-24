return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local CategoryIndex = require(script.Parent.CategoryIndex)
	local SelectCategory = require(Modules.AvatarExperience.AvatarEditor.Actions.SelectCategory)

	it("should be unchanged by other actions", function()
		local oldState = CategoryIndex(nil, {})
		local newState = CategoryIndex(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should change category with SelectCategory", function()
		local oldState = CategoryIndex(nil, {})
		local newState = CategoryIndex(oldState, SelectCategory(3))

		expect(newState).to.equal(3)
	end)
end