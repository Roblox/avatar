--[[
	A group of mini base tiles, used for showing stickers/add-ons applied and
	selecting different layers/pieces. One tile can be selected at a time.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local IconButton = require(Components:WaitForChild("IconButton"))

local MiniBaseTileGroup = {}
MiniBaseTileGroup.__index = MiniBaseTileGroup

export type BaseTileInfo = {
	imageAssetId: string,
	callback: () -> (),
}

function MiniBaseTileGroup.new(baseTiles: { BaseTileInfo })
	local self = {}
	setmetatable(self, MiniBaseTileGroup)

	self.frame = Instance.new("Frame")
	self.frame.Name = "MiniBaseTileGroup"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.MiniBaseTileGroup)

	self.tileFrameInfos = {
		--[[
		{
			frame: Instance,
			hasButton: boolean,
			callback: () -> (),
		},
		]]
	}

	for i, baseTileInfo in baseTiles do
		local baseTile = BaseTile.createComponentFrame(baseTileInfo.imageAssetId, baseTileInfo.callback)
		baseTile.Parent = self.frame
		baseTile.LayoutOrder = i
		StyleUtils.AddStyleTag(baseTile, StyleConsts.tags.MiniBaseTile)
		local wrappedCallback = function()
			baseTileInfo.callback()
			self:UpdateSelection(i)
		end
		table.insert(self.tileFrameInfos, { frame = baseTile, hasButton = false, callback = wrappedCallback })
	end

	return self
end

export type AppliedItemDetails = {
	textureId: string,
}

function MiniBaseTileGroup:UpdateSelection(currentlySelectedIndex: number)
	for i, baseTile in self.tileFrameInfos do
		if i == currentlySelectedIndex then
			StyleUtils.AddStyleTag(baseTile.frame, StyleConsts.tags.MiniBaseTileSelected)
		else
			StyleUtils.RemoveStyleTag(baseTile.frame, StyleConsts.tags.MiniBaseTileSelected)
		end
	end
end

function MiniBaseTileGroup:UpdateTiles(appliedItems: { AppliedItemDetails }, currentlySelectedIndex: number)
	for i, baseTile in self.tileFrameInfos do
		if appliedItems[i] then
			local itemData = appliedItems[i]
			local imageAssetId = itemData.textureId

			if baseTile.hasButton then
				-- Change the image if needed
				local button = baseTile.frame:FindFirstChildWhichIsA("TextButton")
				if button then
					local icon = button:FindFirstChildWhichIsA("ImageLabel")
					if not icon then
						warn("MiniBaseTileGroup:UpdateTiles - missing ImageLabel in IconButton")
						continue
					end

					if icon.Image ~= imageAssetId then
						icon.Image = imageAssetId
					end
				end
			else
				-- Add button with image
				baseTile.hasButton = true

				local button = IconButton.createComponentFrame(imageAssetId, baseTile.callback)
				button.Parent = baseTile.frame
				StyleUtils.AddStyleTag(button, StyleConsts.tags.BaseTileButton)
			end
		else
			-- No sticker applied to this tile
			if baseTile.hasButton then
				-- Remove button
				local button = baseTile.frame:FindFirstChildWhichIsA("TextButton")
				if button then
					button:Destroy()
				end
				baseTile.hasButton = false
			end
		end
	end
	-- Update selection state
	self:UpdateSelection(currentlySelectedIndex)
end

return MiniBaseTileGroup
