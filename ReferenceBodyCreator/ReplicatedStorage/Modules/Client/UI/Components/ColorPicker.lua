--[[
	Creates a color picker, with a bar for selecting hue and a rectangular field
	for selecting saturation and value. Updates the color of the field and color
	markers dynamically. Used for painting and fill texture editing UIs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local ColorPickerInternal = {}
ColorPickerInternal.__index = ColorPickerInternal

local function makeHuePicker()
	-- This creates the slider for picking hue

	local huePicker = Instance.new("ImageButton")
	huePicker.Name = "HuePicker"
	Utils.AddStyleTag(huePicker, StyleConsts.tags.HuePicker)

	return huePicker
end

local function makeColorDot()
	local colorDot = Instance.new("Frame")
	colorDot.Name = "ColorDot"
	-- While some styling is done in the stylesheet, because the color picker is
	-- updating dynamically, we also do a lot of styling in functions.
	Utils.AddStyleTag(colorDot, StyleConsts.tags.ColorDot)

	return colorDot
end

function ColorPickerInternal:makeSatValPicker()
	-- This frame handles picking the saturation and value (brightness) of the color

	local satValPicker = Instance.new("ImageButton")
	satValPicker.Name = "SatValPicker"
	Utils.AddStyleTag(satValPicker, StyleConsts.tags.SatValPicker)
	-- Since choosing color updates the component, we handle that styling here.
	satValPicker.BackgroundColor3 = Color3.fromHSV(self.h, 1, 1)

	-- The gradients themselves are handled in the stylesheet
	local satGradientFrame = Instance.new("Frame")
	satGradientFrame.Name = "SatGradient"
	satGradientFrame.Parent = satValPicker
	Utils.AddStyleTag(satGradientFrame, StyleConsts.tags.SatGradient)

	local valGradientFrame = Instance.new("Frame")
	valGradientFrame.Name = "ValGradient"
	valGradientFrame.Parent = satValPicker
	Utils.AddStyleTag(valGradientFrame, StyleConsts.tags.ValGradient)

	return satValPicker
end

function ColorPickerInternal:SetSatVal(mousePositionScale: Vector2)
	self.s = mousePositionScale.X
	self.v = 1 - mousePositionScale.Y

	self.satValColorDot.BackgroundColor3 = self:GetColor()
	self.satValColorDot.Position = UDim2.fromScale(mousePositionScale.X, mousePositionScale.Y)
end

function ColorPickerInternal:HandleSatValInput(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseMovement and self.isSelectingSatVal ~= true then
		-- User is just moving mouse, hasn't clicked on the color picker
		return
	end

	if self.inputManager:TryGrabLock(self) == false then
		return
	end

	if Utils.isValidDraggingInput(input) then
		self.isSelectingSatVal = true
		self:SetSatVal(Utils.getMousePositionScaleOnComponent(self.satValPicker, input.Position))
		self.OnColorChangedCallback(self:GetColor(), false --[[isInputEnding]])
	end
end

function ColorPickerInternal:SetHue(mousePositionScale: Vector2)
	self.h = mousePositionScale.X
	local hueColor = Color3.fromHSV(self.h, 1, 1)

	-- Update UI components
	self.satValPicker.BackgroundColor3 = hueColor
	self.satValColorDot.BackgroundColor3 = self:GetColor()

	self.hueColorDot.BackgroundColor3 = hueColor
	self.hueColorDot.Position = UDim2.fromScale(self.h, 0.5)
end

function ColorPickerInternal:HandleHueInput(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseMovement and self.isSelectingHue ~= true then
		-- User is just moving mouse, hasn't clicked on the color picker
		return
	end

	if self.inputManager:TryGrabLock(self) == false then
		return
	end

	if Utils.isValidDraggingInput(input) then
		self.isSelectingHue = true
		self:SetHue(Utils.getMousePositionScaleOnComponent(self.huePicker, input.Position))
		self.OnColorChangedCallback(self:GetColor(), false --[[isInputEnding]])
	end
end

function ColorPickerInternal:HandleInputEnd(input: InputObject)
	-- Make sure the input that ended is relevant
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if self.inputManager:TryGrabLock(self) == false then
		return
	end

	if self.isSelectingHue then
		self:SetHue(Utils.getMousePositionScaleOnComponent(self.huePicker, input.Position))
		self.isSelectingHue = false
	elseif self.isSelectingSatVal then
		self:SetSatVal(Utils.getMousePositionScaleOnComponent(self.satValPicker, input.Position))
		self.isSelectingSatVal = false
	end

	self.OnColorChangedCallback(self:GetColor(), true --[[isInputEnding]])
end

function ColorPickerInternal:GetColor()
	return Color3.fromHSV(self.h, self.s, self.v)
end

function ColorPickerInternal.new(inputManager, colorPickerCallback)
	local self = {}
	setmetatable(self, ColorPickerInternal)

	-- Since this is a draggable component, an input manager is used to prevent
	-- input from affecting other components if the cursor leaves the component
	-- while dragging.
	self.inputManager = inputManager

	self.OnColorChangedCallback = colorPickerCallback

	self.isSelectingHue = false
	self.isSelectingSatVal = false

	self.h = Constants.DefaultColorPickerColor.h
	self.s = Constants.DefaultColorPickerColor.s
	self.v = Constants.DefaultColorPickerColor.v

	self.frame = Instance.new("Frame")
	self.frame.Name = "ColorPicker"
	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	Utils.AddStyleTag(self.frame, StyleConsts.tags.ColorPicker)

	-- Create the saturation/value picker UI
	self.satValPicker = self:makeSatValPicker()
	self.satValPicker.Parent = self.frame
	self.satValPicker.LayoutOrder = 1

	self.satValColorDot = makeColorDot()
	self.satValColorDot.Parent = self.satValPicker
	self.satValColorDot.Position = UDim2.fromScale(self.s, 1 - self.v)
	self.satValColorDot.BackgroundColor3 = self:GetColor()

	-- Connect input for sat/val
	self.satValPicker.InputBegan:Connect(function(input)
		self:HandleSatValInput(input)
	end)
	self.satValPicker.InputChanged:Connect(function(input)
		self:HandleSatValInput(input)
	end)
	self.satValPicker.InputEnded:Connect(function(input)
		self:HandleInputEnd(input)
	end)

	-- Create the hue picker UI
	self.huePicker = makeHuePicker()
	self.huePicker.Parent = self.frame
	self.huePicker.LayoutOrder = 2

	self.hueColorDot = makeColorDot()
	self.hueColorDot.Parent = self.huePicker
	self.hueColorDot.Position = UDim2.fromScale(self.h, 0.5)
	self.hueColorDot.BackgroundColor3 = Color3.fromHSV(self.h, 1, 1)

	-- Connect input for hue
	self.huePicker.InputBegan:Connect(function(input)
		self:HandleHueInput(input)
	end)
	self.huePicker.InputChanged:Connect(function(input)
		self:HandleHueInput(input)
	end)
	self.huePicker.InputEnded:Connect(function(input)
		self:HandleInputEnd(input)
	end)

	return self
end

local ColorPickerPublic = {}

function ColorPickerPublic.createComponentFrame(inputManager, colorPickerCallback)
	local colorPicker = ColorPickerInternal.new(inputManager, colorPickerCallback)

	return colorPicker.frame
end

return ColorPickerPublic
