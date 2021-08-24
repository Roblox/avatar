local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Roact = require(Modules.Packages.Roact)
local RoactServices = require(Modules.Common.RoactServices)
local RoactLocalization = require(Modules.Services.RoactLocalization)
local UIBlox = require(Modules.Packages.UIBlox)
local ShimmerPanel = UIBlox.Loading.ShimmerPanel
local withStyle = UIBlox.Style.withStyle

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local FitChildren = require(Modules.NotLApp.FitChildren)
local PrimaryStatWidget = require(Modules.NotLApp.PrimaryStatWidget)

local NumberLocalization = require(Modules.Packages.Localization.NumberLocalization)

local function abbreviateCount(number, locale)
	return NumberLocalization.abbreviate(number, locale)
end

local Images = UIBlox.App.ImageSet.Images

local FAVORITES_ICON = Images["icons/actions/favoriteOn"]
local RATINGS_HEIGHT = 70
local BACKGROUND_IMAGE_SLICE_CENTER = Rect.new(9, 9, 9, 9)


local ItemStatistics = Roact.PureComponent:extend("ItemStatistics")

ItemStatistics.defaultProps = {
	LayoutOrder = 0,
	Position = UDim2.new(0,0,0,0),
	listPadding = 10,
	width = 0,
}

function ItemStatistics:render()
	local favoritesCount = self.props.favoritesCount
	local layoutOrder = self.props.LayoutOrder
	local position = self.props.Position
	local width = self.props.width
	local localization = self.props.localization

	local listPadding = self.props.listPadding

	if not favoritesCount then
		return Roact.createElement(ShimmerPanel, {
			Position = position,
			Size = UDim2.new(0, width, 0, RATINGS_HEIGHT),
			LayoutOrder = layoutOrder,
		})
	end

	local widgetWidth = (width - listPadding)/2

	local favoritesText = localization:Format("Feature.Catalog.Label.Favorites")
	local favoritesCountText = abbreviateCount(favoritesCount, localization:GetLocale())

	local renderFuntion = function(stylePalette)
		local font = stylePalette.Font
		local theme = stylePalette.Theme

		return Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, width, 0, RATINGS_HEIGHT),
			Position = position,
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = BACKGROUND_IMAGE_SLICE_CENTER,
		}, {
			ItemStatisticsSection = Roact.createElement(FitChildren.FitFrame, {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				fitAxis = FitChildren.FitAxis.Height,
				LayoutOrder = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, width, 0, 0),
			}, {
				ListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0,listPadding),
				}),
				FavoritesSection = Roact.createElement(PrimaryStatWidget, {
					icon = FAVORITES_ICON,
					number = favoritesCountText,
					label = favoritesText,
					font = font.Header1.Font,
					color = theme.TextDefault.Color,
					width = widgetWidth,
					LayoutOrder = 0,
				}),
			}),
		})
	end
	return withStyle(renderFuntion)
end

ItemStatistics = RoactServices.connect({
	localization = RoactLocalization,
})(ItemStatistics)

return ItemStatistics
