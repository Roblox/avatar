
local function StringTrim(input, chars, sides)
	if not chars then
		chars = "%s"
	end
	if #chars == 0 then
		return input
	end
	if not sides then
		sides = {
			left = true,
			right = true,
		}
	end
	local trimmed = input
	if sides.left then
		local start = string.find(trimmed, "[^" .. chars .. "]")
		if not start then
			return ""
		end
		trimmed = string.sub(trimmed, start)
	end
	if sides.right then
		local stop = string.find(trimmed, "[" .. chars .. "]+$")
		if not stop then
			return trimmed
		end
		trimmed = string.sub(trimmed, 1, stop-1)
	end
	return trimmed
end

return StringTrim
