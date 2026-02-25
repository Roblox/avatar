local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local TextService = game:GetService("TextService")

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local t = require(Modules.Packages.t)
local UIBlox = require(Modules.Packages.UIBlox)

local withLocalization = require(Modules.Packages.Localization.withLocalization)
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local FitFrame = require(Modules.Packages.FitFrame)
local FitFrameVertical = FitFrame.FitFrameVertical

local withStyle = UIBlox.Style.withStyle
local TwoKnobSystemSlider = UIBlox.App.Slider.TwoKnobSystemSlider

local CatalogPrompt = require(Modules.AvatarExperience.Catalog.Components.Search.Prompts.CatalogPrompt)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetPriceRange = require(Modules.AvatarExperience.Catalog.Actions.SetPriceRange)

local Images = UIBlox.App.ImageSet.Images

local ROBUX_ICON = Images["icons/common/robux"]
local ICON_PADDING = 4
local ELEMENTS_PADDING = 12
local VERTICAL_MARGIN = 12

local PriceFilterPrompt = Roact.PureComponent:extend("PriceFilterPrompt")

PriceFilterPrompt.validateProps = t.strictInterface({
	onAcceptCallback = t.callback,
	minPrice = t.number,
	maxPrice = t.number,
	setPriceRange = t.callback,
	containerWidth = t.number,
})

function PriceFilterPrompt:init()
	self.state = {
		minPrice = self.props.minPrice,
		maxPrice = self.props.maxPrice,
	}

	self.onValueChanged = function(lowerValue, upperValue)
		self:setState({
			minPrice = lowerValue,
			maxPrice = upperValue,
		})
	end
end


function PriceFilterPrompt:onResetPressed()
	self:setState({
		minPrice = CatalogConstants.MinPriceFilter,
		maxPrice = CatalogConstants.MaxPriceFilter})
end

function PriceFilterPrompt:onApplyClicked()
	self.props.setPriceRange(self.state.minPrice, self.state.maxPrice)
	self.props.onAcceptCallback()
end

function PriceFilterPrompt:render()
	return withStyle(function(styles)
		return withLocalization({
			reset = "CommonUI.Messages.Action.Reset",
			price = "Feature.Catalog.Label.Price",
			free = "Feature.Catalog.Label.FreeUpperCase",
		})(function(localized)
			local fontInfo = styles.Font
			local theme = styles.Theme

			local font = fontInfo.CaptionBody.Font
			local fontSize = fontInfo.BaseSize * fontInfo.CaptionBody.RelativeSize

			local priceFont = fontInfo.SubHeader1.Font
			local priceFontSize = fontInfo.BaseSize * fontInfo.SubHeader1.RelativeSize
			local iconSize = Vector2.new(priceFontSize, priceFontSize)

			local textColor = theme.TextEmphasis.Color
			local textTransparency = theme.TextEmphasis.Transparency

			local minPrice = tostring(self.state.minPrice) .. " - "
			local maxPrice
			if self.state.maxPrice == CatalogConstants.MaxPriceFilter then
				maxPrice = tostring(CatalogConstants.MaxPriceFilter) .. "+"
			else
				maxPrice = tostring(self.state.maxPrice)
			end
			local twoPrices = self.state.minPrice ~= self.state.maxPrice

			local minPriceWidth = TextService:GetTextSize(minPrice, priceFontSize, priceFont,
				Vector2.new(math.huge, priceFontSize)).X

			return Roact.createElement(CatalogPrompt, {
				title = localized.price,
				onApply = function() self:onApplyClicked() end,
			}, {
				Frame = Roact.createElement(FitFrameVertical, {
					width = UDim.new(1, 0),
					BackgroundTransparency = 1,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					contentPadding = UDim.new(0, ELEMENTS_PADDING),
					margin = FitFrame.Rect.quad(VERTICAL_MARGIN, 0, VERTICAL_MARGIN, 0),
				}, {
					Frame = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundTransparency = 1,
						LayoutOrder = 1
					}, self.state.maxPrice == 0 and {
						Free = Roact.createElement("TextLabel", {
							Position = UDim2.new(0, 0, 0.5, 0),
							TextSize = priceFontSize,
							TextColor3 = textColor,
							TextTransparency = textTransparency,
							Text = localized.free,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							Font = priceFont,
						})
					} or {
						Layout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, ICON_PADDING),
						}),
						MinRobuxIcon = twoPrices and Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							LayoutOrder = 1,
							Size = UDim2.new(0, iconSize.X, 0, iconSize.Y),
							BackgroundTransparency = 1,
							ImageColor3 = theme.IconEmphasis.Color,
							Image = ROBUX_ICON,
						}),
						MinPrice = twoPrices and Roact.createElement("TextLabel", {
							Size = UDim2.new(0, minPriceWidth, 1, 0),
							BackgroundTransparency = 1,
							TextSize = priceFontSize,
							TextColor3 = textColor,
							TextTransparency = textTransparency,
							Text = minPrice,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							Font = priceFont,
							LayoutOrder = 2,
						}),
						MaxRobuxIcon = Roact.createElement(ImageSetLabel, {
							AnchorPoint = Vector2.new(0, 0.5),
							LayoutOrder = 3,
							Size = UDim2.new(0, iconSize.X, 0, iconSize.Y),
							BackgroundTransparency = 1,
							ImageColor3 = theme.IconEmphasis.Color,
							Image = ROBUX_ICON,
						}),
						MaxPrice = Roact.createElement("TextLabel", {
							TextSize = priceFontSize,
							TextColor3 = textColor,
							TextTransparency = textTransparency,
							Text = maxPrice,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							Font = priceFont,
							LayoutOrder = 4,
						}),
					}),
					Slider = Roact.createElement(TwoKnobSystemSlider, {
						min = CatalogConstants.MinPriceFilter,
						max = CatalogConstants.MaxPriceFilter,
						stepInterval = CatalogConstants.PriceFilterStep,
						lowerValue = self.state.minPrice,
						upperValue = self.state.maxPrice,
						width = UDim.new(1, 0),
						layoutOrder = 2,
						onValueChanged = self.onValueChanged,
					}),
					Reset = Roact.createElement("TextButton", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundTransparency = 1,
						LayoutOrder = 3,
						Text = localized.reset,
						TextSize = fontSize,
						TextColor3 = textColor,
						TextTransparency = textTransparency,
						Font = font,
						[Roact.Event.Activated] = function() self:onResetPressed() end,
					}),
				})
			})
		end)
	end)
end

PriceFilterPrompt = RoactRodux.UNSTABLE_connect2(
	function(state)
		return {
			minPrice = state.AvatarExperience.Catalog.SortAndFilters.PriceRange.minPrice,
			maxPrice = state.AvatarExperience.Catalog.SortAndFilters.PriceRange.maxPrice,
		}
	end,
	function(dispatch)
		return {
			setPriceRange = function(minPrice, maxPrice)
				dispatch(SetPriceRange(minPrice, maxPrice))
			end,
		}
	end
)(PriceFilterPrompt)

return PriceFilterPrompt
