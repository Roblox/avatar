local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local Images = UIBlox.App.ImageSet.Images

local FitChildren = require(Modules.NotLApp.FitChildren)
local BodySizeSlider = require(Modules.AvatarExperience.AvatarEditor.Components.BodySizeSlider)


local ICON_SIZE = 36
local TALL_IMAGE_SET = Images["icons/menu/body_tall"]
local THIN_IMAGE_SET = Images["icons/menu/body_thin"]
local HEAVY_IMAGE_SET = Images["icons/menu/body_heavy"]
local SHORT_IMAGE_SET = Images["icons/menu/body_short"]

local BodySizeRadar = Roact.PureComponent:extend("BodySizeRadar")

function BodySizeRadar:render()
	return withStyle(function(stylePalette)
		return withLocalization({
			bodySize = "Feature.Avatar.Label.BodySize",
		})(function(localized)
			local lockNavigationCallback = self.props.lockNavigationCallback
			local unlockNavigationCallback = self.props.unlockNavigationCallback
			local layoutOrder = self.props.LayoutOrder
			local fontInfo = stylePalette.Font
			local theme = stylePalette.Theme
			local font = fontInfo.Header2.Font
			local fontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize

			return Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				LayoutOrder = layoutOrder,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 24),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				BodySizeLabel = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, fontSize),
					BackgroundTransparency = 1,
					Text = localized.bodySize,
					TextSize = fontSize,
					TextColor3 = theme.TextDefault.Color,
					TextTransparency = theme.TextDefault.TextTransparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
					Font = font,
				}),
				BodySizeContainer = Roact.createElement(FitChildren.FitFrame, {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					TallIcon = Roact.createElement(ImageSetLabel, {
						AnchorPoint = Vector2.new(0, 0.5),
						LayoutOrder = 1,
						Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
						BackgroundTransparency = 1,
						ImageColor3 = theme.IconEmphasis.Color,
						Image = TALL_IMAGE_SET,
					}),
					Wrapper = Roact.createElement(FitChildren.FitFrame, {
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						fitAxis = FitChildren.FitAxis.Height,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),
						ThinIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							LayoutOrder = 1,
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
							BackgroundTransparency = 1,
							ImageColor3 = theme.IconEmphasis.Color,
							Image = THIN_IMAGE_SET,
						}),
						BodySize = Roact.createElement(BodySizeSlider, {
							LayoutOrder = 2,
							lockNavigationCallback = lockNavigationCallback,
							unlockNavigationCallback = unlockNavigationCallback,
						}),
						HeavyIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							LayoutOrder = 3,
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
							ImageColor3 = theme.IconEmphasis.Color,
							BackgroundTransparency = 1,
							Image = HEAVY_IMAGE_SET,
						}),
					}),
					ShortIcon = Roact.createElement(ImageSetLabel, {
						AnchorPoint = Vector2.new(0, 0.5),
						LayoutOrder = 3,
						Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
						BackgroundTransparency = 1,
						ImageColor3 = theme.IconEmphasis.Color,
						Image = SHORT_IMAGE_SET,
					}),
				}),
			})
		end)
	end)
end

return BodySizeRadar
