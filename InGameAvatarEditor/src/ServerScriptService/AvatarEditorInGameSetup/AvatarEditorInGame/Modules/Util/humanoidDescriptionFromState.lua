local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local HumanoidDescriptionIdToName = AvatarExperienceConstants.HumanoidDescriptionIdToName
local HumanoidDescriptionScaleToName = AvatarExperienceConstants.HumanoidDescriptionScaleToName
local HumanoidDescriptionBodyColorIdToName = AvatarExperienceConstants.HumanoidDescriptionBodyColorIdToName
local AssetTypeIdToAccessoryTypeEnum = AvatarExperienceConstants.AssetTypeIdToAccessoryTypeEnum
local LayeredClothingOrder = AvatarExperienceConstants.LayeredClothingOrder

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)

local function addAccessories(state, humanoidDescription, includeTryOn)
	local equippedAssets = state.AvatarExperience.AvatarEditor.Character.EquippedAssets
	if not equippedAssets then
		warn("CharacterManager: Equipped assets has not been initialized!")
		return
	end

	for _, humanoidDescriptionProperty in pairs(HumanoidDescriptionIdToName) do
		humanoidDescription[humanoidDescriptionProperty] = ""
	end

	local lcAccessories = {}
	for assetType, assets in pairs(equippedAssets) do
		if not assets[1] then
			continue
		end

		local propertyName = HumanoidDescriptionIdToName[assetType]
		if propertyName and assetType ~= AvatarExperienceConstants.AssetTypes.Gear then
			humanoidDescription[propertyName] = table.concat(assets, ",")
		else
			local accessoryType = AssetTypeIdToAccessoryTypeEnum[assetType]
			if accessoryType then
				local order = LayeredClothingOrder[assetType]
				lcAccessories[#lcAccessories + 1] = {AssetId = tonumber(assets[1]), Order = order, AccessoryType = accessoryType, IsLayered = true}
			end
		end
	end

	if not includeTryOn then
		if LayeredClothingEnabled then
			humanoidDescription:SetAccessories(lcAccessories, --[[includeRigidAccessories = ]] false)
		end
		return
	end

	-- Try on items take priority over equipped items.
	local tryOnItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

	if tryOnItem.itemType == CatalogConstants.ItemType.Asset then
		local assetId = tryOnItem.itemId
		local assetTypeId = tryOnItem.itemSubType

		if assetId and assetTypeId ~= AvatarExperienceConstants.AssetTypes.Gear then
			local humanoidDescriptionProp = HumanoidDescriptionIdToName[assetTypeId]
			if humanoidDescriptionProp then
				humanoidDescription[humanoidDescriptionProp] = assetId
			else
				local accessoryType = AssetTypeIdToAccessoryTypeEnum[assetTypeId]
				if accessoryType then
					local order = LayeredClothingOrder[assetTypeId]
					lcAccessories[#lcAccessories + 1] = {AssetId = tonumber(assetId), Order = order, AccessoryType = accessoryType, IsLayered = true}
				end
			end
		end
	end

	if LayeredClothingEnabled then
		humanoidDescription:SetAccessories(lcAccessories, --[[includeRigidAccessories = ]] false)
	end
end

local function addScales(state, humanoidDescription)
	local scales = state.AvatarExperience.AvatarEditor.Character.AvatarScales
	for scale, percentage in pairs(scales) do
		humanoidDescription[HumanoidDescriptionScaleToName[scale]] = percentage
	end
end

local function addBodyColors(state, humanoidDescription)
	local bodyColors = state.AvatarExperience.AvatarEditor.Character.BodyColors
	for id, bodyColor in pairs(bodyColors) do
		humanoidDescription[HumanoidDescriptionBodyColorIdToName[id]] = BrickColor.new(bodyColor).Color
	end
end

local function addEmotes(state, humanoidDescription)
	local slotInfo = state.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo

	local emotes = {}
	local equipedEmotes = {}

	for key, emoteInfo in pairs(slotInfo) do
		local emoteName = "Emote" .. key
		emotes[emoteName] = {tonumber(emoteInfo.assetId)}
		table.insert(equipedEmotes, {
			Slot = emoteInfo.position,
			Name = emoteName,
		})
	end

	humanoidDescription:SetEmotes(emotes)
	humanoidDescription:SetEquippedEmotes(equipedEmotes)
end

local function humanoidDescriptionFromState(state, includeTryOn)
	local humanoidDescription = Instance.new("HumanoidDescription")
	addEmotes(state, humanoidDescription)
	addBodyColors(state, humanoidDescription)
	addScales(state, humanoidDescription)
	addAccessories(state, humanoidDescription, includeTryOn)

	return humanoidDescription
end

return humanoidDescriptionFromState