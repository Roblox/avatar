local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)

--[[
	{
		searchUuid : number
		searchInCatalog : table [],
    }
]]

return Action(script.Name, function(searchUuid, searchInCatalog)
	return {
		searchUuid = searchUuid,
		searchInCatalog = searchInCatalog,
	}
end)