local utils = script.Parent
local avatarAssetTypeFromTypeId = require(utils.avatarAssetTypeFromTypeId)

function avatarAssetTypesFromAssetTypes(assetTypes)
	local newTypes = {}
	for _, assetTypeId in ipairs(assetTypes) do
		local avatarAssetTypeEnum = avatarAssetTypeFromTypeId(assetTypeId)
		table.insert(newTypes, avatarAssetTypeEnum)
	end

	return newTypes
end

return avatarAssetTypesFromAssetTypes
