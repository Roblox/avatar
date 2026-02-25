local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)
local TextureScroller = require(Modules.NotLApp.TextureScroller)
local FFlagLuaAppShimmerOnChinaBuyButton = true

local DEFAULT_SHIMMER_SPEED = 2
local DEFAULT_SHIMMER_SCALE = 2

local SHIMMER_TRANSPARENCY = 0.65
local SHIMMER_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/shimmer.png"
local SHIMMER_ASPECT_RATIO = 219 / 250

local ShimmerAnimation = Roact.PureComponent:extend("ShimmerAnimation")

ShimmerAnimation.defaultProps = {
	shimmerSpeed = DEFAULT_SHIMMER_SPEED,
	shimmerScale = DEFAULT_SHIMMER_SCALE,
}

function ShimmerAnimation:render()
	local theme = self._context.AppTheme
	local size = self.props.Size
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local layoutOrder = self.props.LayoutOrder
	local shimmerScale = self.props.shimmerScale
	local shimmerImage = theme and theme.ShimmerAnimation.Image or SHIMMER_IMAGE
	local shimmerImageRatio = theme and theme.ShimmerAnimation.AspectRatio or SHIMMER_ASPECT_RATIO
	local shimmerImageTransparency = theme and theme.ShimmerAnimation.Transparency or SHIMMER_TRANSPARENCY

	if FFlagLuaAppShimmerOnChinaBuyButton then
		local themeSettings = self.props.themeSettings
		if themeSettings and themeSettings.ShimmerAnimation then
			shimmerImage = themeSettings.ShimmerAnimation.Image
			shimmerImageRatio = themeSettings.ShimmerAnimation.AspectRatio
			shimmerImageTransparency = themeSettings.ShimmerAnimation.Transparency
		end
	end

	local imageSize = UDim2.new(shimmerImageRatio * shimmerScale, 0, shimmerScale, 0)
	local shimmerSpeed = self.props.shimmerSpeed

	local repeatTime = 0
	if shimmerSpeed ~= 0 then
		repeatTime = (shimmerScale + 1) / shimmerSpeed
	end

	return Roact.createElement(TextureScroller, {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		LayoutOrder = layoutOrder,
		Image = shimmerImage,
		imageSize = imageSize,
		ImageTransparency = shimmerImageTransparency,
		imageAnchorPoint = Vector2.new(0, 0.5),
		imagePositionStart = UDim2.new(-shimmerScale, 0, 0.5, 0),
		imagePositionEnd = UDim2.new(1, 0, 0.5, 0),
		imageScrollCycleTime = repeatTime,
	})
end

return ShimmerAnimation