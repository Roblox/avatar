return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local DefaultBodyColors = require(script.Parent.DefaultBodyColors)
	local SetDefaultBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultBodyColors)

	it("should be unchanged by other actions", function()
		local oldState = DefaultBodyColors(nil, {})
		local newState = DefaultBodyColors(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should store body color information", function()
		local defaultBodyColors = {
            {
                brickColorId = 364,
                hexColor = "#5A4C42",
                name = "Dark taupe"
            },
            {
                brickColorId = 217,
                hexColor = "#7C5C46",
                name = "Brown"
            },
		}

		local state = DefaultBodyColors(nil, SetDefaultBodyColors(defaultBodyColors))

		expect(#state).to.equal(2)
        expect(state[1].brickColorId).to.equal(364)
        expect(state[1].hexColor).to.equal("#5A4C42")
        expect(state[2].name).to.equal("Brown")
	end)
end