local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetSearchInCatalogStatus = require(Modules.AvatarExperience.Catalog.Actions.SetSearchInCatalogStatus)

return Rodux.createReducer({}, {
    [SetSearchInCatalogStatus.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            [action.searchUuid] = action.status,
        })
    end,
})