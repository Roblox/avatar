local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local SetSelectedItem = require(Modules.AvatarExperience.Common.Actions.SetSelectedItem)

local ClearAnimationPreview = require(Modules.AvatarExperience.Common.Actions.ClearAnimationPreview)
local SetAnimationPreview = require(Modules.AvatarExperience.Common.Actions.SetAnimationPreview)

local default = {
    AnimationPreview = nil,
    SelectedItem = {},
}

return Rodux.createReducer(default, {
    [ClearSelectedItem.name] = function(state, action)
        if state.SelectedItem.itemId == nil then
            return state
        end

        return Cryo.Dictionary.join(state, {
            SelectedItem = {},
        })
    end,

    [SetSelectedItem.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            SelectedItem = {
                itemId = action.itemId,
                itemType = action.itemType,
                itemSubType = action.itemSubType,
            }
        })
    end,

    [ClearAnimationPreview.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            AnimationPreview = Cryo.None,
        })
    end,

    [SetAnimationPreview.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            AnimationPreview = action.assetId,
        })
    end,
})