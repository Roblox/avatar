local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AvatarEditorService = game:GetService("AvatarEditorService")

local Promise = require(Modules.Packages.Promise)
local Logging = require(Modules.Packages.Logging)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local ArgCheck = require(Modules.Common.ArgCheck)
local SetAvatarSettings = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarSettings)
local SetDefaultClothingIds = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultClothingIds)
local SetDefaultBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultBodyColors)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function keyMapper()
	return "avatareditor.getavatarrules"
end

return function()
	return PerformFetch.Single(keyMapper(),
		function(store)
			return Promise.new(function(resolve, reject)

				local avatarRulesData
				pcall(function()
					avatarRulesData = AvatarEditorService:GetAvatarRules()
				end)

				if avatarRulesData then
					avatarRulesData = tableToCamelCaseKeys(avatarRulesData)

					local minimumDeltaEBodyColorDifference = avatarRulesData["minimumDeltaEBodyColorDifference"]
					local defaultClothingAssetLists = avatarRulesData["defaultClothingAssetLists"]
					local scalesRules = avatarRulesData["scales"]
					local bodyColors = avatarRulesData["basicBodyColorsPalette"]

					store:dispatch(SetAvatarSettings(minimumDeltaEBodyColorDifference, scalesRules))

					if defaultClothingAssetLists then
						store:dispatch(SetDefaultClothingIds(defaultClothingAssetLists))
					end

					if bodyColors then
						store:dispatch(SetDefaultBodyColors(bodyColors))
					end
				else
					warn("Error in get avatar rules")
				end
			end)
		end)
end
