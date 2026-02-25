local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Reducers = script.Parent

return Rodux.combineReducers({
	Character = require(Reducers.Character),
	Categories = require(Reducers.Categories),
	EquippedEmotes = require(Reducers.EquippedEmotes),
	Outfits = require(Reducers.Outfits),
	AvatarSettings = require(Reducers.AvatarSettings),
	DefaultClothingIds = require(Reducers.DefaultClothingIds),
	DefaultBodyColors = require(Reducers.DefaultBodyColors),
	AssetTypeCursor = require(Reducers.AssetTypeCursor),
	FullView = require(Reducers.FullView),
	RecommendedItems = require(Reducers.RecommendedItems),
	UIFullView = require(Reducers.UIFullView),
    PageLoaded = require(Reducers.PageLoaded),
})