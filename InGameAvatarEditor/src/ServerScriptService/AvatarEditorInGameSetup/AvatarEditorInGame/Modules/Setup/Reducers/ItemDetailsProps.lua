local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local InGameSetup = script.Parent.Parent
local SetItemDetailsProps = require(InGameSetup.Actions.SetItemDetailsProps)

local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)

return function(state, action)
	state = state or {
		itemId = nil,
		itemType = nil,
	}

	if action.type == SetItemDetailsProps.name then
		return {
			itemId = action.itemId,
			itemType = action.itemType,
		}
	end

	return state
end