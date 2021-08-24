local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Common.ArgCheck)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetOwnedAssets = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOwnedAssets)
local SetAssetTypeCursor = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetTypeCursor)
local SetAssetInfoFromInventoryFetch =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromInventoryFetch)
local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local Promise = require(Modules.Packages.Promise)
local avatarAssetTypeFromTypeId = require(Modules.Util.avatarAssetTypeFromTypeId)
local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function checkAssetExists(state, assetId)
	local existingInfo = state.AvatarExperience.Common.Assets[assetId]

	if existingInfo and existingInfo.receivedFromInventoryFetch then
		return true
	end

	return false
end

return function(assetTypeId)
	return function(store)
		ArgCheck.isType(assetTypeId, "string", "GetUserInventory thunk expects assetTypeId to be a string")

		local state = store:getState()
		if state.AvatarExperience.AvatarEditor.AssetTypeCursor[assetTypeId] == Constants.ReachedLastPage then
			return Promise.resolve("Reached last page")
		end

		if assetTypeId == "Skin Tone" then
			return Promise.resolve()
		end

		return PerformFetch.Single(AvatarExperienceConstants.UserInventoryKey .. assetTypeId,
			function(store)
				return Promise.new(function(resolve, reject)
					coroutine.wrap(function()
						local state = store:getState()
						local userId = state.LocalUserId
						local pageObject = state.AvatarExperience.AvatarEditor.AssetTypeCursor[assetTypeId]

						if pageObject then
							pageObject:AdvanceToNextPageAsync()
						else
							pageObject = AvatarEditorService:GetInventory({avatarAssetTypeFromTypeId(assetTypeId)})
						end

						local data = pageObject:GetCurrentPage()
						local state = store:getState()

						data = tableToCamelCaseKeys(data)

						local assetsToUpdate = {}
						local ownedAssets = {}
						for _, asset in ipairs(data) do
							local assetId = tostring(asset.assetId)
							ownedAssets[#ownedAssets + 1] = assetId

							if not checkAssetExists(state, assetId) then
								assetsToUpdate[#assetsToUpdate + 1] = asset
							end
						end

						local nextCursor = pageObject.IsFinished and Constants.ReachedLastPage or pageObject

						if #assetsToUpdate then
							store:dispatch(SetAssetInfoFromInventoryFetch(assetsToUpdate, assetTypeId))
						end

						store:dispatch(SetAssetTypeCursor(assetTypeId, nextCursor))
						store:dispatch(SetOwnedAssets(assetTypeId, ownedAssets))
						resolve(ownedAssets)
					end)()
				end)
			end)(store)
	end
end
