local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local Reducers = script.Parent

return Rodux.combineReducers({
	AvatarType = require(Reducers.AvatarType),
	AvatarScales = require(Reducers.AvatarScales),
	BodyColors = require(Reducers.BodyColors),
	OwnedAssets = require(Reducers.OwnedAssets),
	EquippedAssets = require(Reducers.EquippedAssets),
})