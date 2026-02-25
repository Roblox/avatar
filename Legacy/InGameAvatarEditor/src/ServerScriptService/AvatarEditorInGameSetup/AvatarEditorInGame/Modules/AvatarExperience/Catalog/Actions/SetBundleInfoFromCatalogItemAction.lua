local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(bundleId, bundleData)
	return {
		bundleId = bundleId,
		bundleData = bundleData,
	}
end)
