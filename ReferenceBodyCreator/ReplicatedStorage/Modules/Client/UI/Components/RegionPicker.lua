--[[
	Creates a horizontal pillbar containing icons for the region parts, ordered
	according to StyleConsts. The whole model is selected by default. Used by
	fill and sticker tool UIs.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))

local Components = UI:WaitForChild("Components")
local HorizontalPillbar = require(Components:WaitForChild("HorizontalPillbar"))

local RegionPicker = {}

function RegionPicker.createComponentFrame(regionParts, onRegionSelectedCallback)
	-- Create button infos from region names
	local buttonInfos = {}

	-- Sort for correct order
	table.sort(regionParts, function(a, b)
		return StyleConsts.regionOrdering[a] < StyleConsts.regionOrdering[b]
	end)

	for _, partName in regionParts do
		table.insert(buttonInfos, {
			iconId = StyleConsts.regionIcons[partName],
			callback = function()
				onRegionSelectedCallback(partName)
			end,
		})
	end

	-- Create and return horizontal pillbar
	local regionPillbar = HorizontalPillbar.createComponentFrame(buttonInfos)

	return regionPillbar
end

return RegionPicker
