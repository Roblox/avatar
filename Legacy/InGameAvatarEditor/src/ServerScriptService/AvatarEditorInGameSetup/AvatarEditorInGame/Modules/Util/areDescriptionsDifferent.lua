local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)

local HumanoidDescriptionIdToName = {
	["2"]  = "GraphicTShirt",
	["8"]  = "HatAccessory",
	["41"] = "HairAccessory",
	["42"] = "FaceAccessory",
	["43"] = "NeckAccessory",
	["44"] = "ShouldersAccessory",
	["45"] = "FrontAccessory",
	["46"] = "BackAccessory",
	["47"] = "WaistAccessory",
	["11"] = "Shirt",
	["12"] = "Pants",
	["17"] = "Head",
	["18"] = "Face",
	["27"] = "Torso",
	["28"] = "RightArm",
	["29"] = "LeftArm",
	["30"] = "LeftLeg",
	["31"] = "RightLeg",
	["48"] = "ClimbAnimation",
	["50"] = "FallAnimation",
	["51"] = "IdleAnimation",
	["52"] = "JumpAnimation",
	["53"] = "RunAnimation",
	["54"] = "SwimAnimation",
	["55"] = "WalkAnimation",
}

local HumanoidDescriptionScaleToName = {
	bodyType = "BodyTypeScale",
	head = "HeadScale",
	height = "HeightScale",
	proportion = "ProportionScale",
	depth = "DepthScale",
	width = "WidthScale",
}

local HumanoidDescriptionBodyColorIdToName = {
	headColorId = "HeadColor",
	leftArmColorId = "LeftArmColor",
	leftLegColorId = "LeftLegColor",
	rightArmColorId = "RightArmColor",
	rightLegColorId = "RightLegColor",
	torsoColorId = "TorsoColor",
}

local function getAllIds(equippedEmotes, emotes)
	local ids = {}

	for name, idList in pairs(emotes) do
		local isEquipped = false
		for _, emoteInfo in pairs(equippedEmotes) do
			if emoteInfo.Name == name then
				isEquipped = true
				break
			end
		end

		if isEquipped then
			for _, x in ipairs(idList) do
				ids[x] = true
			end
		end
	end

	return ids
end

local function countMap(map)
	local count = 0

	for _, _ in pairs(map) do
		count = count + 1
	end
	return count
end


local function compareMaps(mapA, mapB)
	for k, v in pairs(mapA) do
		if mapB[k] ~= v then
			print(k, v)
			print(mapB[k])
			return true
		end
	end

	return false
end

local function emotesDifferent(descA, descB)
	local emotesA = descA:GetEmotes()
	local emotesB = descB:GetEmotes()

	local allIdsAMap = getAllIds(descA:GetEquippedEmotes(), emotesA)
	local allIdsBMap = getAllIds(descB:GetEquippedEmotes(), emotesB)

	if countMap(allIdsAMap) ~= countMap(allIdsBMap) then
		return true
	end

	if compareMaps(allIdsAMap, allIdsBMap) then
		return true
	end

	return false
end

local function compareHumanoidDescProps(propA, propB)
	if type(propA) == "string" and type(propB) == "string" then
		local splitA = string.split(propA, ",")
		local splitB = string.split(propB, ",")

		if #splitA ~= #splitB then
			return true
		end

		table.sort(splitA)
		table.sort(splitB)

		for i, _ in ipairs(splitA) do
			if splitA[i] ~= splitB[i] then
				return true
			end
		end

		return false
	end

	return propA ~= propB
end

local function layeredAccessoriesDifferent(descA, descB)
	local accessoriesA = descA:GetAccessories(--[[includeRidgit = ]] false)
	local accessoriesB = descB:GetAccessories(--[[includeRidgit = ]] false)

	if #accessoriesA ~= #accessoriesB then
		return true
	end

	local function toIdList(accessories)
		local idList = {}

		for _, metadata in ipairs(accessories) do
			table.insert(idList, metadata.AssetId)
		end

		return idList
	end

	local idsA = toIdList(accessoriesA)
	local idsB = toIdList(accessoriesB)

	table.sort(idsA)
	table.sort(idsB)

	for i, v in ipairs(idsA) do
		if v ~= idsB[i] then
			return true
		end
	end

	return false
end

local function areDescriptionsDifferent(descA, descB)
	for _, name in pairs(HumanoidDescriptionIdToName) do
		if compareHumanoidDescProps(descA[name], descB[name]) then
			--print("Bad", name, currentHumanoidDescription[name], humanoidDescription[name])
			return true
		end
	end

	for _, name in pairs(HumanoidDescriptionScaleToName) do
		if descA[name] ~= descB[name] then
			--print("Bad", name, currentHumanoidDescription[name], humanoidDescription[name])
			return true
		end
	end

	for _, name in pairs(HumanoidDescriptionBodyColorIdToName) do
		if descA[name] ~= descB[name] then
			--print("Bad", name, currentHumanoidDescription[name], humanoidDescription[name])
			return true
		end
	end

	if emotesDifferent(descA, descB) then
		return true
	end

	if LayeredClothingEnabled then
		if layeredAccessoriesDifferent(descA, descB) then
			return true
		end
	end

	return false
end

return areDescriptionsDifferent
