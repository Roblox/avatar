local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local UpdateOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.UpdateOutfit)
local GetOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetOutfit)

return function(outfitId)
	return function(store)
		store:dispatch(UpdateOutfit(outfitId))
		store:dispatch(GetOutfit(outfitId))
	end
end
