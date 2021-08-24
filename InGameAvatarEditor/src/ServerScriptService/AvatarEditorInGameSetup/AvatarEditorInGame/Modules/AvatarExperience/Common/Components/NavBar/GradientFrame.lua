local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local withStyle = UIBlox.Style.withStyle

local GRADIENT_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/gradient_0_100.png"
local GRADIENT_SIZE = 50

local GradientFrame = Roact.PureComponent:extend("GradientFrame")

function GradientFrame:render()
	local gradientStyle = self.props.gradientStyle
	local navHeight = self.props.navHeight
	local ZIndex = self.props.ZIndex

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local gradientColor = gradientStyle and gradientStyle.Color or theme.BackgroundDefault.Color
		local gradientTransparency = gradientStyle and gradientStyle.Transparency or theme.BackgroundDefault.Transparency

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = ZIndex,

			[Roact.Ref] = self.props.ref,
		}, {
			Left = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, GRADIENT_SIZE, 0, navHeight),
			}, {
				Image = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, navHeight, 0, GRADIENT_SIZE),
					Rotation = 90,
					Image = GRADIENT_IMAGE,
					ImageColor3 = gradientColor,
					ImageTransparency = gradientTransparency,
				}),
			}),

			Right = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, GRADIENT_SIZE, 0, navHeight),
			}, {
				Image = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, navHeight, 0, GRADIENT_SIZE),
					Rotation = -90,
					Image = GRADIENT_IMAGE,
					ImageColor3 = gradientColor,
					ImageTransparency = gradientTransparency,
				}),
			}),
		})
	end)
end

return GradientFrame