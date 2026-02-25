local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules

local Rodux = require(Modules.Packages.Rodux)

local SetItemDetailsExpanded = require(Modules.AvatarExperience.Common.Actions.SetItemDetailsExpanded)

return Rodux.createReducer(false, {
	[SetItemDetailsExpanded.name] = function(state, action)
		return action.itemDetailsExpanded
	end,
})