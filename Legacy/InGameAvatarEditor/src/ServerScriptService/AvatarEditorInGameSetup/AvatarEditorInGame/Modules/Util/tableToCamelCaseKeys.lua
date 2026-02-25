--[[
	The web endpoints return information in a camelCase format, however the convention for game engine APIs is to return
	infomration in a PascalCase format. To avoid needing to change all our code to access data returned as PascalCase
	we use this helper function to convert it back to camelCase
]]

local function tableToCamelCaseKeys(oldTable)
	local newTable = {}
	for k, v in pairs(oldTable) do
		local newKey = k
		if typeof(k) == "string" then
			newKey = string.lower(string.sub(k, 1, 1)) .. string.sub(k, 2)
		end
		local newValue = v
		if typeof(v) == "table" then
			newValue = tableToCamelCaseKeys(v)
		end
		newTable[newKey] = newValue
	end
	return newTable
end

return tableToCamelCaseKeys