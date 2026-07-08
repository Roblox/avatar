--[[
	Creates a color picker, with a bar for selecting hue and a rectangular field
	for selecting saturation and value. Updates the color of the field and color
	markers dynamically. Used for painting and fill texture editing UIs.
]]

local GuiService = game:GetService("GuiService")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local ColorPickerInternal = {}
ColorPickerInternal.__index = ColorPickerInternal

function ColorPickerInternal:ConnectDragDetector(dragDetector: UIDragDetector, setPropertyCallback: (Vector2) -> nil)
	-- This connects a dragDetector to its parent and a property setting.

	local topLeftInset = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min

	dragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale

	assert(
		dragDetector.Parent and dragDetector.Parent:IsA("GuiObject"),
		"UI Drag Detector must be parented to a GuiObject"
	)

	dragDetector.DragStart:Connect(function(inputPos)
		setPropertyCallback(StyleUtils.GetMousePositionScaleOnComponent(dragDetector.Parent, inputPos + topLeftInset))
		self.OnColorChangedCallback(self:GetColor(), false --[[isInputEnding]])
	end)
	dragDetector.DragContinue:Connect(function(inputPos)
		setPropertyCallback(StyleUtils.GetMousePositionScaleOnComponent(dragDetector.Parent, inputPos + topLeftInset))
		self.OnColorChangedCallback(self:GetColor(), false --[[isInputEnding]])
	end)
	dragDetector.DragEnd:Connect(function(inputPos)
		setPropertyCallback(StyleUtils.GetMousePositionScaleOnComponent(dragDetector.Parent, inputPos + topLeftInset))
		self.OnColorChangedCallback(self:GetColor(), true --[[isInputEnding]])
	end)
end

function ColorPickerInternal:makeHuePicker()
	-- This creates the slider for picking hue

	local huePicker = Instance.new("Frame")
	huePicker.Name = "HuePicker"
	StyleUtils.AddStyleTag(huePicker, StyleConsts.tags.HuePicker)

	-- Add the ui drag detector for moving the color dot
	local dragDetector = Instance.new("UIDragDetector")
	dragDetector.Parent = huePicker

	self:ConnectDragDetector(dragDetector, function(scalePosition: Vector2)
		self:SetHue(scalePosition)
	end)

	return huePicker
end

local function makeColorDot()
	local colorDot = Instance.new("Frame")
	colorDot.Name = "ColorDot"
	-- While some styling is done in the stylesheet, because the color picker is
	-- updating dynamically, we also do a lot of styling in functions.
	StyleUtils.AddStyleTag(colorDot, StyleConsts.tags.ColorDot)

	return colorDot
end

local function makeOpacityDot()
	local colorDot = makeColorDot()
	colorDot.Name = "OpacityDot"
	return colorDot
end

function ColorPickerInternal:makeOpacitySlider()
	-- This creates the slider for picking opacity

	local opacityPicker = Instance.new("ImageLabel")
	opacityPicker.Name = "OpacityPicker"
	StyleUtils.AddStyleTag(opacityPicker, StyleConsts.tags.OpacityPicker)

	local opacityOverlay = Instance.new("Frame")
	opacityOverlay.Name = "OpacityOverlay"
	StyleUtils.AddStyleTag(opacityOverlay, StyleConsts.tags.OpacityOverlay)
	opacityOverlay.Parent = opacityPicker

	self.opacityGradient = Instance.new("UIGradient")
	self.opacityGradient.Name = "OpacityGradient"
	StyleUtils.AddStyleTag(self.opacityGradient, StyleConsts.tags.OpacityGradient)
	self.opacityGradient.Parent = opacityOverlay

	self.opacityDot = makeOpacityDot()
	self.opacityDot.Parent = opacityPicker
	self.opacityDot.Position = UDim2.fromScale(self.opacity, 0.5)
	self.opacityDot.BackgroundColor3 = self:GetColor()
	self:UpdateOpacityGradient()

	-- Add the ui drag detector for moving the color dot
	local dragDetector = Instance.new("UIDragDetector")
	dragDetector.Parent = opacityPicker

	self:ConnectDragDetector(dragDetector, function(scalePosition: Vector2)
		self:SetOpacity(scalePosition)
	end)

	return opacityPicker
end

function ColorPickerInternal:makeSatValPicker()
	-- This frame handles picking the saturation and value (brightness) of the color

	local satValPicker = Instance.new("Frame")
	satValPicker.Name = "SatValPicker"
	StyleUtils.AddStyleTag(satValPicker, StyleConsts.tags.SatValPicker)
	-- Since choosing color updates the component, we handle that styling here.
	satValPicker.BackgroundColor3 = Color3.fromHSV(self.h, 1, 1)

	-- The gradients themselves are handled in the stylesheet
	local satGradientFrame = Instance.new("Frame")
	satGradientFrame.Name = "SatGradient"
	satGradientFrame.Parent = satValPicker
	StyleUtils.AddStyleTag(satGradientFrame, StyleConsts.tags.SatGradient)

	local valGradientFrame = Instance.new("Frame")
	valGradientFrame.Name = "ValGradient"
	valGradientFrame.Parent = satValPicker
	StyleUtils.AddStyleTag(valGradientFrame, StyleConsts.tags.ValGradient)

	-- Add the ui drag detector for moving the color dot
	local dragDetector = Instance.new("UIDragDetector")
	dragDetector.Parent = satValPicker

	self:ConnectDragDetector(dragDetector, function(scaleInput: Vector2)
		self:SetSatVal(scaleInput)
	end)

	return satValPicker
end

function ColorPickerInternal:SetSatVal(mousePositionScale: Vector2)
	self.s = mousePositionScale.X
	self.v = 1 - mousePositionScale.Y

	self.satValColorDot.BackgroundColor3 = self:GetColor()
	self.satValColorDot.Position = UDim2.fromScale(mousePositionScale.X, mousePositionScale.Y)

	self:UpdateOpacityGradient()
end

function ColorPickerInternal:SetHue(mousePositionScale: Vector2)
	self.h = mousePositionScale.X
	local hueColor = Color3.fromHSV(self.h, 1, 1)

	-- Update UI components
	self.satValPicker.BackgroundColor3 = hueColor
	self.satValColorDot.BackgroundColor3 = self:GetColor()

	self.hueColorDot.BackgroundColor3 = hueColor
	self.hueColorDot.Position = UDim2.fromScale(self.h, 0.5)

	self:UpdateOpacityGradient()
end

function ColorPickerInternal:SetOpacity(mousePositionScale: Vector2)
	self.opacity = math.clamp(mousePositionScale.X, 0, 1)

	if self.opacityDot then
		self.opacityDot.Position = UDim2.fromScale(self.opacity, 0.5)
		self.opacityDot.BackgroundColor3 = self:GetColor()
		self.opacityDot.BackgroundTransparency = 1 - self.opacity
	end

	if self.OnOpacityChangedCallback then
		self.OnOpacityChangedCallback(self.opacity)
	end
end

function ColorPickerInternal:GetColor()
	return Color3.fromHSV(self.h, self.s, self.v)
end

function ColorPickerInternal:GetOpacity()
	return self.opacity
end

function ColorPickerInternal:UpdateOpacityGradient()
	if not self.opacityGradient then
		return
	end

	local color = self:GetColor()

	-- Same color across the bar and fade from opaque (0) to fully transparent (1)
	self.opacityGradient.Color = ColorSequence.new(color)

	if self.opacityDot then
		self.opacityDot.BackgroundColor3 = color
		self.opacityDot.BackgroundTransparency = 1 - self.opacity
	end
end

function ColorPickerInternal.new(colorPickerCallback, opacityPickerCallback)
	local self = {}
	setmetatable(self, ColorPickerInternal)

	self.OnColorChangedCallback = colorPickerCallback
	self.OnOpacityChangedCallback = opacityPickerCallback

	self.h = StyleConsts.DefaultColorPickerColor.h
	self.s = StyleConsts.DefaultColorPickerColor.s
	self.v = StyleConsts.DefaultColorPickerColor.v
	self.opacity = 1

	self.frame = Instance.new("Frame")
	self.frame.Name = "ColorPicker"
	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.ColorPicker)

	-- Create the saturation/value picker UI
	self.satValPicker = self:makeSatValPicker()
	self.satValPicker.Parent = self.frame
	self.satValPicker.LayoutOrder = 1

	self.satValColorDot = makeColorDot()
	self.satValColorDot.Parent = self.satValPicker
	self.satValColorDot.Position = UDim2.fromScale(self.s, 1 - self.v)
	self.satValColorDot.BackgroundColor3 = self:GetColor()

	-- Create the hue picker UI
	self.huePicker = self:makeHuePicker()
	self.huePicker.Parent = self.frame
	self.huePicker.LayoutOrder = 2

	self.hueColorDot = makeColorDot()
	self.hueColorDot.Parent = self.huePicker
	self.hueColorDot.Position = UDim2.fromScale(self.h, 0.5)
	self.hueColorDot.BackgroundColor3 = Color3.fromHSV(self.h, 1, 1)

	-- Create opacity picker UI
	self.opacityPicker = self:makeOpacitySlider()
	self.opacityPicker.Parent = self.frame
	self.opacityPicker.LayoutOrder = 3

	return self
end

local ColorPickerPublic = {}

function ColorPickerPublic.createComponentFrame(colorPickerCallback, opacityPickerCallback)
	local colorPicker = ColorPickerInternal.new(colorPickerCallback, opacityPickerCallback)

	return colorPicker.frame
end

return ColorPickerPublic
