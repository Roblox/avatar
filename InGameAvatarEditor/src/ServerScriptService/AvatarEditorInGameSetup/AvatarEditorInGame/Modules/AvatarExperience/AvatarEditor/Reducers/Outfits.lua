local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetOutfitInfo = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOutfitInfo)
local RevokeOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeOutfit)
local UpdateOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.UpdateOutfit)

return Rodux.createReducer({}, {
	[SetOutfitInfo.name] = function(state, action)
        return Cryo.Dictionary.join(state, {[tostring(action.outfit.outfitId)] = action.outfit})
    end,
	[RevokeOutfit.name] = function(state, action)
        local outfitId = tostring(action.outfitId)
        return Cryo.Dictionary.join(state, {[outfitId] = Cryo.None})
	end,
	[UpdateOutfit.name] = function(state, action)
        -- To update outfit: remove the outfit info from the state. Because we
		-- don't remove it from AEOwnedAssets, its info will be regotten from the webapi
		local outfitId = tostring(action.outfitId)
		return Cryo.Dictionary.join(state, {[outfitId] = Cryo.None})
	end
})