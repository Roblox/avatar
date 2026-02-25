return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local ResellerCursor = require(script.Parent.ResellerCursor)
	local SetResellerCursor = require(Modules.AvatarExperience.Catalog.Actions.SetResellerCursor)
	local MockId = require(Modules.NotLApp.MockId)

	local DUMMY_CURSOR = "abc"

	local function countChildObjects(aTable)
		local numChildren = 0
		for _ in pairs(aTable) do
			numChildren = numChildren + 1
		end

		return numChildren
	end

	it("should be empty by default", function()
		local status = ResellerCursor(nil, {})
		expect(type(status)).to.equal("table")
		expect(countChildObjects(status)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = ResellerCursor(nil, {})
		local newState = ResellerCursor(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetResellerCursor", function()
		it("should preserve purity", function()
			local oldState = ResellerCursor(nil, {})
			local newState = ResellerCursor(oldState, SetResellerCursor(DUMMY_CURSOR))
			expect(oldState).to.never.equal(newState)
			expect(newState.nextPageCursor).to.equal(DUMMY_CURSOR)
		end)

		it("should correctly update hasMoreRows based off the cursor", function()
			local oldState = ResellerCursor(nil, SetResellerCursor(DUMMY_CURSOR))
			expect(oldState.hasMoreRows).to.equal(true)

			local newState = ResellerCursor(oldState, SetResellerCursor(nil))
			expect(oldState).to.never.equal(newState)
			expect(newState.hasMoreRows).to.equal(false)
		end)

		it("should override an existing cursor", function()
			local oldState = ResellerCursor(nil, SetResellerCursor(DUMMY_CURSOR))
			expect(oldState.nextPageCursor).to.equal(DUMMY_CURSOR)

			local newCursor = tostring(MockId())
			local newState = ResellerCursor(oldState, SetResellerCursor(newCursor))
			expect(oldState).to.never.equal(newState)
			expect(newState.nextPageCursor).to.equal(newCursor)
		end)
	end)
end