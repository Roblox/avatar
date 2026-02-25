local BodyColorManager = {}
BodyColorManager.__index = BodyColorManager

local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Constants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)

local GetFFlagLuaAppEnableAERedesign = function() return true end

local function getMinBodyColorDifference(state)
	local avatarSettings

	if GetFFlagLuaAppEnableAERedesign() then
		avatarSettings = state.AvatarExperience.AvatarEditor.AvatarSettings
	else
		avatarSettings = state.AEAppReducer.AEAvatarSettings
	end

	return avatarSettings[AvatarEditorConstants.AvatarSettings.minDeltaBodyColorDifference]
end

local function getBodyColors(state)
	if GetFFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.BodyColors
	else
		return state.AEAppReducer.AECharacter.AEBodyColors
	end
end

local function getEquippedAssets(state)
	if GetFFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.EquippedAssets
	else
		return state.AEAppReducer.AECharacter.AEEquippedAssets
	end
end

function BodyColorManager.new(store, characterManager)
	local self = {}
	self.store = store
	self.characterManager = characterManager

	setmetatable(self, BodyColorManager)

	local userId = store:getState().LocalUserId

	local defaultClothingIds
	if GetFFlagLuaAppEnableAERedesign() then
		defaultClothingIds = store:getState().AvatarExperience.AvatarEditor.DefaultClothingIds
	else
		defaultClothingIds = store:getState().AEAppReducer.AEDefaultClothingIds
	end

	local defaultClothesIndex = tonumber(userId) % #defaultClothingIds.defaultShirtAssetIds + 1
	self.defaultShirtId = defaultClothingIds.defaultShirtAssetIds[defaultClothesIndex]
	self.defaultPantsId = defaultClothingIds.defaultPantAssetIds[defaultClothesIndex]

	self.wearingDefaultShirt = false
	self.wearingDefaultPants = false
	self.checkBodyColors = true
	self.bodyColorsTooSimilar = false

	return self
end

function BodyColorManager:start()
	self:manageDefaultClothing(getEquippedAssets(self.store:getState()))
end

function BodyColorManager:checkBodyColorsForDefaultClothes()
	if not self.checkBodyColors then
		return self.bodyColorsTooSimilar
	end

	local minDeltaEDifference = getMinBodyColorDifference(self.store:getState())

	local rightLegColor = Color3.new(0, 0, 0)
	local leftLegColor = Color3.new(0, 0, 0)
	local torsoColor = Color3.new(0, 0, 0)
	local bodyColors = getBodyColors(self.store:getState())

	for index, value in pairs(bodyColors) do
		if index == "rightLegColorId" then
			rightLegColor = BrickColor.new(value).Color
		elseif index == "leftLegColorId" then
			leftLegColor = BrickColor.new(value).Color
		elseif index == "torsoColorId" then
			torsoColor = BrickColor.new(value).Color
		end
	end

	local minDeltaE = math.min(
		AvatarEditorUtils.delta_CIEDE2000(rightLegColor, torsoColor),
		AvatarEditorUtils.delta_CIEDE2000(leftLegColor, torsoColor))

	self.checkBodyColors = false
	self.bodyColorsTooSimilar = minDeltaE <= minDeltaEDifference
	return self.bodyColorsTooSimilar
end

function BodyColorManager:manageDefaultClothing(curEquipped, checkBodyColors)
	if checkBodyColors then
		self.checkBodyColors = true
	end

	local wearingShirt = (curEquipped[Constants.AssetTypes.Shirt]
		and #curEquipped[Constants.AssetTypes.Shirt] > 0) and true or false
	local wearingPants = (curEquipped[Constants.AssetTypes.Pants]
		and #curEquipped[Constants.AssetTypes.Pants] > 0) and true or false
	local bodyColorsTooSimilar = self:checkBodyColorsForDefaultClothes()
	local shirtId = nil
	local pantsId = nil

	if not self.wearingDefaultShirt and (not wearingShirt and not wearingPants) and bodyColorsTooSimilar then
		self.wearingDefaultShirt = true
		shirtId = self.defaultShirtId
	elseif self.wearingDefaultShirt and ((wearingShirt or wearingPants) or not bodyColorsTooSimilar) then
		self.wearingDefaultShirt = false
	end
	if not self.wearingDefaultPants and not wearingPants and bodyColorsTooSimilar then
		self.wearingDefaultPants = true
		pantsId = self.defaultPantsId
	elseif self.wearingDefaultPants and (wearingPants or not bodyColorsTooSimilar) then
		self.wearingDefaultPants = false
	end

	if self.wearingDefaultShirt then
		shirtId = self.defaultShirtId
	end

	if self.wearingDefaultPants then
		pantsId = self.defaultPantsId
	end

	self.characterManager:manageDefaultClothing(shirtId, pantsId)
end

function BodyColorManager:stop()
end

function BodyColorManager:onDestroy()
end

return BodyColorManager