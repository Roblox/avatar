return function()
	local Players = game:GetService("Players")
	local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local Roact = require(Modules.Packages.Roact)
	local Rodux = require(Modules.Packages.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local Categories = require(Modules.AvatarExperience.Catalog.Categories)
    local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local CategoryButton = require(Modules.AvatarExperience.Common.Components.NavBar.CategoryButton)

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer)

		local element = mockServices({
			itemDescription = Roact.createElement(CategoryButton, {
				categoryTitle = Categories[1].Title
			})
		}, {
			includeStoreProvider = true,
			store = store
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end