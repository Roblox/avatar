local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(userAssets)
	ArgCheck.isType(userAssets, "table", "userAssets")

	return {
		userAssets = userAssets,
	}
end)