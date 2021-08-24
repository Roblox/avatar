local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local LocalizedTextBox = require(Modules.NotLApp.LocalizedTextBox)
local LocalizedTextButton = require(Modules.NotLApp.LocalizedTextButton)

local ImageSetLabel = UIBlox.Core.ImageSet.Label
local ImageSetButton = UIBlox.Core.ImageSet.Button
local Images = UIBlox.App.ImageSet.Images

local SEARCH_BAR_HEIGHT = 28
local SEARCH_BAR_PADDING = 12
local SEARCH_BAR_TEXT_SIZE = 20
local SEARCH_BAR_ICON_PADDING = 9
local SEARCH_BAR_TEXT_PADDING_WITH_ICON = 36
local SEARCH_BAR_TEXT_PADDING_WITHOUT_ICON = 12
local CLEAR_IMAGE_SIZE = 16
local CLEAR_IMAGE_PADDING = 6
local CLEAR_BUTTON_SIZE = CLEAR_IMAGE_PADDING*2 + CLEAR_IMAGE_SIZE
local CANCEL_BUTTON_WIDTH = 88

local SEARCH_FRAME_IMAGE = {
	Image = Images["component_assets/circle_17"],
	SliceCenter = Rect.new(8, 8, 9, 9),
}
local SEARCH_BAR_ICON  = Images["icons/common/search"]
local CLEAR_BUTTON_IMAGE = Images["icons/actions/edit/clear"]

local SearchBar = Roact.PureComponent:extend("SearchBar")

SearchBar.defaultProps = {
	Size = UDim2.new(1, 0, 1, 0),
}

function SearchBar:init()
	self.state = {
		clearButtonVisible = false
	}
	self.searchBoxRef = Roact.createRef()
	self.searchBoxTextChangedConn = nil

	self.onFocused = function()
		if self.props.onFocused then
			self.props.onFocused()
		end
		if self.searchBoxRef.current and not self.searchBoxTextChangedConn then
			self.searchBoxTextChangedConn = self.searchBoxRef.current:GetPropertyChangedSignal("Text"):Connect(function()
				if self.searchBoxRef.current then
					local clearButtonVisible = self.searchBoxRef.current.Text ~= ""
					if clearButtonVisible ~= self.state.clearButtonVisible then
						self:setState({
							clearButtonVisible = clearButtonVisible
						})
					end
				end
			end)
		end
	end

	self.onFocusLost = function(rbx, enterPressed, inputObject)
		local cancelSearch = self.props.cancelSearch

		if enterPressed then
			self.props.confirmSearch(rbx.Text)

		-- On Android, if user press the native back button, we want to cancel
		-- our current search. When this happens, inputObject is nil.
		elseif inputObject == nil then
			cancelSearch()
		end
	end

	self.onCancelButtonActivated = self.props.cancelSearch

	self.onClearText = function()
		if self.searchBoxRef.current then
			self.searchBoxRef.current.Text = ""
			self.searchBoxRef.current:captureFocus()
		end
	end
end

function SearchBar:didMount()
	if self.props.isPhone and self.searchBoxRef.current then
		self.searchBoxRef.current:captureFocus()
	end
end

function SearchBar:render()
	local size = self.props.Size
	local isPhone = self.props.isPhone
	local clearButtonVisible = self.state.clearButtonVisible
	local searchTextOffset = isPhone and SEARCH_BAR_TEXT_PADDING_WITHOUT_ICON or SEARCH_BAR_TEXT_PADDING_WITH_ICON
	local searchBoxMargin = clearButtonVisible and searchTextOffset + CLEAR_BUTTON_SIZE or searchTextOffset

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = size,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		},{
			Layout = isPhone and Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			SearchBoxBackground = Roact.createElement(ImageSetLabel,{
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(1, isPhone and -SEARCH_BAR_PADDING - CANCEL_BUTTON_WIDTH or 0, 0, SEARCH_BAR_HEIGHT),
				Position = UDim2.new(0, 0, 0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = SEARCH_FRAME_IMAGE.Image,
				ImageColor3 = style.Theme.UIMuted.Color,
				ImageTransparency = style.Theme.UIMuted.Transparency,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = SEARCH_FRAME_IMAGE.SliceCenter,
				LayoutOrder = 1,
			},{
				SearchIcon = not isPhone and Roact.createElement(ImageSetLabel,{
					Size = UDim2.new(0, SEARCH_BAR_TEXT_SIZE, 0, SEARCH_BAR_TEXT_SIZE),
					Position = UDim2.new(0, SEARCH_BAR_ICON_PADDING, 0.5, 0),
					Image = SEARCH_BAR_ICON,
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 0.5),
					ImageColor3 = style.Theme.SystemPrimaryDefault.Color,
					ImageTransparency = style.Theme.SystemPrimaryDefault.Transparency,
				}),
				SearchBox = Roact.createElement(LocalizedTextBox, {
					Size = UDim2.new(1, -searchBoxMargin, 1, 0),
					Position = UDim2.new(0, searchTextOffset, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = self.props.initialSearchText or "",
					Font = style.Font.Body.Font,
					TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
					TextColor3 = style.Theme.TextDefault.Color,
					TextTransparency = style.Theme.TextDefault.Transparency,
					TextWrapped = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClipsDescendants = true,
					PlaceholderText = self.props.placeholderText,
					PlaceholderColor3 = style.Theme.TextDefault.Color,
					--OverlayNativeInput = true,
					ClearTextOnFocus = false,
					LayoutOrder = 1,
					[Roact.Ref] = self.searchBoxRef,
					[Roact.Event.FocusLost] = self.onFocusLost,
					[Roact.Event.Focused] = self.onFocused,
				}),
				ClearButton = Roact.createElement(ImageSetButton, {
					AnchorPoint = Vector2.new(1, 0.5),
					Size = UDim2.new(0, CLEAR_BUTTON_SIZE, 1, 0),
					Position = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Visible = clearButtonVisible,
					[Roact.Event.Activated] = self.onClearText,
				}, {
					ClearImage = Roact.createElement(ImageSetLabel, {
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, CLEAR_IMAGE_SIZE, 0, CLEAR_IMAGE_SIZE),
						Position = UDim2.new(1, -CLEAR_IMAGE_PADDING, 0.5, 0),
						Image = CLEAR_BUTTON_IMAGE,
						ImageColor3 = style.Theme.SystemPrimaryDefault.Color,
						ImageTransparency = style.Theme.SystemPrimaryDefault.Transparency,
						BackgroundTransparency = 1,
					}),
				}),
			}),
			CancelButton = isPhone and Roact.createElement(LocalizedTextButton, {
				Size = UDim2.new(0, CANCEL_BUTTON_WIDTH, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "Feature.GamePage.LabelCancelField",
				Font = style.Font.Body.Font,
				TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
				TextColor3 = style.Theme.SystemPrimaryDefault.Color,
				TextTransparency = style.Theme.SystemPrimaryDefault.Transparency,
				LayoutOrder = 2,
				[Roact.Event.Activated] = self.onCancelButtonActivated,
			}),
		})

	end)

end

return SearchBar
