return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local SetAvatarTypeAction = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarType)
	local ReceivedAvatarDataAction = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)
	local AvatarType = require(script.Parent.AvatarType)
	local AEConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

	it("should be R15 by default", function()
		local state = AvatarType(nil, {})
		expect(state).to.equal(AEConstants.AvatarType.R15)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AvatarType(nil, {})
		local newState = AvatarType(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should preserve purity", function()
		local oldState = AvatarType(nil, {})
		local newState = AvatarType(oldState, SetAvatarTypeAction(AEConstants.AvatarType.R6))
		expect(oldState).to.never.equal(newState)
	end)

	it("should change avatar type", function()
		local newState = AvatarType(nil, SetAvatarTypeAction(AEConstants.AvatarType.R6))
		expect(newState).to.equal(AEConstants.AvatarType.R6)

		newState = AvatarType(newState, SetAvatarTypeAction(AEConstants.AvatarType.R15))
		expect(newState).to.equal(AEConstants.AvatarType.R15)
	end)

	it ("should remain R15 with with ReceivedAvatarDataAction with empty table", function()
		local newState = AvatarType(nil, ReceivedAvatarDataAction({}))
		expect(newState).to.equal(AEConstants.AvatarType.R15)
	end)

	it ("should change avatar type with ReceivedAvatarDataAction", function()
		local newState = AvatarType(nil, ReceivedAvatarDataAction({playerAvatarType = AEConstants.AvatarType.R6}))
		expect(newState).to.equal(AEConstants.AvatarType.R6)
	end)

	it ("should not change avatar type with invalid avatar type passed by ReceivedAvatarDataAction", function()
		local newState = AvatarType(nil, ReceivedAvatarDataAction({playerAvatarType = "Invalid"}))
		expect(newState).to.equal(AEConstants.AvatarType.R15)
	end)
end