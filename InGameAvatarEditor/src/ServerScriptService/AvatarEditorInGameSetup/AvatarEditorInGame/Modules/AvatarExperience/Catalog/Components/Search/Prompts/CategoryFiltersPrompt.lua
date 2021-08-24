local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local t = require(Modules.Packages.t)

local withLocalization = require(Modules.Packages.Localization.withLocalization)

local FitFrame = require(Modules.Packages.FitFrame)
local FitFrameVertical = FitFrame.FitFrameVertical

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local GridView = UIBlox.App.Grid.GridView
local LargePill = UIBlox.App.Pill.LargePill

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SelectCategoryFilters = require(Modules.AvatarExperience.Catalog.Actions.SelectCategoryFilters)
local CatalogPrompt = require(Modules.AvatarExperience.Catalog.Components.Search.Prompts.CatalogPrompt)

local BUTTON_GRID_PADDING = 12
local BUTTON_GRID_MARGIN = 24

local CategoryFiltersPrompt = Roact.PureComponent:extend("CategoryFiltersPrompt")

function CategoryFiltersPrompt:init()
	self.state = {
		gridWidth = 0,
		filtersSelection = self.props.filtersSelection,
	}
end

CategoryFiltersPrompt.validateProps = t.strictInterface({
	onAcceptCallback = t.callback,
	filtersSelection = t.table,
	selectCategoryFilters = t.callback,
	containerWidth = t.number,
})

function CategoryFiltersPrompt:onCategoryPressed(categoryId)
	local isSelected = self.state.filtersSelection[categoryId]

	-- Multiple filter selection (Intended behavior, when the API is ready for it)
	-- self:setState({
	-- 	filtersSelection = Cryo.Dictionary.join(self.state.filtersSelection, {
	-- 		[categoryId] = not isSelected
	-- 	})
	-- })

	-- Single filter selection
	if isSelected then
		self:setState({filtersSelection = {}})
	else
		self:setState({filtersSelection = {[categoryId] = true}})
	end
end

function CategoryFiltersPrompt:onClearAllPressed()
	self:setState({filtersSelection = {}})
end

function CategoryFiltersPrompt:onButtonGridSizeChanged(size)
	local gridWidth = size.X
	if self.state.gridWidth ~= gridWidth then
		self:setState({
			gridWidth = gridWidth
		})
	end
end

function CategoryFiltersPrompt:onApplyClicked()
	self.props.selectCategoryFilters(self.state.filtersSelection)
	self.props.onAcceptCallback()
end

function CategoryFiltersPrompt.renderPill(item)
	return withLocalization({
		text = item.locale
	})(function(localized)
		return Roact.createElement(LargePill, {
			width = UDim.new(1, 0),
			text = localized.text,
			isSelected = item.isSelected,
			onActivated = item.onActivated,
		})
	end)
end

function CategoryFiltersPrompt:render()
	local items = {}
	local hasSelectedItem = false

	for i, category in pairs(CatalogConstants.Filters) do
		table.insert(items, {
			layoutOrder = i,
			locale = CatalogConstants.FilterLabels[category],
			isSelected = self.state.filtersSelection[category],
			onActivated = function() self:onCategoryPressed(category) end,
		})

		hasSelectedItem = hasSelectedItem or self.state.filtersSelection[category]
	end

	return withStyle(function(styles)
		return withLocalization({
			clearAll = "Feature.Catalog.Action.ClearAll",
			category = "Feature.Catalog.Label.Category",
		})(function(localized)
			local fontInfo = styles.Font
			local theme = styles.Theme

			local font = fontInfo.CaptionBody.Font
			local fontSize = fontInfo.BaseSize * fontInfo.CaptionBody.RelativeSize
			local textColor = hasSelectedItem and theme.TextEmphasis.Color or theme.TextMuted.Color
			local textTransparency = hasSelectedItem and theme.TextEmphasis.Transparency or theme.TextMuted.Transparency
			local pillSize = Vector2.new(math.max(self.state.gridWidth - BUTTON_GRID_PADDING, 0) / 2, 48)

			return Roact.createElement(CatalogPrompt, {
				title = localized.category,
				onApply = function() self:onApplyClicked() end,
			}, {
				ButtonGrid = Roact.createElement(FitFrameVertical, {
					width = UDim.new(1, 0),
					margin = FitFrame.Rect.quad(BUTTON_GRID_MARGIN, 0, BUTTON_GRID_MARGIN, 0),
					contentPadding = UDim.new(0, BUTTON_GRID_MARGIN),
					BackgroundTransparency = 1,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					[Roact.Change.AbsoluteSize] = self.onButtonGridSizeChanged,
				},{
					GridView = Roact.createElement(GridView, {
						renderItem = self.renderPill,
						itemPadding = Vector2.new(BUTTON_GRID_PADDING, BUTTON_GRID_PADDING),
						items = items,
						itemSize = pillSize,
						LayoutOrder = 1,
					}),
					ClearAll = Roact.createElement("TextButton", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundTransparency = 1,
						LayoutOrder = 3,
						Text = localized.clearAll,
						TextSize = fontSize,
						TextColor3 = textColor,
						TextTransparency = textTransparency,
						Font = font,
						[Roact.Event.Activated] = function()
							if hasSelectedItem then self:onClearAllPressed() end
						end,
					}),
				})
			})
		end)
	end)
end

CategoryFiltersPrompt = RoactRodux.UNSTABLE_connect2(
	function(state)
		return {
			filtersSelection = state.AvatarExperience.Catalog.SortAndFilters.CategoryFilters
		}
	end,
	function(dispatch)
		return {
			selectCategoryFilters = function(categories)
				dispatch(SelectCategoryFilters(categories))
			end,
		}
	end
)(CategoryFiltersPrompt)

return CategoryFiltersPrompt
