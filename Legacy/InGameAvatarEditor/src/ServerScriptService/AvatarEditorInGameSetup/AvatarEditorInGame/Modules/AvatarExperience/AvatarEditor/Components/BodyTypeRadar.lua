local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local FitChildren = require(Modules.NotLApp.FitChildren)
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local BodyTypeSlider = require(Modules.AvatarExperience.AvatarEditor.Components.BodyTypeSlider)

local Images = UIBlox.App.ImageSet.Images

local ICON_SIZE = 36
local RTHRO_WOMAN_IMAGE_SET = Images["icons/menu/body_female"]
local RTHRO_MAN_IMAGE_SET = Images["icons/menu/body_male"]
local MINI_FIG_IMAGE_SET = Images["icons/menu/body_neutral"]

local BodyTypeRadar = Roact.PureComponent:extend("BodyTypeRadar")

function BodyTypeRadar:render()
	return withStyle(function(stylePalette)
		return withLocalization({
			bodyType = "Feature.Avatar.Label.BodyType",
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
					Padding = UDim.new(0, 36),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				BodyTypeLabel = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, fontSize),
					BackgroundTransparency = 1,
					Text = localized.bodyType,
					TextSize = fontSize,
					TextColor3 = theme.TextDefault.Color,
					TextTransparency = theme.TextDefault.TextTransparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
					Font = font,
				}),
				Container = Roact.createElement(FitChildren.FitFrame, {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					UpperRow = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						LayoutOrder = 1,
						fitAxis = FitChildren.FitAxis.Height,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),
						RthroWomanIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
							BackgroundTransparency = 1,
							ImageColor3 = theme.IconEmphasis.Color,
							Image = RTHRO_WOMAN_IMAGE_SET,
							LayoutOrder = 1,
						}),

						BodyType = Roact.createElement(BodyTypeSlider, {
							lockNavigationCallback = lockNavigationCallback,
							unlockNavigationCallback = unlockNavigationCallback,
							LayoutOrder = 2,
						}),

						RthroManIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -36, 0, 0),
							ImageColor3 = theme.IconEmphasis.Color,
							Image = RTHRO_MAN_IMAGE_SET,
							LayoutOrder = 3,
						}),
					}),
					LowerRow = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 36),
						LayoutOrder = 2,
						fitAxis = FitChildren.FitAxis.Height,
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingTop = UDim.new(0, 8),
						}),
						MiniFigIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
							Position = UDim2.new(0.5, 0, 0, 0),
							BackgroundTransparency = 1,
							ImageColor3 = theme.IconEmphasis.Color,
							Image = MINI_FIG_IMAGE_SET,
						}),
					}),
				}),
			})
		end)
	end)
end

return BodyTypeRadar
