local BaseTile = script.Parent
local Tile = BaseTile.Parent
local App = Tile.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)
local withStyle = require(UIBlox.Core.Style.withStyle)

local Images = require(UIBlox.App.ImageSet.Images)
local ImageTextLabel = require(UIBlox.Core.Text.ImageTextLabel.ImageTextLabel)
local ShimmerPanel = require(UIBlox.App.Loading.ShimmerPanel)

local ICON_PADDING = 4
local LINE_PADDING = 4

local ItemTileName = Roact.PureComponent:extend("ItemTileName")

local validateProps = t.strictInterface({
	LayoutOrder = t.optional(t.integer),

	maxHeight = t.intersection(t.integer, t.numberMin(0)),
	maxWidth =  t.intersection(t.integer, t.numberMin(0)),

	-- Loading skeleton will be rendered if name is not included
	name = t.optional(t.string),

	-- Optional image to be displayed in the title component
	-- Image information should be ImageSet compatible
	titleIcon = t.optional(t.table),
})

function ItemTileName:render()
	assert(validateProps(self.props))

	local layoutOrder = self.props.LayoutOrder
	local maxHeight = self.props.maxHeight
	local maxWidth = self.props.maxWidth
	local name = self.props.name
	local titleIcon = self.props.titleIcon

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font
		local textSize = font.BaseSize * font.Header2.RelativeSize

		if name ~= nil then
			local titleIconSize = titleIcon and titleIcon.ImageRectSize / Images.ImagesResolutionScale or Vector2.new(0, 0)

			return Roact.createElement(ImageTextLabel, {
				imageProps = titleIcon and {
					BackgroundTransparency = 1,
					Image = titleIcon,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					Size = UDim2.new(0, titleIconSize.X, 0, titleIconSize.Y),
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, 0, 0, 0),
				} or nil,

				genericTextLabelProps = {
					fontStyle = font.Header2,
					colorStyle = theme.TextEmphasis,
					Text = name,
					TextTruncate = Enum.TextTruncate.AtEnd,
				},

				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = layoutOrder,
				},

				maxSize = Vector2.new(maxWidth, maxHeight),
				padding = ICON_PADDING,
			})
		else
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = layoutOrder,
				Size = UDim2.new(0, maxWidth, 0, maxHeight),
			}, {
				FirstLine = Roact.createElement(ShimmerPanel, {
					Size = UDim2.new(1, 0, 0, textSize),
				}),

				SecondLine = Roact.createElement(ShimmerPanel, {
					Position = UDim2.new(0, 0, 0, textSize + LINE_PADDING),
					Size = UDim2.new(0.4, 0, 0, textSize),
				}),
			})
		end
	end)
end

return ItemTileName
