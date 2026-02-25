--[[
	Model for an Outfit (e.g. Hat).
	{
		outfitId = number
		assets = {}
		bodyColors = {}
	}
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local MockId = require(Modules.NotLApp.MockId)
local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)

local AEOutfitInfo = {}

function AEOutfitInfo.new()
	local self = {}

	return self
end

function AEOutfitInfo.mock()
	local self = AEOutfitInfo.new()
	local MEDIUM_STONE_GREY = 194

	self.outfitId = MockId()
	self.name = ""
	self.assets = {}
	self.bodyColors = {
		HeadColor = MEDIUM_STONE_GREY,
		LeftArmColor = MEDIUM_STONE_GREY,
		LeftLegColor = MEDIUM_STONE_GREY,
		RightArmColor = MEDIUM_STONE_GREY,
		RightLegColor = MEDIUM_STONE_GREY,
		TorsoColor = MEDIUM_STONE_GREY,
	}

	self.scales = {
		height = 0,
		width = 0,
		head = 0,
		depth = 0,
		proportion = 0,
		bodyType = 0,
	}

	self.avatarType = Constants.AvatarType.R15

	self.isEditable = true

	return self
end

function AEOutfitInfo.fromWebApi(outfitId, name, assets, bodyColors, scales, avatarType, isEditable)
	local self = AEOutfitInfo.new()

	self.outfitId = outfitId
	self.name = name
	self.assets = assets
	self.bodyColors = bodyColors
	self.scales = scales
	self.avatarType = avatarType
	self.isEditable = isEditable

	return self
end

return AEOutfitInfo