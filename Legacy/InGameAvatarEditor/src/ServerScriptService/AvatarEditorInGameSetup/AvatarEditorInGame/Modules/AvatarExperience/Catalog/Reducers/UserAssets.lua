local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local SetUserAssetsFromSellPageAndResellers =
	require(Modules.AvatarExperience.Catalog.Actions.SetUserAssetsFromSellPageAndResellers)
local UpdateUserAssetPrice = require(Modules.AvatarExperience.Catalog.Actions.UpdateUserAssetPrice)
local UserAssetModel = require(Modules.AvatarExperience.Catalog.Models.UserAssetModel)
local Cryo = require(Modules.Packages.Cryo)

return Rodux.createReducer({}, {
	--[[
		action.userAssets: table
	]]
	[SetUserAssetsFromSellPageAndResellers.name] = function(state, action)
		local changedUserAssets = {}

		for _, entry in pairs(action.userAssets) do
			local userAssetId = tostring(entry.userAssetId)
			local newUserAssetInfo = UserAssetModel.fromSellPageAndResellers(entry)

			local existingInfo = state[userAssetId]
			if existingInfo then
                changedUserAssets[userAssetId] = Cryo.Dictionary.join(existingInfo, newUserAssetInfo)
			else
                changedUserAssets[userAssetId] = newUserAssetInfo
			end
		end

		return Cryo.Dictionary.join(state, changedUserAssets)
	end,

	--[[
		action.userAssetId: string
		action.priceInRobux: optional int
	]]
	[UpdateUserAssetPrice.name] = function(state, action)
		local userAssetId = tostring(action.userAssetId)
		local priceInRobux = action.priceInRobux
		local newUserAssetInfo = UserAssetModel.fromPriceInRobux(userAssetId, priceInRobux)

		local existingInfo = state[userAssetId]
		if existingInfo then
			return Cryo.Dictionary.join(state, {
				[userAssetId] = Cryo.Dictionary.join(existingInfo, newUserAssetInfo),
			})
		else
			return Cryo.Dictionary.join(state, {
				[userAssetId] = newUserAssetInfo,
			})
		end
	end,
})