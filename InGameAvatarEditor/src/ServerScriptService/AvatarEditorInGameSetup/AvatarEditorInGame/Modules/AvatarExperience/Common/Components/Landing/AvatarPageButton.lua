local Players = game:GetService("Players")
local NotificationService = game:GetService("NotificationService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)

local PageButton = require(Modules.AvatarExperience.Common.Components.Landing.PageButton)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local AVATAR_THUMBNAIL_TYPE = CatalogConstants.ThumbnailType.Avatar
local AVATAR_THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["720"]

local CUSTOMIZE_ICON = "icons/menu/customize_large"

local DARK_BACKGROUND = "rbxasset://textures/AvatarEditorImages/AvatarEditor.png"
local LIGHT_BACKGROUND = "rbxasset://textures/AvatarEditorImages/AvatarEditor_LightTheme.png"

local IMAGE_WIDTH_OFFSET = -0.05
local IMAGE_HEIGHT_OFFSET = 0.05

local AvatarPageButton = Roact.PureComponent:extend("AvatarPageButton")

AvatarPageButton.defaultProps = {
	transparencyModifier = 0,
}

function AvatarPageButton:init()
	self.state = {
		style = "dark",
	}
end

function AvatarPageButton:render()
	local localUserId = self.props.localUserId
	local style = self.state.style
	local transparencyModifier = self.props.transparencyModifier

	local backgroundImage = LIGHT_BACKGROUND
	if style == "dark" then
		backgroundImage = DARK_BACKGROUND
	end

	local avatarThumbnail = CatalogUtils.MakeRbxThumbUrl(AVATAR_THUMBNAIL_TYPE, localUserId,
		AVATAR_THUMBNAIL_SIZE, AVATAR_THUMBNAIL_SIZE)

	return withLocalization({
		avatarEditorText = "Feature.Catalog.Action.Customize",
	})(function(localized)
		return Roact.createElement(PageButton, {
			Size = UDim2.new(1, 0, 1, 0),

			backgroundImage = backgroundImage,
			icon = CUSTOMIZE_ICON,
			text = localized.avatarEditorText,
			transparencyModifier = transparencyModifier,

			onActivated = self.props.onActivated,
		}, {
			ThumbnailFrame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(2.8, 0, 2.8, 0),
			}, {
				AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.FitWithinMaxSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),

				Image = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(IMAGE_WIDTH_OFFSET, 0, IMAGE_HEIGHT_OFFSET, 0),
					Image = avatarThumbnail,
					ImageTransparency = transparencyModifier,
					Size = UDim2.new(1, 0, 1, 0),
					ImageRectOffset = Vector2.new(AVATAR_THUMBNAIL_SIZE, 0),
					ImageRectSize = Vector2.new(-AVATAR_THUMBNAIL_SIZE, AVATAR_THUMBNAIL_SIZE),
				}),
			}),
		})
	end)
end

function AvatarPageButton:didMount()
	--[[
	self.themeChangedConn = NotificationService:GetPropertyChangedSignal("SelectedTheme"):Connect(function()
		self:setState({
			style = string.lower(NotificationService.SelectedTheme),
		})
	end)
	]]
end

function AvatarPageButton:willUnmount()
	if self.themeChangedConn then
		self.themeChangedConn:Disconnect()
		self.themeChangedConn = nil
	end
end

local function mapStateToProps(state)
	return {
		localUserId = state.LocalUserId,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(AvatarPageButton)