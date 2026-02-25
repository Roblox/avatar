local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local FitChildren = require(Modules.NotLApp.FitChildren)

local BodyTypeRadar = require(Modules.AvatarExperience.AvatarEditor.Components.BodyTypeRadar)
local BodySizeRadar = require(Modules.AvatarExperience.AvatarEditor.Components.BodySizeRadar)
local HeadSlider = require(Modules.AvatarExperience.AvatarEditor.Components.HeadSlider)
local AvatarTypeSwitch = require(Modules.AvatarExperience.AvatarEditor.Components.AvatarTypeSwitch)

local ScalesPage = Roact.PureComponent:extend("ScalesPage")

local SIDE_PADDING = 10

function ScalesPage:render()
	return withStyle(function(stylePalette)
		return withLocalization({
			headSize = "Feature.Avatar.Label.HeadSize",
			r6R15 = "Feature.Avatar.Label.R6R15",
		})(function(localized)
			local lockNavigationCallback = self.props.lockNavigationCallback
			local unlockNavigationCallback = self.props.unlockNavigationCallback
			local enableNavigation = self.props.enableNavigation
			local fontInfo = stylePalette.Font
			local theme = stylePalette.Theme
			local font = fontInfo.Header2.Font
			local fontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize

			return Roact.createElement(FitChildren.FitScrollingFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ScrollBarThickness = 0,
				ElasticBehavior = Enum.ElasticBehavior.Always,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollingEnabled = enableNavigation,
				fitFields = {
					CanvasSize = FitChildren.FitAxis.Height,
				},
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, SIDE_PADDING * 2),
					PaddingLeft = UDim.new(0, 24),
					PaddingRight = UDim.new(0, 24),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, SIDE_PADDING),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
				}),
				BodyTypeWrapper = Roact.createElement(BodyTypeRadar, {
					lockNavigationCallback = self.props.lockNavigationCallback,
					unlockNavigationCallback = self.props.unlockNavigationCallback,
					enableNavigation = self.props.enableNavigation,
					layoutOrder = 1,
				}),
				BodySizeWrapper = Roact.createElement(BodySizeRadar, {
					lockNavigationCallback = self.props.lockNavigationCallback,
					unlockNavigationCallback = self.props.unlockNavigationCallback,
					enableNavigation = self.props.enableNavigation,
					layoutOrder = 2,
				}),
				HeadSizeWrapper = Roact.createElement(FitChildren.FitFrame, {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 24),
					}),
					UIListLayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 11),
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					HeadSizeLabel = Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 0, fontSize),
						BackgroundTransparency = 1,
						Text = localized.headSize,
						TextSize = fontSize,
						TextColor3 = theme.TextDefault.Color,
						TextTransparency = theme.TextDefault.TextTransparency,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 1,
						Font = font,
					}),
					HeadSize = Roact.createElement(HeadSlider, {
						LayoutOrder = 2,
						lockNavigationCallback = lockNavigationCallback,
						unlockNavigationCallback = unlockNavigationCallback,
					}),
				}),
				R6R15Wrapper = Roact.createElement(FitChildren.FitFrame, {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 4,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 24),
					}),
					UIListLayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 11),
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					R6R15Label = Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 0, fontSize),
						BackgroundTransparency = 1,
						Text = localized.r6R15,
						TextSize = fontSize,
						TextColor3 = theme.TextDefault.Color,
						TextTransparency = theme.TextDefault.TextTransparency,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 1,
						Font = font,
					}),
					AvatarTypeSwitch = Roact.createElement(AvatarTypeSwitch, {
						LayoutOrder = 2
					}),
				}),
			})
		end)
	end)
end

return ScalesPage