local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)

local UIBlox = require(Modules.Packages.UIBlox)

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local LocalizedFitTextLabel = require(Modules.NotLApp.LocalizedFitTextLabel)
local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local FitChildren = require(Modules.NotLApp.FitChildren)

local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local Images = UIBlox.App.ImageSet.Images

local LINK_ARROW_IMAGE = Images["icons/navigation/pushRight_small"]
local LINK_ARROW_IMAGE_SIZE = 14
local LINK_ARROW_PRE_SPACE = 11

local FFlagLuaCatalogInfoRowEclispe = true

local ItemInfoRow = Roact.PureComponent:extend("ItemInfoRow")

ItemInfoRow.defaultProps = {
	horizontalPadding = 0,
}

function ItemInfoRow:render()
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local infoName = self.props.infoName
	local infoData = self.props.infoData
	local horizontalPadding = self.props.horizontalPadding
	local onActivate = self.props.onActivate

	local renderFuntion = function(stylePalette, localized)
		local theme = stylePalette.Theme
		local font = stylePalette.Font

		local linkTextColor = theme.TextEmphasis.Color

		local textSize = font.BaseSize * font.Body.RelativeSize

		local infoNameTextLabel
		local infoDataTextLabel
		if FFlagLuaCatalogInfoRowEclispe then
			infoNameTextLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = font.Body.Font,
				LayoutOrder = 1,
				Size = UDim2.new(0.5, 0, 1, 0),
				Text = localized.name,
				TextColor3 = theme.TextDefault.Color,
				TextSize = textSize,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			})
			infoDataTextLabel = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, onActivate and (- LINK_ARROW_PRE_SPACE - LINK_ARROW_IMAGE_SIZE) or 0, 0, 0),
				BackgroundTransparency = 1,
				Font = onActivate and font.Header2.Font or font.Body.Font,
				LayoutOrder = 2,
				Size = UDim2.new(0.5, 0, 1, 0),
				Text = infoData,
				TextColor3 = onActivate and theme.TextEmphasis.Color or theme.TextDefault.Color,
				TextSize = textSize,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Center,
			})
		else
			infoNameTextLabel = Roact.createElement(LocalizedFitTextLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = font.Body.Font,
				Size = UDim2.new(0, 0, 1, 0),
				Text = infoName,
				TextColor3 = theme.TextDefault.Color,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,

				fitAxis = FitChildren.FitAxis.Width,
			})
			infoDataTextLabel = Roact.createElement(FitTextLabel, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, onActivate and (- LINK_ARROW_PRE_SPACE - LINK_ARROW_IMAGE_SIZE) or 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = onActivate and font.Header2.Font or font.Body.Font,
				Size = UDim2.new(0, 0, 1, 0),
				TextColor3 = onActivate and theme.TextEmphasis.Color or theme.TextDefault.Color,
				Text = infoData,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Center,
				LayoutOrder = 1,

				fitAxis = FitChildren.FitAxis.Width,
			})
		end

		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
			Position = position,
			Size = size,

			[Roact.Event.Activated] = onActivate,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, horizontalPadding),
				PaddingRight = UDim.new(0, horizontalPadding),
			}),
			InfoNameTextLabel = infoNameTextLabel,
			InfoDataTextLabel = infoDataTextLabel,
			LinkArrow = onActivate and Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, LINK_ARROW_IMAGE_SIZE, 0, LINK_ARROW_IMAGE_SIZE),
				Image = LINK_ARROW_IMAGE,
				ImageColor3 = linkTextColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}),
		})
	end

	if FFlagLuaCatalogInfoRowEclispe then
		return withLocalization({
			name = infoName,
		})(function(localized)
			return withStyle(
				function(stylized)
					return renderFuntion(stylized, localized)
				end)
		end)
	else
		return withStyle(renderFuntion)
	end
end

return ItemInfoRow
