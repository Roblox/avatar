local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local Reducers = script.Parent

return Rodux.combineReducers({
    AvailableToSellAssets = require(Reducers.AvailableToSellAssets),
    CurrentlySellingAssets = require(Reducers.CurrentlySellingAssets),
})
