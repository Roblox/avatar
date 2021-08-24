
local CorePackages = game:GetService("CorePackages")
local ArgCheck = require(CorePackages.ArgCheck)

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local StringSplit = require(Modules.Common.StringUtilities.StringSplit)

local function urlDecode(input)
	ArgCheck.isType(input, "string", "input")
	local decoded = string.gsub(input, '%%(%x%x)', function(charCode)
		return string.char(tonumber(charCode, 16))
	end)
	decoded = string.gsub(decoded, "+", " ")
	return decoded;
end

--[[
	Parses a query string into a lua table.
	* supports both "&"" and ";" as separator (and "=" separates names/values)
	* empty names or values are returned as "" (eg "k1=&=v2&k3")
		* completely empty pairs are ignored (eg "k1=v1&&k3=v3")
	* url decodes all names and values
	* supports multiple values
		* by default, all values are returned in tables
		* if listKeyMapper (name => listKey) is provided:
			* only the last value for a name is returned as that key (ie name)
			* the list of values is returned at the key provided by listKeyMapper
			* listKeyMapper can return the same input key (ie name), or nil (same effect)
]]
local function ParseQuery(input, listKeyMapper)
	ArgCheck.isTypeOrNil(input, "string", "input")
	ArgCheck.isTypeOrNil(listKeyMapper, "function", "listKeyMapper")
	local useListKeys = type(listKeyMapper) == "function"
	local parsed = {}
	if input and #input > 0 then
		local items = StringSplit(input, "[&;]")
		for _, item in ipairs(items) do
			if item and #item > 0 then
				local key, value = unpack(string.split(item, "="))
				if value == nil then
					value = ""
				end
				key = urlDecode(key)
				value = urlDecode(value)
				if useListKeys then
					if parsed[key] ~= nil then
						local listKey = listKeyMapper(key)
						if listKey == nil then
							listKey = key
						end
						if type(parsed[listKey]) ~= "table" then
							parsed[listKey] = { parsed[key] }
						end
						table.insert(parsed[listKey], value)
						if key ~= listKey then
							parsed[key] = value
						end
					else
						parsed[key] = value
					end
				else
					if parsed[key] == nil then
						parsed[key] = {}
					end
					table.insert(parsed[key], value)
				end
			end
		end
	end
	return parsed
end

return ParseQuery
