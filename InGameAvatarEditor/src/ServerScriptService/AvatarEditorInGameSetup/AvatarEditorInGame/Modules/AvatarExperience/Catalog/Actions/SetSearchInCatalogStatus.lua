local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)

--[[
	{
		searchUuid : number
		status : SearchRetrievalStatus,
    }
]]

return Action(script.Name, function(searchUuid, status)
	return {
		searchUuid = searchUuid,
		status = status,
	}
end)