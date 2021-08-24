
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local NavigateToRoute = require(Modules.NotLApp.Thunks.NavigateToRoute)
local Cryo = require(Modules.Packages.Cryo)


return function(page, bypassNavigationLock)

	return function(store)
		local state = store:getState()

		local oldRoute = state.Navigation.history[#state.Navigation.history]
		local truncatedRoute = Cryo.List.removeIndex(oldRoute, #oldRoute)
		local newRoute = Cryo.List.join(truncatedRoute, { page })
		store:dispatch(NavigateToRoute(newRoute, bypassNavigationLock))
	end
end
