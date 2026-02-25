local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(categoryIndex, tabIndex)
	return {
		categoryIndex = categoryIndex,
		tabIndex = tabIndex,
	}
end)