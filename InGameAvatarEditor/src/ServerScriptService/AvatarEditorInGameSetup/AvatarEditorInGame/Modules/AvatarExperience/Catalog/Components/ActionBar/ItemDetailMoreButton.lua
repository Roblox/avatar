local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules


local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local ImageSetButton = UIBlox.Core.ImageSet.Button
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local Images = UIBlox.App.ImageSet.Images

local BUTTON_SIZE = UDim2.new(0, 44, 0, 44)
local BUTTON_ICON_IMAGE = Images["icons/common/more"]
local BUTTON_ICON_SIZE = UDim2.new(0, 37, 0, 37)
local BUTTON_FILL_9S_IMAGE = Images["component_assets/circle_17"]
local BUTTON_FILL_9S_CENTER = Rect.new(8, 8, 9, 9)

local ItemDetailMoreButton = Roact.PureComponent:extend("ItemDetailMoreButton")

function ItemDetailMoreButton:init()
	self.state = {
		isButtonPressed = false,
	}

	self.onInputBegan = function()
		self:setState({
			isButtonPressed = true
		})
	end

	self.onInputEnded = function()
		self:setState({
			isButtonPressed = false
		})
	end

	self.moreButtonRef = Roact.createRef()
end

function ItemDetailMoreButton:renderWithStyle(stylePalette)
	local theme = stylePalette.Theme
	local onActivated = self.props.onActivated
	local isButtonPressed = self.state.isButtonPressed
	local buttonTransparency = theme.BackgroundDefault.Transparency
	if isButtonPressed then
		buttonTransparency = theme.Overlay.Transparency
	end
	return Roact.createElement(ImageSetButton, {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = BUTTON_SIZE,
		Image = BUTTON_FILL_9S_IMAGE,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = BUTTON_FILL_9S_CENTER,
		ImageTransparency = buttonTransparency,
		ImageColor3 = theme.BackgroundDefault.Color,
		LayoutOrder = 1,
		ClipsDescendants = false,
		[Roact.Event.Activated] = onActivated,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		[Roact.Ref] = self.moreButtonRef,
	}, {
		Icon = Roact.createElement(ImageSetLabel, {
			Size = BUTTON_ICON_SIZE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = BUTTON_ICON_IMAGE,
			ImageTransparency = theme.IconEmphasis.Transparency,
			ImageColor3 =  theme.IconEmphasis.Color,
		}),
	})
end

function ItemDetailMoreButton:willUnmount()
	if true and self.props.onUnmount ~= nil then
		self.props.onUnmount()
	end
end

function ItemDetailMoreButton:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

return ItemDetailMoreButton
