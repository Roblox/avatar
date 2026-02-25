local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local ArgCheck = require(Modules.Common.ArgCheck)
local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)

local function keyMapper()
	return "avatareditor.getavatardata"
end

return function()
	return PerformFetch.Single(keyMapper(),
		function(store)
			return Promise.new(function(resolve, reject)
				local avatarData = Players:GetCharacterAppearanceInfoAsync(Players.LocalPlayer.UserId)

				store:dispatch(ReceivedAvatarData(avatarData))

				resolve()
			end)
		end)
end
