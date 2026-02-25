local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(selectedSlot)
	return {
		selectedSlot = selectedSlot,
	}
end)