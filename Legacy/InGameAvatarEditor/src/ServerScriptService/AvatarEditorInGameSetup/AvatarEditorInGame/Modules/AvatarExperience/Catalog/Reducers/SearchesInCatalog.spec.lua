return function()
	local Players = game:GetService("Players")

	local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local SearchesInCatalog = require(script.Parent.SearchesInCatalog)

	local AppendSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.AppendSearchInCatalog)
	local SearchUuid = require(Modules.LuaApp.SearchUuid)
	local SortResults = require(Modules.AvatarExperience.Catalog.Models.SortResults)

	it("should be empty by default", function()
		local defaultState = SearchesInCatalog(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(next(defaultState)).to.equal(nil)
	end)

	it("should be unchanged by other actions", function()
		local oldState = SearchesInCatalog(nil, {})
		local newState = SearchesInCatalog(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("AppendSearchInCatalog", function()
		it("should preserve purity", function()
			local oldState = SearchesInCatalog(nil, {})
			local searchUuid = SearchUuid()

			local newState = SearchesInCatalog(oldState, AppendSearchInCatalog(searchUuid, {}))
			expect(oldState).to.never.equal(newState)
		end)

		it("should add sortResults", function()
			local sortResults = SortResults.mock()
			local searchUuid = SearchUuid()

			local newState = SearchesInCatalog(nil, AppendSearchInCatalog(searchUuid, sortResults))
			expect(newState[searchUuid]).to.equal(sortResults)
		end)

		it("should append to existing sort results", function()
			local sortResults = SortResults.mock()
			local searchUuid = SearchUuid()

			local state = SearchesInCatalog(nil, AppendSearchInCatalog(searchUuid, sortResults))
			expect(state[searchUuid]).to.equal(sortResults)

			local newSortResults = SortResults.mock()
			local newState = SearchesInCatalog(state, AppendSearchInCatalog(searchUuid, newSortResults))
			expect(state[searchUuid]).to.never.equal(newState[searchUuid].items)
		end)
	end)
end