return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local AssetTypeCursor = require(script.Parent.AssetTypeCursor)
	local SetAssetTypeCursor = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetTypeCursor)

	it("should be unchanged by other actions", function()
		local oldState = AssetTypeCursor(nil, {})
		local newState = AssetTypeCursor(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should set the next page cursor for an assetType", function()
		local assets = { 1, 2 }
		local testCursors = {
			"page1",
			"page2",
		}

		local newState = AssetTypeCursor(nil, SetAssetTypeCursor(assets[1], testCursors[1]))
		newState = AssetTypeCursor(newState, SetAssetTypeCursor(assets[2], testCursors[2]))
		expect(newState[assets[1]]).to.equal(testCursors[1])
		expect(newState[assets[2]]).to.equal(testCursors[2])
	end)

	it("should overwrite the next page cursor for an assetType", function()
		local assets = { 1 }
		local testCursors = {
			"page1",
			"page2",
		}

		local newState = AssetTypeCursor(nil, SetAssetTypeCursor(assets[1], testCursors[1]))
		expect(newState[assets[1]]).to.equal(testCursors[1])

		newState = AssetTypeCursor(newState, SetAssetTypeCursor(assets[1], testCursors[2]))
		expect(newState[assets[1]]).to.equal(testCursors[2])
	end)
end