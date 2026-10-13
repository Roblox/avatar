--[[
	Horizontal tile with thumbnail, name, and icon buttons on the right. Used
	for layers in the layer editor.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local TwoStateIconButton = require(Components:WaitForChild("TwoStateIconButton"))

local LayerTile = {}
LayerTile.__index = LayerTile

type LayerTileButtonInfo = {
	iconId: string,
	inactiveIconId: string?,
	isActive: boolean?,
	callback: (button: TextButton, isActive: boolean?) -> (),
}

local function createInfoFrame(thumbnailContent: Content?, name: string)
	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "InfoFrame"

	local thumbnail, thumbnailIcon = BaseTile.createComponentFrame(thumbnailContent, nil)
	thumbnail.Name = "Thumbnail"
	thumbnail.Parent = infoFrame
	thumbnail.LayoutOrder = 1
	StyleUtils.AddStyleTag(thumbnail, StyleConsts.tags.LayerTileThumbnail)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Text = name
	nameLabel.Parent = infoFrame
	nameLabel.LayoutOrder = 2

	return infoFrame, thumbnailIcon
end

local function createButtonsFrame(buttonInfos: { LayerTileButtonInfo })
	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Name = "ButtonsFrame"

	for i, buttonInfo in buttonInfos do
		local twoStateButton
		twoStateButton = TwoStateIconButton.new(
			buttonInfo.iconId,
			buttonInfo.inactiveIconId or buttonInfo.iconId,
			function(isActive)
				local newIsActive
				if buttonInfo.inactiveIconId then
					newIsActive = not isActive
				end
				buttonInfo.callback(twoStateButton:GetFrame(), newIsActive)
				if newIsActive ~= nil then
					twoStateButton:SetActive(newIsActive)
				end
			end
		)
		if buttonInfo.inactiveIconId then
			twoStateButton:SetActive(buttonInfo.isActive)
		end
		local button = twoStateButton:GetFrame()
		button.LayoutOrder = i
		button.Parent = buttonsFrame
		StyleUtils.AddStyleTag(button, StyleConsts.tags.LayerTileButton)
	end

	return buttonsFrame
end

function LayerTile.new(thumbnailContent: Content?, name: string, buttonInfos: { LayerTileButtonInfo })
	local self = setmetatable({}, LayerTile)

	local frame = Instance.new("Frame")
	frame.Name = "LayerTile"
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.LayerTile)

	local infoFrame, thumbnailIcon = createInfoFrame(thumbnailContent, name)
	infoFrame.Parent = frame
	infoFrame.LayoutOrder = 1

	local buttonsFrame = createButtonsFrame(buttonInfos)
	buttonsFrame.Parent = frame
	buttonsFrame.LayoutOrder = 2

	self.frame = frame
	self.thumbnailIcon = thumbnailIcon

	return self
end

function LayerTile:GetFrame(): Frame
	return self.frame
end

function LayerTile:SetThumbnail(content: Content?)
	if self.thumbnailIcon and content then
		self.thumbnailIcon.ImageContent = content
	end
end

export type LayerTile = typeof(LayerTile.new(nil, "", {}))

return LayerTile
