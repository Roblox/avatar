local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local FitChildren = require(Modules.NotLApp.FitChildren)
local ShimmerPanel = UIBlox.Loading.ShimmerPanel
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local SIDE_PADDING = 30
local TITLE_KEYWORD_PADDING = 2

local ResultsHeader = Roact.PureComponent:extend("ResultsHeader")

function ResultsHeader:renderWithStyle(stylePalette)
    local fontInfo = stylePalette.Font

    local font = fontInfo.Body.Font
    local fontSize = fontInfo.BaseSize * fontInfo.Body.RelativeSize

    local keywordFont = fontInfo.Header2.Font
    local keywordFontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize

    local theme = stylePalette.Theme
    local textColor3 = theme.TextEmphasis.Color
    local textTransparency = theme.TextEmphasis.Transparency

    local searchInCatalog = self.props.searchInCatalog
    if not searchInCatalog then
		return Roact.createElement(ShimmerPanel, {
			Size = UDim2.new(1, -SIDE_PADDING, 0, fontSize),
		})
    end

    local keyword = searchInCatalog.keyword

    return withLocalization({
        showingResultsFor = "Feature.GamePage.LabelShowingResultsFor",
    })(function(localized)
        return Roact.createElement(FitChildren.FitFrame, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = 1,
            fitAxis = FitChildren.FitAxis.Height,
        }, {
            ShowingResultsFrame = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, fontSize),
                LayoutOrder = 1,
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
                }),

                ShowingResultsText = Roact.createElement(FitTextLabel, {
                    Text = localized.showingResultsFor,
                    LayoutOrder = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextSize = fontSize,
                    TextColor3 = textColor3,
                    TextTransparency = textTransparency,
                    Font = font,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    fitAxis = FitChildren.FitAxis.Width,
                }),

                Keyword = Roact.createElement(FitTextLabel, {
                    Text = keyword or "",
                    LayoutOrder = 2,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextSize = keywordFontSize,
                    TextColor3 = textColor3,
                    TextTransparency = textTransparency,
                    Font = keywordFont,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    fitAxis = FitChildren.FitAxis.Width,
                }),
            }),
        })
    end)
end

function ResultsHeader:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

local function mapStateToProps(state, props)
    return {
        searchInCatalog = state.Search.SearchesInCatalog[props.searchUuid],
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(ResultsHeader)