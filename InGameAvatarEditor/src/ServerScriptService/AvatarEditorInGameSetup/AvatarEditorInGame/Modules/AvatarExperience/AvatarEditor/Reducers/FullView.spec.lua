return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local FullView = require(script.Parent.FullView)
	local Toggle3DFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.Toggle3DFullView)

	it("should be unchanged by other actions", function()
		local oldState = FullView(nil, {})
		local newState = FullView(oldState, { type = "some action" })
		expect(oldState).to.equal(newState)
	end)

	it("should set the state", function()
		local state = FullView(nil, Toggle3DFullView())
		expect(state).to.equal(true)

		state = FullView(state, Toggle3DFullView())
		expect(state).to.equal(false)
	end)
end