--[[
	Horizontally scrolling brush picker. Selecting a tile adds a highlight and activates the callback.
	Nothing is initially selected, immediately call UpdateSelection to set a "default"
]]

local TweenService = game:GetService("TweenService")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local IconButton = require(Components:WaitForChild("IconButton"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

-- Fraction of the visible width scrolled per arrow click
local SCROLL_PAGE_FRACTION = 0.7
-- Pixel tolerance when deciding whether we've reached an end of the scroll range
local SCROLL_END_EPSILON = 1
-- Slide animation played when scrolling via the arrows
local SCROLL_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local BrushPicker = {}
BrushPicker.__index = BrushPicker

export type BrushCardInfo = {
	previewImageId: string, -- Card image
	name: string, -- Tile caption
	callback: () -> (), -- Called on click
	tinted: boolean?,
}

function BrushPicker:AddBrushTile(index: number, brushInfo: BrushCardInfo)
	local tile = Instance.new("Frame")
	tile.Name = "BrushPickerTile"
	tile.LayoutOrder = index
	StyleUtils.AddStyleTag(tile, StyleConsts.tags.BrushPickerTile)

	local onActivated = function()
		brushInfo.callback()
		self:UpdateSelection(index)
	end

	local thumbnail, icon = BaseTile.createComponentFrame(brushInfo.previewImageId, onActivated)
	thumbnail.Name = "BrushPickerThumbnail"
	thumbnail.LayoutOrder = 1
	-- BaseTile forces a square (1:1) aspect; the BrushPickerThumbnail tag drives a
	-- high-priority style rule that overrides it back to the 68x46 thumbnail aspect.
	StyleUtils.AddStyleTag(thumbnail, StyleConsts.tags.BrushPickerThumbnail)
	thumbnail.Parent = tile

	local selectionOutline = Instance.new("Frame")
	selectionOutline.Name = "BrushPickerSelectionOutline"
	StyleUtils.AddStyleTag(selectionOutline, StyleConsts.tags.BrushPickerSelectionOutline)
	selectionOutline.Parent = thumbnail
	self.selectionOutlines[index] = selectionOutline

	if brushInfo.tinted then
		StyleUtils.AddStyleTag(icon, StyleConsts.tags.BrushPickerCardTinted)
	end

	local caption = Instance.new("TextLabel")
	caption.Name = "BrushPickerCaption"
	caption.Text = brushInfo.name
	caption.LayoutOrder = 2
	StyleUtils.AddStyleTag(caption, StyleConsts.tags.BrushPickerCaption)
	caption.Parent = tile

	return tile
end

function BrushPicker:AddArrows(scrollFrame)
	-- Arrows in title bar for alternate scroll method (only exist if scrollable)
	local arrows = Instance.new("Frame")
	arrows.Name = "BrushPickerArrows"
	StyleUtils.AddStyleTag(arrows, StyleConsts.tags.BrushPickerArrows)
	self.arrows = arrows

	self.leftArrow = IconButton.createComponentFrame(StyleConsts.icons.ChevronLeft, function()
		self:Scroll(-1)
	end)
	self.leftArrow.Name = "BrushPickerArrowLeft"
	self.leftArrow.LayoutOrder = 1
	self.leftArrow.Parent = arrows

	self.rightArrow = IconButton.createComponentFrame(StyleConsts.icons.ChevronRight, function()
		self:Scroll(1)
	end)
	self.rightArrow.Name = "BrushPickerArrowRight"
	self.rightArrow.LayoutOrder = 2
	self.rightArrow.Parent = arrows

	-- Arrow visibility needs updating if one of these properties change
	for _, property in { "CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize" } do
		table.insert(
			self.connections,
			scrollFrame:GetPropertyChangedSignal(property):Connect(function()
				self:UpdateArrowStates()
			end)
		)
	end

	self:UpdateArrowStates()

	return arrows
end

function BrushPicker.new(brushInfos: { BrushCardInfo }, titleText: string)
	local self = {}
	setmetatable(self, BrushPicker)

	self.selectionOutlines = {}
	self.connections = {} -- keep connections for cleanup

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "BrushPickerScroll"
	StyleUtils.AddStyleTag(scrollFrame, StyleConsts.tags.BrushPickerScroll)
	self.scrollFrame = scrollFrame

	for i, brushInfo in brushInfos do
		local tile = self:AddBrushTile(i, brushInfo)
		tile.Parent = scrollFrame
	end

	local arrows = self:AddArrows(scrollFrame)

	self.frame = ToolFrame.createComponentFrame(scrollFrame, titleText, arrows)

	return self
end

-- Max scroll distance. 0 if content already fits within the viewport.
function BrushPicker:GetMaxScrollX(): number
	return math.max(0, self.scrollFrame.AbsoluteCanvasSize.X - self.scrollFrame.AbsoluteWindowSize.X)
end

-- The horizontal scroll position the arrows should reflect (the current animation target if it exists,
-- otherwise the current canvas position)
function BrushPicker:GetEffectiveScrollX(): number
	local isSliding = self.scrollTween ~= nil and self.scrollTween.PlaybackState == Enum.PlaybackState.Playing
	return if isSliding then self.targetX else self.scrollFrame.CanvasPosition.X
end

-- Slides the row by roughly a page in the given direction (-1 left, 1 right)
function BrushPicker:Scroll(direction: number)
	local step = self.scrollFrame.AbsoluteWindowSize.X * SCROLL_PAGE_FRACTION

	local fromX = self:GetEffectiveScrollX()
	self.targetX = fromX + direction * step

	self.scrollTween = TweenService:Create(self.scrollFrame, SCROLL_TWEEN_INFO, {
		CanvasPosition = Vector2.new(self.targetX, self.scrollFrame.CanvasPosition.Y),
	})
	self.scrollTween:Play()

	-- Reflect the new destination immediately for muting
	self:UpdateArrowStates()
end

-- Shows arrows iff content needs scrolling. Mutes arrows at ends of scrolling frame
function BrushPicker:UpdateArrowStates()
	local maxScrollX = self:GetMaxScrollX()

	-- Nothing to scroll: hide the arrows entirely
	local canScroll = maxScrollX > SCROLL_END_EPSILON
	self:SetArrowsVisible(canScroll)

	local positionX = self:GetEffectiveScrollX()
	self:SetArrowMuted(self.leftArrow, positionX <= SCROLL_END_EPSILON)
	self:SetArrowMuted(self.rightArrow, positionX >= maxScrollX - SCROLL_END_EPSILON)
end

function BrushPicker:SetArrowsVisible(isVisible: boolean)
	StyleUtils.SetStyleTag(self.arrows, StyleConsts.tags.Hidden, not isVisible)
end

function BrushPicker:SetArrowMuted(arrow: TextButton, isMuted: boolean)
	StyleUtils.SetStyleTag(arrow, StyleConsts.tags.IconButtonMuted, isMuted)
end

-- Highlights the tile at the given index and clears any previous selection
function BrushPicker:UpdateSelection(selectedIndex: number)
	for i, selectionOutline in self.selectionOutlines do
		StyleUtils.SetStyleTag(selectionOutline, StyleConsts.tags.MiniBaseTileSelected, i == selectedIndex)
	end
end

function BrushPicker:GetFrame(): Frame
	return self.frame
end

function BrushPicker:Destroy(): ()
	for i, connection in self.connections do
		if connection then
			connection:Disconnect()
			self.connections[i] = nil
		end
	end
end

return BrushPicker
