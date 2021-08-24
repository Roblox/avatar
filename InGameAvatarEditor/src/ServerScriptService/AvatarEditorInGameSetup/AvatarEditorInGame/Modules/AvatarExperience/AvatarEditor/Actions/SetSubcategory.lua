local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Packages.ArgCheck)
local Action = require(Modules.Common.Action)

return Action("AvatarEditor-"..script.Name, function(subcategory)
	ArgCheck.isType(subcategory, "number", "subcategory")

	return {
		subcategory = subcategory,
	}
end)