local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Cryo = require(Modules.Packages.Cryo)
local NavigateToRoute = require(Modules.NotLApp.Thunks.NavigateToRoute)
local AppPageProperties = require(Modules.NotLApp.AppPageProperties)

return function(page, bypassNavigationLock)

	local pageProperties = AppPageProperties[page.name] or {}
	local isNativeWrapper = pageProperties.nativeWrapper or false

	if isNativeWrapper then
		page = Cryo.Dictionary.join(page, { nativeWrapper = true })
	end

	return function(store)
		local state = store:getState()

		local currentRoute = state.Navigation.history[#state.Navigation.history]
		--local newRoute = Cryo.List.join(currentRoute, { page })
		local newRoute = { page }
		store:dispatch(NavigateToRoute(newRoute, true))
	end
end
