local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local FitChildren = require(Modules.NotLApp.FitChildren)
local LocalizedFitTextLabel = require(Modules.NotLApp.LocalizedFitTextLabel)
local RetryButton = require(Modules.NotLApp.RetryButton)

local MESSAGE_FONT_SIZE = 26
local MESSAGE_PADDING_X = 40
local MESSAGE_PADDING_Y = 40
local MESSAGE_WIDTH_MAX = 400
local ESTIMATED_MESSAGE_HEIGHT = MESSAGE_FONT_SIZE + MESSAGE_PADDING_Y * 2

local ERROR_IMAGE_SIZE = UDim2.new(0, 128, 0, 91)
local ERROR_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/noconnection.png"

local EmptyStatePage = Roact.PureComponent:extend("EmptyStatePage")

function EmptyStatePage:render()
	local onRetry = self.props.onRetry
	local screenWidth = self.props.screenWidth
	local clipsDescendants = self.props.ClipsDescendants

	local messageWidth = screenWidth - MESSAGE_PADDING_X * 2
	messageWidth = math.min(messageWidth, MESSAGE_WIDTH_MAX)

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = style.Theme.BackgroundDefault.Color,
			BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			ClipsDescendants = clipsDescendants,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Image = Roact.createElement("ImageLabel", {
				Size = ERROR_IMAGE_SIZE,
				BackgroundTransparency = 1,
				ImageColor3 = style.Theme.UIMuted.Color,
				ImageTransparency = style.Theme.UIMuted.Transparency,
				LayoutOrder = 1,
				Image = ERROR_IMAGE,
			}),
			Message = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(0, messageWidth, 0, ESTIMATED_MESSAGE_HEIGHT),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				-- FitChildren currently cannot calculate correctly
				-- with UIPadding. Adding a ListLayout can help fix that.
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, MESSAGE_PADDING_Y),
					PaddingBottom = UDim.new(0, MESSAGE_PADDING_Y),
				}),
				Text = Roact.createElement(LocalizedFitTextLabel, {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "Feature.EmptyStatePage.Message.NoInternet",
					TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
					Font = style.Font.Body.Font,
					TextColor3 = style.Theme.TextDefault.Color,
					TextTransparency = style.Theme.TextDefault.Transparency,
					TextWrapped = true,
					fitAxis = FitChildren.FitAxis.Height,
				}),
			}),
			RetryButton = Roact.createElement(RetryButton, {
				LayoutOrder = 3,
				onRetry = onRetry,
			}),
		})
	end)

end

EmptyStatePage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenWidth = state.ScreenSize.X,
		}
	end
)(EmptyStatePage)

return EmptyStatePage