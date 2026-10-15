--[[
	MakeupRegionMasks
	Loads the authored cage-space allow masks for decal makeup regions.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local MakeupRegionMasks = {}

local REGION_ASSET_IDS: { [string]: string } = {
	[Constants.MAKEUP_ASSET_TYPES.Face] = "rbxassetid://127838549635683",
	[Constants.MAKEUP_ASSET_TYPES.Eyes] = "rbxassetid://93404713470721",
	[Constants.MAKEUP_ASSET_TYPES.Lips] = "rbxassetid://114194999975463",
}

-- Loads the decal-region masks at native PNG size.
function MakeupRegionMasks.Load(): { [string]: EditableImage }
	local result = {}
	for _, key in Constants.MAKEUP_DECAL_ASSET_TYPES do
		if not REGION_ASSET_IDS[key] then
			warn("MakeupRegionMasks: missing asset ID for " .. key)
			continue
		end
		local image = AssetService:CreateEditableImageAsync(Content.fromUri(REGION_ASSET_IDS[key]))
		assert(image, "MakeupRegionMasks: failed to load " .. key .. " mask")
		result[key] = image
	end
	return result
end

return MakeupRegionMasks
