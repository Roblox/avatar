local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AvatarEditorService = game:GetService("AvatarEditorService")

local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local GetOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetOutfit)
local SetOwnedAssets = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOwnedAssets)
local SetAssetTypeCursor = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetTypeCursor)
local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

return function(costumeType)
	return PerformFetch.Single(AvatarExperienceConstants.UserOutfitsKey .. costumeType,
		function(store)
			local state = store:getState()

			return Promise.new(function(resolve, reject)
				local pageObject = state.AvatarExperience.AvatarEditor.AssetTypeCursor[costumeType]

				if pageObject == Constants.ReachedLastPage then
					return resolve()
				end

				if pageObject then
					local success, err = pcall(function()
						pageObject:AdvanceToNextPageAsync()
					end)
					if not success then
						warn("Error in GetUserOutfits advance" .. err)
						return reject()
					end
				else
					local success, err = pcall(function()
						pageObject = AvatarEditorService:GetOutfits()
					end)
					if not success then
						warn("Error in GetUserOutfits" ..err)
						return reject()
					end
				end

				local data = pageObject:GetCurrentPage()

				data = tableToCamelCaseKeys(data)

				local costumeIds = {}
				for _, costume in pairs(data) do
					costumeIds[#costumeIds + 1] = tostring(costume.id)

					-- Get this costume's data before showing it to prevent async problems when equipping.
					store:dispatch(GetOutfit(costume.id, costume.isEditable))
				end

				if pageObject.IsFinished then
					store:dispatch(SetAssetTypeCursor(costumeType, Constants.ReachedLastPage))
				else
					store:dispatch(SetAssetTypeCursor(costumeType, pageObject))
				end

				store:dispatch(SetOwnedAssets(costumeType, costumeIds))

				resolve()
			end)
		end)
end
