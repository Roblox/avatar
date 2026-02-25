return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AvatarSettings = require(script.Parent.AvatarSettings)
	local SetAvatarSettings = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarSettings)
	local AEConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

	local MOCK_MIN_DELTA = 11.2
	local MOCK_SCALE_VALUES = {}

	it("should be unchanged by other actions", function()
		local oldState = AvatarSettings(nil, {})
		local newState = AvatarSettings(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should set the min delta for similar body colors", function()
		local state = AvatarSettings(nil, SetAvatarSettings(MOCK_MIN_DELTA, MOCK_SCALE_VALUES))
		expect(state.ObtainedAvatarRules).to.equal(true)
		expect(state[AEConstants.AvatarSettings.minDeltaBodyColorDifference]).to.equal(MOCK_MIN_DELTA)
		expect(state[AEConstants.AvatarSettings.scalesRules]).to.equal(MOCK_SCALE_VALUES)
	end)

	it("should set the scale values", function()
		local state = AvatarSettings(nil, SetAvatarSettings(MOCK_MIN_DELTA, MOCK_SCALE_VALUES))
		expect(state.ObtainedAvatarRules).to.equal(true)
		expect(state[AEConstants.AvatarSettings.scalesRules]).to.equal(MOCK_SCALE_VALUES)
	end)
end