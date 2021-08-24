local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarType)

return function(avatarType)
	return function(store)
		store:dispatch(SetAvatarType(avatarType))
	end
end