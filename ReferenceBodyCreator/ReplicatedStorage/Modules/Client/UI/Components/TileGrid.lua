--[[
	Creates a grid of interactive BaseTiles. Used for sticker and kitbashing UIs.
	Takes in a list of IconButtonInfos, and adds them to a grid based on the
	order of the list.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))

local TileGrid = {}

type TileInfo = {
	iconId: string?,
	previewInstance: (Model | BasePart)?,
	viewportOptions: BaseTile.ViewportOptions?,
	insetButton: GuiButton?,
	callback: () -> (),
}

function TileGrid.createComponentFrame(gridButtonInfos: { TileInfo })
	local frame = Instance.new("Frame")
	frame.Name = "TileGridFrame"
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.TileGrid)

	for i, info in gridButtonInfos do
		local tile = if info.previewInstance
			then BaseTile.createViewportComponentFrame(info.previewInstance, info.callback, info.viewportOptions)
			else BaseTile.createComponentFrame(info.iconId, info.callback)
		tile.Parent = frame
		tile.LayoutOrder = i
		if info.insetButton then
			StyleUtils.AddStyleTag(info.insetButton, StyleConsts.tags.BaseTileInsetButton)
			info.insetButton.Parent = tile
		end
	end

	return frame
end

return TileGrid
