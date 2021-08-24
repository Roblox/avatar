local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Action = require(Modules.Common.Action)

--[[
	{
		searchUuid : number
		searchType : Constants.SearchTypes,
    }
]]

return Action(script.Name, function(searchUuid, searchType)
	return {
		searchUuid = searchUuid,
		searchType = searchType,
	}
end)