local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

--[[
	userId: string,
	robux: number,
]]

return Action(script.Name, function(userId, robux)
	assert(type(userId) == "string", "SetUserRobux: universeId must be a string")
	assert(type(robux) == "number", "SetUserRobux: robux must be a number")

	return {
		userId = userId,
		robux = robux,
	}
end)