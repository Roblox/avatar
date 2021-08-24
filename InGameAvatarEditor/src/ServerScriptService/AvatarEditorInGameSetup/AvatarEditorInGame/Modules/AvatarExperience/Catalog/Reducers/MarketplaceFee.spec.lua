return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local MarketplaceFee = require(Modules.AvatarExperience.Catalog.Reducers.MarketplaceFee)
	local SetMarketplaceFee = require(Modules.AvatarExperience.Catalog.Actions.SetMarketplaceFee)

	local MARKETPLACE_FEE = 0.3
	local MINIMUM_FEE = 1

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	it("should be empty by default", function()
		local defaultState = MarketplaceFee(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = MarketplaceFee(nil, {})
		local newState = MarketplaceFee(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetMarketplaceFee", function()
		it("should override the previous marketplace fee", function()
			local oldState = MarketplaceFee(nil, {})
			local mockData = {
				taxRate = MARKETPLACE_FEE,
				minimumFee = MINIMUM_FEE,
			}
			local newState = MarketplaceFee(oldState, SetMarketplaceFee(mockData))
			expect(oldState).to.never.equal(newState)
			expect(newState.taxRate).to.equal(MARKETPLACE_FEE)
			expect(newState.minimumFee).to.equal(MINIMUM_FEE)
		end)
	end)
end