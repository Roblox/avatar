local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ResetNavigationHistory = require(Modules.NotLApp.Thunks.ResetNavigationHistory)

local function navigateSameLevel(history, appPage)
	local newHistory = {}

	if #history > 1 then
		for i = 1, #history - 1 do
			newHistory[i] = history[i]
		end
	end

	local route = history[#history]
	local newRoute = {}

	if route and #route > 1 then
		for i = 1, #route - 1 do
			newRoute[i] = route[i]
		end

		newRoute[#newRoute + 1] = { name = appPage }
	else
		newRoute = {
			{ name = appPage }
		}
	end

	newHistory[#newHistory + 1] = newRoute
	return newRoute, newHistory
end

return function(history, appPage)
	return function(store)
		local newRoute, newHistory = navigateSameLevel(history, appPage)
		store:dispatch(ResetNavigationHistory(newRoute, newHistory))
	end
end
