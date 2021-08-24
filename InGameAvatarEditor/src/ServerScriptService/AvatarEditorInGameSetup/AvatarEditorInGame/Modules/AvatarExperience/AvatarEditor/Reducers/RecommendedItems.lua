local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Cryo = require(Modules.Packages.Cryo)
local Rodux = require(Modules.Packages.Rodux)
local ArgCheck = require(Modules.Common.ArgCheck)
local SetRecommendedItems = require(Modules.AvatarExperience.AvatarEditor.Actions.SetRecommendedItems)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

return Rodux.createReducer(
	{}
, {
	--[[
		Set recommended item ids for a given assetTypeId. Expects data from the catalog/v1/recommendations endpoint.
	]]
	[SetRecommendedItems.name] = function(state, action)
		ArgCheck.isType(action.assetTypeId, "string", "assetTypeId must be a string.")
		ArgCheck.isType(action.assets, "table", "assets data must be a table.")

		if action.assetTypeId == AvatarEditorConstants.RecommendationsType.BodyParts or
			action.assetTypeId == AvatarEditorConstants.RecommendationsType.AvatarAnimations then
			local assetType = action.assetTypeId
			local assets = action.assets

			local assetIds = {}

			for _, asset in ipairs(assets) do
				local assetId = asset and asset.id or nil
				if assetId then
					assetIds[#assetIds + 1] = tostring(assetId)
				end

				-- Only show 6 recommended items.
				if #assetIds >= AvatarEditorConstants.NumRecommendedItems then
					break
				end
			end

			return Cryo.Dictionary.join(state, {
				[assetType] = assetIds,
			})
		else
			local assetTypeId = action.assetTypeId
			local assets = action.assets

			local assetIds = {}

			for _, asset in ipairs(assets) do
				local assetId = asset.item and asset.item.assetId or nil
				if assetId then
					assetIds[#assetIds + 1] = tostring(assetId)
				end
			end

			return Cryo.Dictionary.join(state, {
				[assetTypeId] = assetIds,
			})
		end
	end,
})
