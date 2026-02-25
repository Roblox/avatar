local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ToggleUIFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleUIFullView)

return function()
	return function(store)
		store:dispatch(ToggleUIFullView())
	end
end
