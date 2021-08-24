local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ArgCheck = require(Modules.Packages.ArgCheck)
local Action = require(Modules.Common.Action)

return Action(script.Name, function(marketplaceFeeInfo)
	ArgCheck.isType(marketplaceFeeInfo, "table", "marketplaceFeeInfo")
	return {
		marketplaceFeeInfo = marketplaceFeeInfo,
	}
end)