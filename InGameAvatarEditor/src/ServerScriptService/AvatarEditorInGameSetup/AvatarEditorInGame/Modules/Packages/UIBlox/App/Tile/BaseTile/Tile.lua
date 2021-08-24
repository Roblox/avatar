local BaseTile = script.Parent
local TileRoot = BaseTile.Parent
local App = TileRoot.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local UIBloxConfig = require(UIBlox.UIBloxConfig)
local RoactGamepad = require(Packages.RoactGamepad)

local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local t = require(Packages.t)
local withStyle = require(UIBlox.Core.Style.withStyle)
local GetTextSize = require(UIBlox.Core.Text.GetTextSize)

local CursorKind = require(App.SelectionImage.CursorKind)
local withSelectionCursorProvider = require(App.SelectionImage.withSelectionCursorProvider)

local TileName = require(BaseTile.TileName)
local TileThumbnail = require(BaseTile.TileThumbnail)
local TileBanner = require(BaseTile.TileBanner)
local StyledTextLabel = require(App.Text.StyledTextLabel)

local Tile = Roact.PureComponent:extend("Tile")

local tileInterface = t.strictInterface({
	-- The footer Roact element.
	footer = t.optional(t.table),

	-- The item's name that will show a loading state if nil
	name = t.optional(t.string),

	-- Text content to be displayed as a subtitle that will be hidden if nil
	subtitle = t.optional(t.string),

	-- The number of lines of text for the item name
	titleTextLineCount = t.optional(t.integer),

	-- The vertical padding between elements in the ItemTile
	innerPadding = t.optional(t.integer),

	-- The function that gets called on itemTile click
	onActivated = t.optional(t.callback),

	-- The item's thumbnail that will show a loading state if nil
	thumbnail = t.optional(t.union(t.string, t.table)),

	-- The item thumbnail's size if not UDm2.new(1, 0, 1, 0)
	thumbnailSize = t.optional(t.UDim2),

	-- The item thumbnail's transparency if not 0
	thumbnailTransparency = t.optional(t.number),

	-- Optional text to display in the Item Tile banner in place of the footer
	bannerText = t.optional(t.string),

	-- Optional backgroundImage of the tile
	backgroundImage = t.optional(t.union(t.string, t.table)),

	-- Whether the tile is selected or not
	isSelected = t.optional(t.boolean),

	-- Whether the tile is part of a grid where multiple tiles can be selected
	multiSelect = t.optional(t.boolean),

	-- Whether the tile is disabled or not
	isDisabled = t.optional(t.boolean),

	-- Optional boolean indicating whether to create an overlay to round the corners of the image
	hasRoundedCorners = t.optional(t.boolean),

	-- Optional image to be displayed in the title component
	-- Image information should be ImageSet compatible
	titleIcon = t.optional(t.table),

	-- Optional Roact elements that are overlayed over the thumbnail component
	thumbnailOverlayComponents = t.optional(t.table),

	-- optional parameters for RoactGamepad
	NextSelectionLeft = t.optional(t.table),
	NextSelectionRight = t.optional(t.table),
	NextSelectionUp = t.optional(t.table),
	NextSelectionDown = t.optional(t.table),
	thumbnailRef = t.optional(t.table),
})

local function tileBannerUseValidator(props)
	if props.bannerText and props.footer then
		return false, "A custom footer and bannerText can't be used together"
	end

	return true
end

local validateProps = t.intersection(tileInterface, tileBannerUseValidator)

Tile.defaultProps = {
	titleTextLineCount = 2,
	innerPadding = 8,
	isSelected = false,
	multiSelect = false,
	isDisabled = false,
	hasRoundedCorners = true,
}

function Tile:init()
	self.state = {
		tileWidth = 0,
		tileHeight = 0,
	}

	self.onAbsoluteSizeChange = function(rbx)
		local tileWidth = rbx.AbsoluteSize.X
		local tileHeight = rbx.AbsoluteSize.Y
		self:setState({
			tileWidth = tileWidth,
			tileHeight = tileHeight,
		})
	end
end

function Tile:render()
	assert(validateProps(self.props))
	local footer = self.props.footer
	local name = self.props.name
	local subtitle = self.props.subtitle
	local titleTextLineCount = self.props.titleTextLineCount
	local innerPadding = self.props.innerPadding
	local onActivated = self.props.onActivated
	local thumbnail = self.props.thumbnail
	local thumbnailSize = self.props.thumbnailSize
	local thumbnailTransparency = self.props.thumbnailTransparency
	local bannerText = self.props.bannerText
	local hasRoundedCorners = self.props.hasRoundedCorners
	local isSelected = self.props.isSelected
	local multiSelect = self.props.multiSelect
	local isDisabled = self.props.isDisabled
	local titleIcon = self.props.titleIcon
	local thumbnailOverlayComponents = self.props.thumbnailOverlayComponents
	local backgroundImage = self.props.backgroundImage

	return withStyle(function(stylePalette)
		return withSelectionCursorProvider(function(getSelectionCursor)
			local font = stylePalette.Font
			local theme = stylePalette.Theme

			local tileHeight = self.state.tileHeight
			local tileWidth = self.state.tileWidth

			local maxTitleTextHeight = math.ceil(font.BaseSize * font.Header2.RelativeSize * titleTextLineCount)
			local footerHeight = tileHeight - tileWidth - innerPadding - maxTitleTextHeight - innerPadding
			local titleTextSize = Vector2.new(0,0)
			local subtitleTextHeight = 0
			if UIBloxConfig.enableSubtitleOnTile then
				titleTextSize = GetTextSize(
					name or "",
					font.BaseSize * font.Header2.RelativeSize,
					font.Header2.Font,
					Vector2.new(
						tileWidth,
						maxTitleTextHeight
					)
				)
				if (subtitle ~= "" and subtitle ~= nil) then
					subtitleTextHeight = math.ceil(font.BaseSize * font.CaptionHeader.RelativeSize)
					footerHeight = footerHeight - subtitleTextHeight
				end
			end
			footerHeight = math.max(0, footerHeight)

			local hasFooter = footer ~= nil or bannerText ~= nil

			-- TODO: use generic/state button from UIBlox
			return Roact.createElement("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Selectable = false,
				[Roact.Event.Activated] = not isDisabled and onActivated or nil,
				[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChange,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, innerPadding),
				}),
				Thumbnail = Roact.createElement(UIBloxConfig.enableExperimentalGamepadSupport
						and RoactGamepad.Focusable.Frame or "Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					BackgroundTransparency = 1,
					LayoutOrder = 1,

					NextSelectionLeft = self.props.NextSelectionLeft,
					NextSelectionRight = self.props.NextSelectionRight,
					NextSelectionUp = self.props.NextSelectionUp,
					NextSelectionDown = self.props.NextSelectionDown,
					[Roact.Ref] = self.props.thumbnailRef,
					SelectionImageObject = getSelectionCursor(CursorKind.RoundedRectNoInset),
					inputBindings = (UIBloxConfig.enableExperimentalGamepadSupport and not isDisabled and onActivated) and {
						Activate = RoactGamepad.Input.onBegin(Enum.KeyCode.ButtonA, onActivated)
					} or nil,
				}, {
					Image = Roact.createElement(TileThumbnail, {
						Image = thumbnail,
						hasRoundedCorners = hasRoundedCorners,
						isSelected = isSelected,
						multiSelect = multiSelect,
						overlayComponents = thumbnailOverlayComponents,
						imageSize = thumbnailSize,
						imageTransparency = thumbnailTransparency,
						backgroundImage = backgroundImage,
					}),
				}),
				TitleArea = (UIBloxConfig.enableSubtitleOnTile) and Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, titleTextSize.Y+subtitleTextHeight),
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				},{
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 0),
					}),
					Name = (titleTextLineCount > 0 and tileWidth > 0) and Roact.createElement(TileName, {
						titleIcon = titleIcon,
						name = name,
						maxHeight = maxTitleTextHeight,
						maxWidth = tileWidth,
						LayoutOrder = 1,
					}),
					Subtitle = (subtitle ~= "" and subtitle ~= nil) and Roact.createElement(StyledTextLabel, {
						size = UDim2.new(1, 0, 0, subtitleTextHeight),
						text = subtitle,
						colorStyle = theme.TextDefault,
						fontStyle = font.CaptionHeader,
						layoutOrder = 2,
						fluidSizing = false,
						textTruncate = Enum.TextTruncate.AtEnd,
						richText = false,
						lineHeight = 1,
					}),
				}) or (titleTextLineCount > 0 and tileWidth > 0) and Roact.createElement(TileName, {
					titleIcon = titleIcon,
					name = name,
					maxHeight = maxTitleTextHeight,
					maxWidth = tileWidth,
					LayoutOrder = 2,
				}),
				FooterContainer = hasFooter and Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, footerHeight),
					BackgroundTransparency = 1,
					LayoutOrder = 3,
				}, {
					Banner = bannerText and Roact.createElement(TileBanner, {
						bannerText = bannerText,
					}),
					Footer = not bannerText and footer,
				}),
			})
		end)
	end)
end

return Roact.forwardRef(function(props, ref)
	return Roact.createElement(Tile, Cryo.Dictionary.join(props, {
		thumbnailRef = ref
	}))
end)
