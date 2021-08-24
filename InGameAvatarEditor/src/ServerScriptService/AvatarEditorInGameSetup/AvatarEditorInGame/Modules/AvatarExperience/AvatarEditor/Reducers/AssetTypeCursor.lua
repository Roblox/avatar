local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetAssetTypeCursor = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetTypeCursor)

return Rodux.createReducer({}, {
    [SetAssetTypeCursor.name] = function(state, action)
        return Cryo.Dictionary.join(state, {[action.assetTypeId] = action.nextCursor})
    end,
})