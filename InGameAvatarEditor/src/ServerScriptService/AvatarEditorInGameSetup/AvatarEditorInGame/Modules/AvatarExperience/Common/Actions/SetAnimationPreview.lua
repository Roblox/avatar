local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(assetId)
	ArgCheck.isType(assetId, "string", "SetAnimationPreview: assetId")

	return {
        assetId = assetId,
	}
end)