local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules


local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetSearchType = require(Modules.NotLApp.Actions.SetSearchType)

return Rodux.createReducer({}, {
    [SetSearchType.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            [action.searchUuid] = action.searchType,
        })
    end,
})