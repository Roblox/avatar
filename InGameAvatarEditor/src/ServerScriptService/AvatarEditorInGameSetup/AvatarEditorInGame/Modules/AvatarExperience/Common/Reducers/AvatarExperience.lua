local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local AvatarScene = require(Modules.AvatarExperience.Common.Reducers.AvatarScene)
local Common = require(Modules.AvatarExperience.Common.Reducers.Common)

local AvatarEditor = require(Modules.AvatarExperience.AvatarEditor.Reducers.AvatarEditor)
local Catalog = require(Modules.AvatarExperience.Catalog.Reducers.Catalog)

return Rodux.combineReducers({
	AvatarEditor = AvatarEditor,
	Catalog = Catalog,
	Common = Common,
	AvatarScene = AvatarScene,
})