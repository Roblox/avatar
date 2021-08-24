local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local RoactServices = require(Modules.Common.RoactServices)
local RoactLocalization = require(Modules.Services.RoactLocalization)

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local NumberLocalization = require(Modules.Packages.Localization.NumberLocalization)
local ShimmerPanel = UIBlox.Loading.ShimmerPanel
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local withStyle = UIBlox.Style.withStyle

local Images = UIBlox.App.ImageSet.Images

local ROBUX_ICON = Images["icons/common/robux"]
local ICON_PADDING = 4

local FFlagLuaCatalogFixLongPriceText = true

local ItemCardFooter = Roact.PureComponent:extend("ItemCardFooter")

function ItemCardFooter:render()
	local localization = self.props.localization
	local robuxPrice = self.props.price
	local isPriceLoaded = self.props.isPriceLoaded

	return withStyle(function(stylePalette)
		return withLocalization({
			freeText = "Feature.Catalog.LabelFree",
			offSaleText = "Feature.Catalog.LabelOffSale",
		})(function(localized)
			local font = stylePalette.Font.SubHeader1.Font
			local fontSize = stylePalette.Font.BaseSize * stylePalette.Font.SubHeader1.RelativeSize
			local theme = stylePalette.Theme

			local icon, text
			local iconSize = Vector2.new(fontSize, fontSize)

			if robuxPrice == 0 then
				text = localized.freeText
			elseif robuxPrice then
				icon = ROBUX_ICON
				if FFlagLuaCatalogFixLongPriceText then
					text = string.format("%.0f", robuxPrice)
					text = NumberLocalization.localize(text, localization:GetLocale())
				else
					text = NumberLocalization.localize(robuxPrice, localization:GetLocale())
				end
			elseif isPriceLoaded then
				text = localized.offSaleText
			end

			local iconPadding = 0
			if icon then
				iconPadding = iconSize.X + ICON_PADDING
			end

			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Shimmer = not isPriceLoaded and Roact.createElement(ShimmerPanel, {
					Size = UDim2.new(0.8, 0, 0, fontSize),
				}),

				Icon = icon and Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					Image = icon,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					Size = UDim2.new(0, iconSize.X, 0, iconSize.Y),
				}),

				TextLabel = text and Roact.createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(1, -iconPadding, 1, 0),
					Font = font,
					TextColor3 = theme.SecondaryContent.Color,
					TextTransparency = theme.SecondaryContent.Transparency,
					TextSize = fontSize,
					Text = text,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				})
			})
		end)
	end)
end

ItemCardFooter = RoactServices.connect({
	localization = RoactLocalization,
})(ItemCardFooter)

return ItemCardFooter
