local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(itemId, itemType, itemSubType)
	ArgCheck.isType(itemId, "string", "SetSelectedItem: itemId")
	ArgCheck.isType(itemType, "string", "SetSelectedItem: itemType")
	ArgCheck.isType(itemSubType, "string", "SetSelectedItem: itemSubType")

	return {
		itemId = itemId,
		itemType = itemType,
		itemSubType = itemSubType,
	}
end)