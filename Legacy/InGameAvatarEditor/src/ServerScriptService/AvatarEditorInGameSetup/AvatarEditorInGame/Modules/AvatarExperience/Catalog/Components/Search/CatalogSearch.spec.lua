return function()
	local Players = game:GetService("Players")

    local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
    local Roact = require(Modules.Packages.Roact)

    local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local RoactNetworking = require(Modules.Services.RoactNetworking)

	local CatalogSearch = require(Modules.AvatarExperience.Catalog.Components.Search.CatalogSearch)
	local SortResults = require(Modules.AvatarExperience.Catalog.Models.SortResults)

	if not true then
		return
	end

	local mockProperties = {
		searchUuid = 1,
		searchParameters = {
			searchKeyword = "Tie",
		},
	}

	local function testSearchPage(networkImpl)
		local mockStore = MockStore.new()

		local element = mockServices({
			CatalogSearch = Roact.createElement(CatalogSearch, mockProperties)
		}, {
			includeStoreProvider = true,
			store = mockStore,
			includeThemeProvider = true,
			extraServices = {
				[RoactNetworking] = networkImpl,
			},
		})

        local instance = Roact.mount(element)

		-- Force the store to update right away
		mockStore:flush()
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when search succeeds", function()
		local mockSearchResult = SortResults.mock()

		testSearchPage(MockRequest.simpleSuccessRequest(mockSearchResult))
	end)

	it("should create and destroy without errors when search is loading", function()
		testSearchPage(MockRequest.simpleOngoingRequest())
	end)

	it("should create and destroy without errors when search fails", function()
		testSearchPage(MockRequest.simpleFailRequest("error"))
	end)
end