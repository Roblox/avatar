--[[
	A swatch shows a solid color on the left half and the same color with the opacity
	applied on the right. The transparent side has a checkered background. Use on the
	SwatchBar for saving and setting colors.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Swatch = {}

function Swatch.createComponentFrame(onActivated: () -> (), color: Color3, opacity: number?): ImageButton
	-- CanvasGroup rounds the corners and propogates the rounded corners to the children properly
	local canvas = Instance.new("CanvasGroup")
	StyleUtils.AddStyleTag(canvas, StyleConsts.tags.SwatchCanvas)

	local swatch = Instance.new("ImageButton")
	swatch.Name = "Swatch"
	swatch.Activated:Connect(onActivated)
	swatch.Parent = canvas
	StyleUtils.AddStyleTag(swatch, StyleConsts.tags.Swatch)

	local colorChild = Instance.new("Frame")
	colorChild.Name = "ColorSwatchHalf"
	colorChild.Parent = swatch
	colorChild.BackgroundColor3 = color

	local opacityChild = Instance.new("Frame")
	opacityChild.Name = "OpacitySwatchHalf"
	opacityChild.Parent = swatch
	opacityChild.BackgroundColor3 = color
	opacityChild.BackgroundTransparency = 1 - (opacity or 1)
	StyleUtils.AddStyleTag(opacityChild, StyleConsts.tags.SwatchOpacityHalf)

	return canvas
end

return Swatch
