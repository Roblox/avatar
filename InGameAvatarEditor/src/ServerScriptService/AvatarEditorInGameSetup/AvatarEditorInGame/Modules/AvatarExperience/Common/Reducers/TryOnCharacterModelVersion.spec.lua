return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local TryOnCharacterModelVersion = require(script.Parent.TryOnCharacterModelVersion)
	local IncrementTryOnCharacterModelVersion = require(Modules.AvatarExperience.Catalog.Actions.IncrementTryOnCharacterModelVersion)

	it("should be unchanged by other actions", function()
		local oldState = TryOnCharacterModelVersion(nil, {})
		local newState = TryOnCharacterModelVersion(oldState, { type = "some action" })
		expect(oldState).to.equal(newState)
	end)

	it("should have the character model version be 0 on startup", function()
		local state = TryOnCharacterModelVersion(nil, {})
		expect(state).to.equal(0)
	end)

	it("should increment the character model version.", function()
		local state = TryOnCharacterModelVersion(nil, IncrementTryOnCharacterModelVersion())
		expect(state).to.equal(1)
	end)
end