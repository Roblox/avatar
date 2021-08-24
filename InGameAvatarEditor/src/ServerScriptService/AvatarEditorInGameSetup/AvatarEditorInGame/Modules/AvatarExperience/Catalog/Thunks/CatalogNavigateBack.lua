local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AppPage = require(Modules.NotLApp.AppPage)
local ResetNavigationHistory = require(Modules.NotLApp.Thunks.ResetNavigationHistory)
local NavigateToRoute = require(Modules.NotLApp.Thunks.NavigateToRoute)
local GetFFlagAvatarExperienceNavigationFix = function() return true end
local FFlagAvatarExperienceEmptyHistoryFix = true

local function getDefaultRoute()
	return { { name = AppPage.Home } }
end

return function()
	return function(store)
		local state = store:getState()
		local history = state.Navigation.history

		local currentRoute = history[#history]
		if not currentRoute then
			currentRoute = getDefaultRoute()
		end

		local newRoute = {}
		for index = 1, #currentRoute do
			if currentRoute[index].name ~= AppPage.ItemDetails then
				newRoute[#newRoute + 1] = currentRoute[index]
			end
		end

		-- Ensure that the history isn't being overwritten with an empty route. Fall back to the HomePage.
		if #newRoute == 0 then
			if GetFFlagAvatarExperienceNavigationFix() then
				return store:dispatch(NavigateToRoute(getDefaultRoute()))
			else
				newRoute = getDefaultRoute()
			end
		end

		local newHistory = {}
		if not FFlagAvatarExperienceEmptyHistoryFix or (FFlagAvatarExperienceEmptyHistoryFix and #newRoute > 1) then
			for i = 1, #newRoute - 1 do
				local tempRoute = {}
				for j = 1, i do
					tempRoute[#tempRoute + 1] = newRoute[j]
				end
				newHistory[#newHistory + 1] = tempRoute
			end
		elseif FFlagAvatarExperienceEmptyHistoryFix then
			newHistory = { newRoute }
		end

		return store:dispatch(ResetNavigationHistory(newRoute, newHistory))
	end
end