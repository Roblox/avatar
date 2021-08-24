local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AppPage = require(Modules.NotLApp.AppPage)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local GetFFlagAvatarExperienceNavigationFix = function() return true end

local function getDefaultRoute()
	return { { name = AppPage.Home } }
end

return function(newItemDetailsPage)
	return function(store)
		local state = store:getState()
		local history = state.Navigation.history

		local currentRoute = history[#history]
		if GetFFlagAvatarExperienceNavigationFix() and not currentRoute then
			currentRoute = getDefaultRoute()
		end

		local newRoute = {}
		for index = 1, #currentRoute do
			if currentRoute[index].name ~= AppPage.ItemDetails then
				newRoute[#newRoute + 1] = currentRoute[index]
			end
		end

		newRoute[#newRoute + 1] = newItemDetailsPage

		-- Ensure that the history isn't being overwritten with an empty route
		if GetFFlagAvatarExperienceNavigationFix() and #newRoute == 0 then
			newRoute = getDefaultRoute()
		end

		local newHistory = {}
		for i = 1, #newRoute do
			local tempRoute = {}
			for j = 1, i do
				tempRoute[#tempRoute + 1] = newRoute[j]
			end
			newHistory[#newHistory + 1] = tempRoute
		end

		store:dispatch(NavigateDown({ name = AppPage.ItemDetails }))
	end
end