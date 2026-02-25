local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(sortResults)
     ArgCheck.isType(sortResults, "table", "SetAssetInfoFromSortResults expects sortResults")

	return {
        sortResults = sortResults,
	}
end)