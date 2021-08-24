local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local Assets = require(Modules.AvatarExperience.Common.Reducers.Assets)
local Bundles = require(Modules.AvatarExperience.Common.Reducers.Bundles)
local ItemDetailsExpanded = require(Modules.AvatarExperience.Common.Reducers.ItemDetailsExpanded)

return Rodux.combineReducers({
	Assets = Assets,
	Bundles = Bundles,
	ItemDetailsExpanded = ItemDetailsExpanded,
})