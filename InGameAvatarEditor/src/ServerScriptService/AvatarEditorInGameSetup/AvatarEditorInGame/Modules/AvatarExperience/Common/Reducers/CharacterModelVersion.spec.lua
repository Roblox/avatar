return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local CharacterModelVersion = require(script.Parent.CharacterModelVersion)
	local IncrementCharacterModelVersion =
		require(Modules.AvatarExperience.AvatarEditor.Actions.IncrementCharacterModelVersion)

	it("should be unchanged by other actions", function()
		local oldState = CharacterModelVersion(nil, {})
		local newState = CharacterModelVersion(oldState, { type = "some action" })
		expect(oldState).to.equal(newState)
	end)

	it("should have the character model version be 0 on startup", function()
		local state = CharacterModelVersion(nil, {})
		expect(state).to.equal(0)
	end)

	it("should increment the character model version.", function()
		local state = CharacterModelVersion(nil, IncrementCharacterModelVersion())
		expect(state).to.equal(1)
	end)
end