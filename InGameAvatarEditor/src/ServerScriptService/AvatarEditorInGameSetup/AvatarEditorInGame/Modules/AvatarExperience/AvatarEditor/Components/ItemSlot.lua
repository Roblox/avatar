local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)

local UIBlox = require(Modules.Packages.UIBlox)
local LoadableImage = UIBlox.Loading.LoadableImage

local withStyle = UIBlox.Style.withStyle

local BACKGROUND_IMAGE = "http://www.roblox.com/asset/?id=7264431979"
local DOTTED_BORDER_IMAGE = "http://www.roblox.com/asset/?id=7264433887"
local SELECTED_BORDER_IMAGE = "http://www.roblox.com/asset/?id=7264435213"

local THUMBNAIL_PADDING = 4

local ItemSlot = Roact.PureComponent:extend("ItemSlot")

function ItemSlot:render()
	local slotNumber = self.props.slotNumber
	local thumbnailUrl = self.props.thumbnailUrl
	local isSelected = self.props.isSelected
	local onActivate = self.props.onActivate
	local layoutOrder = self.props.LayoutOrder

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font

		local backgroundColor
		local backgroundTransparency
		local borderImage
		local borderSliceType
		local numberColor
		local numberTransparency

		if isSelected then
			backgroundColor = theme.BackgroundUIDefault.Color
			backgroundTransparency = theme.BackgroundUIDefault.Transparency
			borderImage = SELECTED_BORDER_IMAGE
			borderSliceType = Enum.ScaleType.Slice
			numberColor = theme.TextEmphasis.Color
			numberTransparency = theme.TextEmphasis.Transparency
		else
			if thumbnailUrl then
				backgroundColor = theme.BackgroundUIDefault.Color
				backgroundTransparency = theme.BackgroundUIDefault.Transparency
			else
				backgroundColor = theme.BackgroundUIContrast.Color
				backgroundTransparency = theme.BackgroundUIContrast.Transparency
			end
			borderImage = DOTTED_BORDER_IMAGE
			borderSliceType = Enum.ScaleType.Stretch
			numberColor = theme.TextDefault.Color
			numberTransparency = theme.TextDefault.Transparency
		end

		local content

		if thumbnailUrl then
			content = Roact.createElement(LoadableImage, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = thumbnailUrl,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -THUMBNAIL_PADDING, 1, -THUMBNAIL_PADDING),
				useShimmerAnimationWhileLoading = true,
			})
		else
			content = Roact.createElement("TextLabel", {
				Text = tostring(slotNumber),
				Font = font.SubHeader1.Font,
				TextSize = font.SubHeader1.RelativeSize * font.BaseSize,
				TextColor3 = numberColor,
				TextTransparency = numberTransparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
			})
		end

		return Roact.createElement("ImageButton", {
			Image = BACKGROUND_IMAGE,
			ImageColor3 = backgroundColor,
			ImageTransparency = backgroundTransparency,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(6, 6, 13, 13),
			LayoutOrder = layoutOrder,

			[Roact.Event.Activated] = function(rbx)
				onActivate(slotNumber)
			end,
		}, {
			AEBorder = Roact.createElement("ImageLabel", {
				Image = borderImage,
				ImageColor3 = numberColor,
				ImageTransparency = numberTransparency,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				ScaleType = borderSliceType,
				SliceCenter = isSelected and Rect.new(9, 9, 10, 10) or nil,
			}, {
				Content = content,
			}),
		})
	end)
end

return ItemSlot
