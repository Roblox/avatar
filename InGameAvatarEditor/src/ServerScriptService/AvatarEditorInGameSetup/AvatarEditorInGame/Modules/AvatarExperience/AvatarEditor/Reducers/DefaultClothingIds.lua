local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local SetDefaultClothingIds = require(Modules.AvatarExperience.AvatarEditor.Actions.SetDefaultClothingIds)

--[[
		These default ids are various colors that sync up with chat username color order.
		Username color list: "Bright red", "Bright blue", "Earth green", "Bright violet",
		"Bright orange", "Bright yellow", "Light reddish violet", "Brick yellow"
]]
local initialState = {
    defaultShirtAssetIds = {
        "855776103",
        "855760101",
        "855766176",
        "855777286",
        "855768342",
        "855779323",
        "855773575",
        "855778084"
    },
    defaultPantAssetIds = {
        "855783877",
        "855780360",
        "855781078",
        "855782781",
        "855781508",
        "855785499",
        "855782253",
        "855784936"
    }
}

return Rodux.createReducer(initialState, {
    [SetDefaultClothingIds.name] = function(state, action)
        return {
			defaultShirtAssetIds = action.defaultClothingIds.defaultShirtAssetIds,
			defaultPantAssetIds = action.defaultClothingIds.defaultPantAssetIds,
		}
	end,
})