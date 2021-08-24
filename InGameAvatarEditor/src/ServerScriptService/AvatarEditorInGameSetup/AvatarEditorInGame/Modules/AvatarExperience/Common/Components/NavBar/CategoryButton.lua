local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local Text = require(Modules.Common.Text)
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local withStyle = UIBlox.Style.withStyle

local CategoryButton = Roact.PureComponent:extend("CategoryButton")

local PADDING = 20

function CategoryButton:renderWithLocalized(localized)
    local renderWithStyle = function(stylePalette)
        local fontInfo = stylePalette.Font
        local theme = stylePalette.Theme

        local isSelected = self.props.isSelected

        local font = fontInfo.Header2.Font
        local fontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize

        local textWidth = Text.GetTextWidth(localized.title, font, fontSize)
        local textColor = isSelected and theme.TextEmphasis.Color or theme.TextMuted.Color
        local textTransparency = isSelected and theme.TextEmphasis.Transparency or theme.TextMuted.Transparency

        local frameWidth = textWidth + PADDING

        return Roact.createElement("Frame", {
            Size = UDim2.new(0, frameWidth, 1, 0),
            BackgroundTransparency = 1,
            LayoutOrder = self.props.layoutOrder,

            [Roact.Ref] = self.props.ref,
        }, {
            Button = Roact.createElement("TextButton", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = localized.title,
                TextSize = fontSize,
                TextColor3 = textColor,
                TextTransparency = textTransparency,
                Font = font,

                [Roact.Event.Activated] = function()
                    self.props.onActivate(self.props.categoryIndex)
                end,
            }),
        })
    end

    return withStyle(renderWithStyle)
end

function CategoryButton:render()
    return withLocalization({
        title = self.props.categoryTitle,
    })(function(localized)
        return self:renderWithLocalized(localized)
    end)
end

return CategoryButton