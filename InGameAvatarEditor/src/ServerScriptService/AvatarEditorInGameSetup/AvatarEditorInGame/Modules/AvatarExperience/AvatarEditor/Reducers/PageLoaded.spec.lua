return function()
	local Players = game:GetService("Players")
	local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AvatarExperience = Modules.AvatarExperience
	local AvatarEditor = AvatarExperience.AvatarEditor
	local SetPageLoaded = require(AvatarEditor.Actions.SetPageLoaded)
	local PageLoaded = require(script.Parent.PageLoaded)

	describe("Action PageLoaded", function()
		it("should be unloaded by default", function()
			local state = PageLoaded(nil, {})

			expect(state).to.equal(false)
		end)

		it("should be changed using SetPageLoaded", function()
			local state = PageLoaded(nil, {})

			state = PageLoaded(state, SetPageLoaded(false))

			expect(state).to.equal(false)

			state = PageLoaded(state, SetPageLoaded(true))

			expect(state).to.equal(true)
		end)
	end)
end