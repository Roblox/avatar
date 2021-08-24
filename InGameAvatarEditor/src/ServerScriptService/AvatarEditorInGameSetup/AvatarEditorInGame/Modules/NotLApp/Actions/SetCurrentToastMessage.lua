local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(toastMessage)
	assert(type(toastMessage) == "table", "SetCurrentToastMessage action expects toastMessage to be a table")

	return {
		toastMessage = toastMessage,
	}
end)