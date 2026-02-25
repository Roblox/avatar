local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local AppPage = require(Modules.NotLApp.AppPage)
local ResetNavigationHistory = require(Modules.NotLApp.Thunks.ResetNavigationHistory)
local GetFFlagAvatarExperienceNavigationFix = function() return true end
local isRoactNavigationEnabled = true

local SetItemDetailsProps = require(Modules.Setup.Actions.SetItemDetailsProps)

local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local function getDefaultRoute()
	return { { name = AppPage.Home } }
end

return function()
	return function(store)
		local state = store:getState()
		local history = state.Navigation.history
		
		store:dispatch(SetItemDetailsProps(nil, nil))

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

		-- Some AE components call this function from willUpdate() which is not compatible with
		-- RN, where we are no longer dispatching navigation items through the store. We have to
		-- spawn this to avoid order of operations issues that manifest as unrelated-appearing
		-- errors like FitChildren's didUpdate being called without its rbx reference being valid.
		--[[
		if isRoactNavigationEnabled() then
			spawn(function()
				store:dispatch(ResetNavigationHistory(newRoute, newHistory))
			end)
		else
			store:dispatch(ResetNavigationHistory(newRoute, newHistory))
		end
		--]]
		store:dispatch(NavigateDown({name = AppPage.Catalog}))
	end
end
