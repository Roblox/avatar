local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(overlayType, arguments)
	return {
		overlayType = overlayType,
		arguments = arguments,
	}
end)