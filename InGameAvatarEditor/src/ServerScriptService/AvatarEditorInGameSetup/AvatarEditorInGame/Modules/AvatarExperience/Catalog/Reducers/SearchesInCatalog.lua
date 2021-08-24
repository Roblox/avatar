local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Cryo = require(Modules.Packages.Cryo)
local Rodux = require(Modules.Packages.Rodux)

local AppendSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.AppendSearchInCatalog)
local RemoveSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.RemoveSearchInCatalog)
local SetSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.SetSearchInCatalog)

return Rodux.createReducer({}, {
    [AppendSearchInCatalog.name] = function(state, action)
        local existingData = state[action.searchUuid]
        if not existingData then
            return Cryo.Dictionary.join(state, {
                [action.searchUuid] = action.searchInCatalog,
            })
        end

        local currentItems = existingData.items
        local newItems = Cryo.List.join(currentItems, action.searchInCatalog.items)
        action.searchInCatalog.items = newItems

        return Cryo.Dictionary.join(state, {
            [action.searchUuid] = action.searchInCatalog,
        })
    end,

    [RemoveSearchInCatalog.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            [action.searchUuid] = Cryo.None,
        })
    end,

    [SetSearchInCatalog.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            [action.searchUuid] = action.searchInCatalog,
        })
    end,
})