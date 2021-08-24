
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

local function buildCostumeInfoFromHumanoidDescription(description)
	
	local assetMap = {}
	
	for assetTypeId, prop in pairs(HumanoidDescriptionIdToName) do
		local assets = string.split(description[prop], ",")
		local filteredAssets = {}
		for _, v in ipairs(assets) do
			if v ~= "0" then
				table.insert(filteredAssets, v)
			end
		end
		if #filteredAssets > 0 then
			assetMap[assetTypeId] = filteredAssets
		end
	end
	
	local info = {
		assets = assetMap,
		bodyColors = {
			headColorId = description.HeadColor,
			torsoColorId = description.TorsoColor,
			rightArmColorId = description.RightArmColor,
			leftArmColorId = description.LeftArmColor,
			rightLegColorId = description.RightLegColor,
			leftLegColorId = description.LeftLegColor,
		},
		scales = {
			height = description.HeightScale,
			width = description.WidthScale,
			head = description.HeadScale,
			depth = description.DepthScale,
			proportion = description.ProportionScale,
			bodyType = description.BodyTypeScale,	
		},
		avatarType = "R15",
	}
	
	return info
end

return buildCostumeInfoFromHumanoidDescription