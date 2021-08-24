local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Toggle3DFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.Toggle3DFullView)

return function()
	return function(store)
		store:dispatch(Toggle3DFullView())
	end
end
