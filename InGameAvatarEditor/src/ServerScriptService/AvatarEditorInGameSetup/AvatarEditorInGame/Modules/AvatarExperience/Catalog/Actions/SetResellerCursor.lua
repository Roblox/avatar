local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(cursor)
	ArgCheck.isTypeOrNil(cursor, "string", "cursor")

	return {
		cursor = cursor,
	}
end)