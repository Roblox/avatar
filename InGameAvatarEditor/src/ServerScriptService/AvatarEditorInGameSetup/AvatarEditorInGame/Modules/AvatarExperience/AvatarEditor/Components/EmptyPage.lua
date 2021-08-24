local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local withLocalization = require(Modules.Packages.Localization.withLocalization)
local FitChildren = require(Modules.NotLApp.FitChildren)

local EmptyPage = Roact.PureComponent:extend("EmptyPage")

local NO_ITEMS_LABEL = "Feature.Avatar.Label.NoItems"
local _NO_ITEMS_IMAGE = "" -- TODO Add this icon when design finishes it.

function EmptyPage:render()
	local page = self.props.page
	local itemTypeString = page.EmptyString or page.Title

	return withStyle(function(stylePalette)
		return withLocalization({
			itemType = itemTypeString,
			noItemsLabel = NO_ITEMS_LABEL,
		})(function(localized)
			local noItemsLabel = localized.noItemsLabel:gsub("({itemType})", localized.itemType)
			local theme = stylePalette.Theme
			local fontInfo = stylePalette.Font
			local font = fontInfo.Header2.Font
			local fontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize

			return Roact.createElement(FitChildren.FitFrame, {
				BorderSizePixel = 0,
				BackgroundColor3 = theme.BackgroundDefault.Color,
				BackgroundTransparency = theme.BackgroundDefault.Transparency,
				Size = UDim2.new(1, 0, 1, 0),
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 9),
					PaddingBottom = UDim.new(0, 24),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 22),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				-- Image = Roact.createElement(ImageSetLabel, {
				-- 	AnchorPoint = Vector2.new(0.5, 0.5),
				-- 	Position = UDim2.new(0.5, 0, 0.5, 0),
				-- 	Size = UDim2.new(0, 50, 0, 50),
				-- }),
				NoItemsText = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, fontSize),
					BackgroundTransparency = 1,
					Text = noItemsLabel,
					TextSize = fontSize,
					TextColor3 = theme.TextDefault.Color,
					TextTransparency = theme.TextDefault.TextTransparency,
					TextXAlignment = Enum.TextXAlignment.Center,
					LayoutOrder = 1,
					Font = font,
				}),
			})
		end)
	end)
end

return EmptyPage