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
local avatarAssetTypesFromAssetTypes = require(Modules.Util.avatarAssetTypesFromAssetTypes)
local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function checkAssetExists(state, assetId)
	local existingInfo = state.AvatarExperience.Common.Assets[assetId]

	if existingInfo and existingInfo.receivedFromInventoryFetch then
		return true
	end

	return false
end

return function(categoryInfo)
	return function(store)
		ArgCheck.isType(categoryInfo, "table", "GetUserInventory thunk expects categoryInfo to be a table")

		local searchUUID = categoryInfo.SearchUuid
		if not searchUUID then
			return Promise.resolve("No SearchUUID")
		end

		local state = store:getState()
		if state.AvatarExperience.AvatarEditor.AssetTypeCursor[searchUUID] == Constants.ReachedLastPage then
			return Promise.resolve("Reached last page")
		end

		return PerformFetch.Single(AvatarExperienceConstants.UserInventoryKey .. searchUUID,
			function(_)
				return Promise.new(function(resolve, _reject)
					coroutine.wrap(function()
						state = store:getState()
						local pageObject = state.AvatarExperience.AvatarEditor.AssetTypeCursor[searchUUID]

						if pageObject then
							pageObject:AdvanceToNextPageAsync()
						else
							local assetTypes = avatarAssetTypesFromAssetTypes(categoryInfo.AssetTypes)
							pageObject = AvatarEditorService:GetInventory(assetTypes)
						end

						local data = pageObject:GetCurrentPage()
						state = store:getState()

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
							store:dispatch(SetAssetInfoFromInventoryFetch(assetsToUpdate))
						end

						store:dispatch(SetAssetTypeCursor(searchUUID, nextCursor))
						store:dispatch(SetOwnedAssets(searchUUID, ownedAssets))
						resolve(ownedAssets)
					end)()
				end)
			end)(store)
	end
end
