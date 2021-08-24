return function(str, replacements)
	if type(str) ~= "string" then
		return ""
	end

	if type(replacements) ~= "table" then
		return str
	end

	local result = str
	for piiStr, replaceStr in pairs(replacements) do
		if type(piiStr) == "string" and type(replaceStr) == "string" then
			result = string.gsub(result, piiStr, replaceStr)
		end
	end

	return result
end