return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local UIFullView = require(script.Parent.UIFullView)
	local ToggleUIFullView = require(Modules.AvatarExperience.Catalog.Actions.ToggleUIFullView)

	it("should be unchanged by other actions", function()
		local oldState = UIFullView(nil, {})
		local newState = UIFullView(oldState, { type = "some action" })
		expect(oldState).to.equal(newState)
	end)

	describe("ToggleUIFullView", function()
		it("should set the state", function()
			local state = UIFullView(nil, ToggleUIFullView(true))
			expect(state).to.equal(true)

			state = UIFullView(state, ToggleUIFullView(false))
			expect(state).to.equal(false)
		end)
	end)
end