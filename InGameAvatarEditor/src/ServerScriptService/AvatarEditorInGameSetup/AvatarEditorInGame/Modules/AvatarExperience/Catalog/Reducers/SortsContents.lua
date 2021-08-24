local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local CatalogAppendSortData = require(Modules.AvatarExperience.Catalog.Actions.CatalogAppendSortData)
local CatalogDataReceived = require(Modules.AvatarExperience.Catalog.Actions.CatalogDataReceived)
local SetCatalogSortDataStatus = require(Modules.AvatarExperience.Catalog.Actions.SetCatalogSortDataStatus)

local default = {
    DataStatus = {}
}

return Rodux.createReducer(default, {
    [CatalogDataReceived.name] = function(state, action)
        local currentCategoryTable = state[action.categoryIndex] or {}
        local entriesTable = {}
        for _, itemData in pairs(action.sortResults.items) do
            table.insert(entriesTable, itemData)
        end
        return Cryo.Dictionary.join(state, {
            [action.categoryIndex] = Cryo.Dictionary.join(currentCategoryTable, {
                [action.subcategoryIndex] = {
                    entries = entriesTable,
                    nextPageCursor = action.sortResults.nextPageCursor,
                    hasMoreRows = action.sortResults.nextPageCursor ~= nil,
                },
            }),
        })
    end,

    [CatalogAppendSortData.name] = function(state, action)
        local currentCategoryTable = state[action.categoryIndex] or {}
        local currentSubcategoryTable = currentCategoryTable[action.subcategoryIndex] or {}

        local entriesTable = currentSubcategoryTable.entries or {}
        local moreEntriesTable = {}
        for _, itemData in pairs(action.sortResults.items) do
            table.insert(moreEntriesTable, itemData)
        end
        entriesTable = Cryo.List.join(entriesTable, moreEntriesTable)

        return Cryo.Dictionary.join(state, {
            [action.categoryIndex] = Cryo.Dictionary.join(currentCategoryTable, {
                [action.subcategoryIndex] = {
                    entries = entriesTable,
                    nextPageCursor = action.sortResults.nextPageCursor,
                    hasMoreRows = action.sortResults.nextPageCursor ~= nil,
                },
            }),
        })
    end,

    [SetCatalogSortDataStatus.name] = function(state, action)
        local currentSubTable = state.DataStatus[action.categoryIndex] or {}

        return Cryo.Dictionary.join(state, {
            DataStatus = Cryo.Dictionary.join(state.DataStatus, {
                [action.categoryIndex] = Cryo.Dictionary.join(currentSubTable, {
                    [action.subcategoryIndex] = action.status,
                }),
            }),
        })
    end,
})