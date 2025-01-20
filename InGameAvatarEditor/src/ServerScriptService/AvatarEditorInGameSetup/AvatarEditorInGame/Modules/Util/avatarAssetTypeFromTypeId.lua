local function avatarAssetTypeFromTypeId(typeId)
	if type(typeId) == "string" then
		typeId = tonumber(typeId)
	end
	for _, enum in ipairs(Enum.AvatarAssetType:GetEnumItems()) do
		if enum.Value == typeId then
			return enum
		end
	end
	error("Unknown typeId" .. tostring(typeId))
end

return avatarAssetTypeFromTypeId