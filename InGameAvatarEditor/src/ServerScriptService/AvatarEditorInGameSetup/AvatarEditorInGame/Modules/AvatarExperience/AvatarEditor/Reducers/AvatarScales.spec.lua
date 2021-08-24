return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AvatarScales = require(script.Parent.AvatarScales)
	local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)
	local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)

	it("should be unchanged by other actions", function()
		local oldState = AvatarScales(nil, {})
		local newState = AvatarScales(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should initialize scales with the default values", function()
		local state = AvatarScales(nil, {})

		expect(state.height).to.equal(1.00)
		expect(state.width).to.equal(1.00)
		expect(state.depth).to.equal(1.00)
		expect(state.head).to.equal(1.00)
		expect(state.bodyType).to.equal(0.00)
		expect(state.proportion).to.equal(0.00)
	end)

	it("should set scales with SetAvatarScales", function()
		local state = AvatarScales(nil, {})

		local newScales = {
			height = 1.05,
			width = 0.95,
			depth = 1.05,
			head = 1.05,
			bodyType = 0.95,
			proportion = 0.80,
		}

		state = AvatarScales(state, SetAvatarScales(newScales))

		expect(state.height).to.equal(1.05)
		expect(state.width).to.equal(0.95)
		expect(state.depth).to.equal(1.05)
		expect(state.head).to.equal(1.05)
		expect(state.bodyType).to.equal(0.95)
		expect(state.proportion).to.equal(0.80)
	end)

	it("should set avatar height without changing other scales", function()
		local state = AvatarScales({
			height = 1.00,
			width = 0.95,
			depth = 1.05,
			head = 1.05,
			bodyType = 0.95,
			proportion = 0.80,
		}, {})

		state = AvatarScales(state, SetAvatarScales({height = 1.05}))
		expect(state.height).to.equal(1.05)
		expect(state.width).to.equal(0.95)
		expect(state.depth).to.equal(1.05)
		expect(state.head).to.equal(1.05)
		expect(state.bodyType).to.equal(0.95)
		expect(state.proportion).to.equal(0.80)
	end)

	it("should set width", function()
		local state = AvatarScales(nil, {})

        state = AvatarScales(state, SetAvatarScales({
			width = 0.75,
			depth = 1.05,
        }))

        expect(state.height).to.equal(1.00)
        expect(state.width).to.equal(0.75)
        expect(state.depth).to.equal(1.05)
        expect(state.head).to.equal(1.00)
        expect(state.bodyType).to.equal(0.00)
        expect(state.proportion).to.equal(0.00)
	end)

	it("should set head size", function()
		local state = AvatarScales(nil, {})

		state = AvatarScales(state, SetAvatarScales({head = 0.95}))
		expect(state.height).to.equal(1.00)
		expect(state.width).to.equal(1.00)
		expect(state.depth).to.equal(1.00)
		expect(state.head).to.equal(0.95)
		expect(state.bodyType).to.equal(0.00)
		expect(state.proportion).to.equal(0.00)
	end)

	it("should set proportion", function()
		local state = AvatarScales(nil, {})

		state = AvatarScales(state, SetAvatarScales({proportion = 0.80}))
		expect(state.height).to.equal(1.00)
		expect(state.width).to.equal(1.00)
		expect(state.depth).to.equal(1.00)
		expect(state.head).to.equal(1.00)
		expect(state.bodyType).to.equal(0.00)
		expect(state.proportion).to.equal(0.80)
	end)

	it("should set body type", function()
		local state = AvatarScales(nil, {})

		state = AvatarScales(state, SetAvatarScales({bodyType = 0.95}))
		expect(state.height).to.equal(1.00)
		expect(state.width).to.equal(1.00)
		expect(state.depth).to.equal(1.00)
		expect(state.head).to.equal(1.00)
		expect(state.bodyType).to.equal(0.95)
		expect(state.proportion).to.equal(0.00)
	end)

	it("should fill in data with ReceivedAvatarData", function()
		local newScales = {
			height = 1.05,
			width = 0.95,
			depth = 1.05,
			head = 1.05,
			bodyType = 0.95,
			proportion = 0.80,
		}
		local state = AvatarScales(nil, ReceivedAvatarData({scales = newScales}))
		expect(state.height).to.equal(1.05)
		expect(state.width).to.equal(0.95)
		expect(state.depth).to.equal(1.05)
		expect(state.head).to.equal(1.05)
		expect(state.bodyType).to.equal(0.95)
		expect(state.proportion).to.equal(0.80)
	end)
end