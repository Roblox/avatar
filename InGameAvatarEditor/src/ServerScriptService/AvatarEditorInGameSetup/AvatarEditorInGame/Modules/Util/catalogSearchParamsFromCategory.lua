
local function isMemeberOfEnum(enumItem, enum)
	for _, testEnumItem in ipairs(enum:GetEnumItems()) do
		if enumItem == testEnumItem then
			return true
		end
	end
	return false
end

local function catalogSearchParamsFromCategory(category, extraAssetTypes, extraBundleTypes)
	local searchParams = CatalogSearchParams.new()

	local testValue = category
	if type(testValue) == "table" then
		testValue = testValue[1]
	end
	
	local tableValue = category
	if typeof(tableValue)~= "table" then
		tableValue = {category}		
	end
	
	if isMemeberOfEnum(testValue, Enum.CatalogCategoryFilter) then
		searchParams.CategoryFilter = testValue
	elseif isMemeberOfEnum(testValue, Enum.AvatarAssetType) then
		searchParams.AssetTypes = tableValue
	elseif isMemeberOfEnum(testValue, Enum.BundleType) then
		searchParams.BundleTypes = tableValue
	end
	
	if extraAssetTypes then
		searchParams.AssetTypes = extraAssetTypes
	end
	
	if extraBundleTypes then
		searchParams.BundleTypes = extraBundleTypes
	end
	
	return searchParams
end

return catalogSearchParamsFromCategory