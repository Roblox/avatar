local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local Images = UIBlox.App.ImageSet.Images
local UIBloxImageSetLabel = UIBlox.Core.ImageSet.Label

local function TouchFriendlyIconButton(props)
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local onActivated = props.onActivated
	local icon = props.icon
	local iconSize = props.iconSize
	local iconPosition = props.iconPosition or UDim2.new(0.5, 0, 0.5, 0)
	local iconAnchorPoint = props.iconAnchorPoint or Vector2.new(0.5, 0.5)
	local iconColor = props.iconColor
	local iconTransparency = props.iconTransparency
	local useUIBloxImageSet = props.useUIBloxImageSet
	local children = props[Roact.Children]

	local imageSetComponent = UIBloxImageSetLabel

	return Roact.createElement("TextButton", {
		Position = position,
		AnchorPoint = anchorPoint,
		Size = size,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Text = "",
		[Roact.Event.Activated] = onActivated,
	}, {
		NavigationButton = Roact.createElement(imageSetComponent, {
			Size = UDim2.new(0, iconSize, 0, iconSize),
			Position = iconPosition,
			AnchorPoint = iconAnchorPoint,
			Image = useUIBloxImageSet and Images[icon] or icon,
			ImageColor3 = iconColor,
			ImageTransparency = iconTransparency,
			BackgroundTransparency = 1,
		}, children),
	})
end

return TouchFriendlyIconButton