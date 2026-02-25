local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local LocalizedTextLabel = require(Modules.NotLApp.LocalizedTextLabel)
local LocalizedTextButton = require(Modules.NotLApp.LocalizedTextButton)

local END_OF_SCROLL_PADDING = 20
local END_OF_SCROLL_FONT_SIZE = 20
local END_OF_SCROLL_MESSAGE_HEIGHT = END_OF_SCROLL_FONT_SIZE
local END_OF_SCROLL_BUTTON_HEIGHT = END_OF_SCROLL_FONT_SIZE + 10
local END_OF_SCROLL_HEIGHT = END_OF_SCROLL_PADDING * 2 + END_OF_SCROLL_MESSAGE_HEIGHT + END_OF_SCROLL_BUTTON_HEIGHT

local function GamesListEndOfScroll(props)
	local backToTopCallback = props.backToTopCallback
	local LayoutOrder = props.LayoutOrder

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, END_OF_SCROLL_HEIGHT),
			LayoutOrder = LayoutOrder,
		}, {
			Message = Roact.createElement(LocalizedTextLabel, {
				Size = UDim2.new(1, 0, 0, END_OF_SCROLL_MESSAGE_HEIGHT),
				Position = UDim2.new(0, 0, 0, END_OF_SCROLL_PADDING),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "Feature.GamePage.Message.EndOfList",
				Font = style.Font.Body.Font,
				TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
				TextColor3 = style.Theme.TextDefault.Color,
				TextTransparency = style.Theme.TextDefault.Transparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			BackToTopButton = Roact.createElement(LocalizedTextButton, {
				Size = UDim2.new(0.5, 0, 0, END_OF_SCROLL_BUTTON_HEIGHT),
				Position = UDim2.new(0.25, 0, 0, END_OF_SCROLL_MESSAGE_HEIGHT + END_OF_SCROLL_PADDING),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "Feature.GamePage.Action.BackToTop",
				Font = style.Font.Body.Font,
				TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
				TextColor3 = style.Theme.TextEmphasis.Color,
				TextTransparency = style.Theme.TextEmphasis.Transparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				[Roact.Event.Activated] = backToTopCallback,
			}),
		})
	end)

end

return GamesListEndOfScroll