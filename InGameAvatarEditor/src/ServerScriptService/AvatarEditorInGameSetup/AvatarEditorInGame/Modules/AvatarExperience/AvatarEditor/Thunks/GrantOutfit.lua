local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local GrantOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantOutfit)
local GetOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetOutfit)

return function(outfitId, isEditable)
	return function(store)
		store:dispatch(GrantOutfit(outfitId))
		store:dispatch(GetOutfit(outfitId, isEditable))
	end
end
