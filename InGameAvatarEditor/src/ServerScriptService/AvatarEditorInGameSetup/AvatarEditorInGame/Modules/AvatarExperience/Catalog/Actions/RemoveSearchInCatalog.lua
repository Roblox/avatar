local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)

--[[
	{
		searchUuid : number
    }
]]

return Action(script.Name, function(searchUuid)
	return {
		searchUuid = searchUuid,
	}
end)