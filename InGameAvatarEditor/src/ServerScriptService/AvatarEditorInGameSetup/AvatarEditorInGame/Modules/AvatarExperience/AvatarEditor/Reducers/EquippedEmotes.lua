local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Cryo = require(Modules.Packages.Cryo)
local Rodux = require(Modules.Packages.Rodux)

local Constants = require(Modules.AvatarExperience.Common.Constants)

local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)
local SetSelectedEmoteSlot = require(Modules.AvatarExperience.AvatarEditor.Actions.SetSelectedEmoteSlot)
local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleEquipAsset)

local default = {
	slotInfo = {},

	selectedSlot = 1,
}

local function createSlotInfo(emotesData)
	local slotInfo = {}

	for _, emoteInfo in ipairs(emotesData) do
		local slotNumber = emoteInfo.position
		local assetId = tostring(emoteInfo.assetId)

		slotInfo[slotNumber] = {
			assetId = assetId,
			position = slotNumber,
		}
	end

	return slotInfo
end

local function addEmoteToSlot(slotInfo, position, emoteInfo)
	return Cryo.Dictionary.join(slotInfo, {
		[position] = emoteInfo,
	})
end

local function removeEmoteFromSlot(slotInfo, position)
	return Cryo.Dictionary.join(slotInfo, {
		[position] = Cryo.None,
	})
end

return Rodux.createReducer(default, {
	[ReceivedAvatarData.name] = function(state, action)
		local emotesData = action.avatarData.emotes
		emotesData = emotesData or {}

		local slotInfo = createSlotInfo(emotesData)

		return Cryo.Dictionary.join(state, {
			slotInfo = slotInfo,
		})
	end,

	[ToggleEquipAsset.name] = function(state, action)
		if action.assetType ~= Constants.AssetTypes.Emote then
			return state
		end

		local oldEmoteInfo = state.slotInfo[state.selectedSlot]

		local emoteInfo = {
			assetId = action.assetId,
			position = state.selectedSlot,
		}

		local newSlotInfo
		if not oldEmoteInfo or oldEmoteInfo.assetId ~= emoteInfo.assetId then
			newSlotInfo = addEmoteToSlot(state.slotInfo, state.selectedSlot, emoteInfo)
		else
			newSlotInfo = removeEmoteFromSlot(state.slotInfo, state.selectedSlot)
		end

		return Cryo.Dictionary.join(state, {
			slotInfo = newSlotInfo,
		})
	end,

	[SetSelectedEmoteSlot.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			selectedSlot = action.selectedSlot,
		})
	end,
})