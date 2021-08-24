local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(bundleId, isFavorited)
	ArgCheck.isType(bundleId, "string", "SetBundleFavorite expects bundleId")
	ArgCheck.isType(isFavorited, "boolean", "SetBundleFavorite expects isFavorited")

	return {
		bundleId = bundleId,
		isFavorited = isFavorited,
	}
end)