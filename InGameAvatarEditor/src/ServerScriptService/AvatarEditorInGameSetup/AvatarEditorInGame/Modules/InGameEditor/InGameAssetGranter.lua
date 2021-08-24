local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = script.Parent.Parent

local GrantAsset = require(Modules.AvatarExperience.AvatarEditor.Thunks.GrantAsset)
local GrantOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.GrantOutfit)

local tableToCamelCaseKeys = require(Modules.Util.tableToCamelCaseKeys)

local function connectInGameAssetGrants(store)
	MarketplaceService.PromptPurchaseFinished:Connect(function(player, assetId, wasPurchased)
		if player == Players.LocalPlayer then
			local itemData = AvatarEditorService:GetItemDetails(assetId, Enum.AvatarItemType.Asset)
			
			itemData = tableToCamelCaseKeys(itemData)
						
			local assetTypeId =  Enum.AvatarAssetType[itemData.assetType].Value
			
			store:dispatch(GrantAsset(tostring(assetTypeId), tostring(assetId)))
		end
	end)	
	
	--pcall because we don't know for sure this method exists
	local success, err = pcall(function()
		MarketplaceService.PromptBundlePurchaseFinished:Connect(function(player, bundleId, wasPurchased)
			if player == Players.LocalPlayer then
				
				local pagesObjet = AvatarEditorService:GetOutfits()
				
				local outfitsData = pagesObjet:GetCurrentPage()
				
				outfitsData = tableToCamelCaseKeys(outfitsData)
				
				if outfitsData[1] then
					
					store:dispatch(GrantOutfit(nil, tostring(outfitsData[1].id), false))
				end
			end
		end)	
	end)
	
	AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(result)
		if result == Enum.AvatarPromptResult.Success then
			local pagesObjet = AvatarEditorService:GetOutfits()

			local outfitsData = pagesObjet:GetCurrentPage()
			
			outfitsData = tableToCamelCaseKeys(outfitsData)

			if outfitsData[1] then
				print(tostring(outfitsData[1].id))
				store:dispatch(GrantOutfit(nil, tostring(outfitsData[1].id), true))
			end
		end
	end)
	
	if not success then
		warn("prompt bundle connection failed")
	end
end

return connectInGameAssetGrants
