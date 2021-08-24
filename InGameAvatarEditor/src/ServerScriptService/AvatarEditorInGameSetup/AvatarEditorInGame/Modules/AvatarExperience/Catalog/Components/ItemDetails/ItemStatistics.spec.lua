return function()
    local Players = game:GetService("Players")
    local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local Roact = require(Modules.Packages.Roact)
	local Rodux = require(Modules.Packages.Rodux)

    local AppReducer = require(Modules.LuaApp.AppReducer)
	local ItemStatistics = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemStatistics)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer)

		local element = mockServices({
			itemDescription = Roact.createElement(ItemStatistics)
		}, {
			includeStoreProvider = true,
			store = store
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
