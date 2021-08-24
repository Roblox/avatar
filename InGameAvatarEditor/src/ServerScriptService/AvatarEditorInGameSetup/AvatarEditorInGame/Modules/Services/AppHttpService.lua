local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local requestService = require(Modules.Http.request)

local AppHttpService = {}

function AppHttpService.new(store, guiService)
	return function(url, requestMethod, options)
		local httpPromise, cancel = requestService(url, requestMethod, options)

		return httpPromise, cancel
	end
end

return AppHttpService
