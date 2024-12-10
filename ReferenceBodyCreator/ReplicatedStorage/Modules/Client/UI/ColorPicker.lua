local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utils = require(Modules:WaitForChild("Utils"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local UIUtils = require(UI:WaitForChild("UIUtils"))
local UIConstants = require(UI:WaitForChild("UIConstants"))

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local SAT_VALUE_RADIUS = 70
local NUM_SWATCH_PER_ROW = 6
local HUE_RING_INNER_RADIUS = 76
local HUE_RING_OUTER_RADIUS = 100
local SWATCH_SIZE = 24
local HUE_RING_AVERAGE_RADIUS = (HUE_RING_INNER_RADIUS + HUE_RING_OUTER_RADIUS) / 2
local CORNER_RADIUS = 10
local PADDING = 16
local CELL_PADDING = 8
local BLANK_COLOR = Color3.new(0.4, 0.4, 0.4)
local HUE_RING_SELECTOR_SIZE = HUE_RING_OUTER_RADIUS - HUE_RING_INNER_RADIUS
local SELECTOR_BORDER_OFFSET = 2
local SATURATION_SELECTOR_SIZE = 34
local SAT_VALUE_START_POS = UDim2.fromOffset(50, 50)

local MAX_COLOR_HISTORY = 12

local DEFAULT_COLOR_HISTORY = {
	Color3.fromHex("3A6C46"),
	Color3.fromHex("3A6B6D"),
	Color3.fromHex("304A6C"),
	Color3.fromHex("2F2769"),
	Color3.fromHex("50296A"),
	Color3.fromHex("662B38"),
	Color3.fromHex("D8D8D8"),
	Color3.fromHex("000000"),
	UIConstants.FGColor,
	UIConstants.FGColor,
	UIConstants.FGColor,
	UIConstants.FGColor,
}

function ColorPicker.new()
	local self = {}
	setmetatable(self, ColorPicker)

	self.currentHue = 0
	self.currentSaturation = 1
	self.currentValue = 1
	self.currentColor = Color3.new(1, 1, 1)
	self.previouslyUsedColors = {}
	self.currentColorIndex = -1 -- Used for adding colors to the "previously used colors" list.
	self.isSelectingColor = false

	local Frame = Instance.new("Frame")
	Frame.AutomaticSize = Enum.AutomaticSize.XY
	Frame.BackgroundColor3 = UIConstants.BGColor
	Frame.Name = "ColorPicker"
	self.Frame = Frame

	UIUtils.AddUICorner(Frame, CORNER_RADIUS)

	local HSVSelector = Instance.new("Frame")
	HSVSelector.AutomaticSize = Enum.AutomaticSize.XY
	HSVSelector.BackgroundColor3 = UIConstants.BGColor
	HSVSelector.Name = "HSVSelector"
	HSVSelector.Parent = Frame
	UIUtils.AddUICorner(HSVSelector, UIConstants.PanelCornerRadius)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, PADDING)
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = Frame

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0, PADDING)
	UIPadding.PaddingRight = UDim.new(0, PADDING)
	UIPadding.PaddingLeft = UDim.new(0, PADDING)
	UIPadding.PaddingBottom = UDim.new(0, PADDING)
	UIPadding.Parent = Frame

	local SaturationValueCircle = Instance.new("ImageLabel")
	SaturationValueCircle.Name = "SaturationValueCircle"
	SaturationValueCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	SaturationValueCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	SaturationValueCircle.BackgroundTransparency = 1
	SaturationValueCircle.Size = UDim2.fromOffset(SAT_VALUE_RADIUS * 2, SAT_VALUE_RADIUS * 2)
	SaturationValueCircle.Parent = HSVSelector
	SaturationValueCircle.ZIndex = 2

	self.editableTextureSVcircle = AssetService:CreateEditableImage({
		Size = SaturationValueCircle.AbsoluteSize,
	})
	self:RegenerateSaturationValueCircleTexture()
	SaturationValueCircle.ImageContent = Content.fromObject(self.editableTextureSVcircle)

	local SatValueSelector = Instance.new("Frame")
	SatValueSelector.Name = "SatValueSelector"
	SatValueSelector.Position = SAT_VALUE_START_POS
	SatValueSelector.Size = UDim2.fromOffset(SATURATION_SELECTOR_SIZE, SATURATION_SELECTOR_SIZE)
	SatValueSelector.ZIndex = 2
	SatValueSelector.Parent = SaturationValueCircle
	SatValueSelector.AnchorPoint = Vector2.new(0.5, 0.5)
	SatValueSelector.BorderSizePixel = 0

	UIUtils.AddUICorner(SatValueSelector, 0, 0.5)

	self.SatValueSelector = SatValueSelector

	local SatValueSelectorBg = Instance.new("Frame")
	SatValueSelectorBg.Name = "SatValueSelector"
	SatValueSelectorBg.Position = SAT_VALUE_START_POS
	SatValueSelectorBg.Size = UDim2.fromOffset(
		SATURATION_SELECTOR_SIZE + SELECTOR_BORDER_OFFSET,
		SATURATION_SELECTOR_SIZE + SELECTOR_BORDER_OFFSET
	)
	SatValueSelectorBg.ZIndex = 1
	SatValueSelectorBg.BackgroundColor3 = Color3.new(1, 1, 1)
	SatValueSelectorBg.Parent = SaturationValueCircle
	SatValueSelectorBg.AnchorPoint = Vector2.new(0.5, 0.5)
	SatValueSelectorBg.BorderSizePixel = 0

	UIUtils.AddUICorner(SatValueSelectorBg, 0, 0.5)
	self.SatValueSelectorBg = SatValueSelectorBg

	local HueRingContainer = Instance.new("Frame")
	HueRingContainer.BackgroundTransparency = 1
	HueRingContainer.Size = UDim2.fromOffset(HUE_RING_OUTER_RADIUS * 2, HUE_RING_OUTER_RADIUS * 2)
	HueRingContainer.Name = "HueRingContainer"
	HueRingContainer.Parent = HSVSelector
	HueRingContainer.LayoutOrder = 1

	local HueRing = Instance.new("ImageButton")
	HueRing.Name = "HueRing"
	HueRing.AnchorPoint = Vector2.new(0.5, 0.5)
	HueRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	HueRing.Size = UDim2.fromOffset(HUE_RING_OUTER_RADIUS * 2, HUE_RING_OUTER_RADIUS * 2)
	HueRing.BackgroundTransparency = 1
	HueRing.Parent = HueRingContainer

	self.PickerCenterPos = HueRing.AbsoluteSize / 2

	local function HandleInput(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self.isSelectingColor ~= true then
			return
		elseif
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseMovement
		then
			self.isSelectingColor = true

			-- Did the user click the hue ring or the saturation/value selector?
			local clickedPos = Vector2.new(input.Position.X, input.Position.Y) - HueRing.AbsolutePosition
			local centerPos = HueRing.AbsoluteSize / 2
			local fromCenter = clickedPos - centerPos
			local sweepAngle = math.deg(math.asin(fromCenter.Y / fromCenter.Magnitude))

			if input.UserInputState == Enum.UserInputState.Begin then
				self.isSelectingInnerRing = fromCenter.Magnitude < HUE_RING_INNER_RADIUS
			end

			if self.isSelectingInnerRing then
				-- User clicked the inner saturation/value circle.
				local width = SaturationValueCircle.AbsoluteSize.X
				local height = SaturationValueCircle.AbsoluteSize.Y
				local x = input.Position.X - SaturationValueCircle.AbsolutePosition.X
				local y = input.Position.Y - SaturationValueCircle.AbsolutePosition.Y
				local size = SaturationValueCircle.AbsoluteSize
				local distanceFromCenter = math.sqrt(math.pow(x - size.X / 2, 2) + math.pow(y - size.Y / 2, 2))
				if distanceFromCenter <= size.X / 2 then
					-- Map to -1, 1
					local normalizedX = (x / width) * 2 - 1
					local normalizedY = (y / height) * 2 - 1

					local squareX, squareY = self:MapCirclePointToSquare(normalizedX, normalizedY)
					squareX = ((squareX + 1) / 2) * width
					squareY = ((squareY + 1) / 2) * width

					-- Get saturation/value from point on square
					local saturation = squareX / width
					local value = 1 - squareY / height

					-- Clamp the selector position to the radius of the sat/value circle.
					local selectorPos = Vector2.new(x, y)
					if distanceFromCenter > SAT_VALUE_RADIUS then
						selectorPos = (fromCenter.Unit * SAT_VALUE_RADIUS) + centerPos
					end
					self.SatValueSelector.Position = UDim2.fromOffset(selectorPos.X, selectorPos.Y)
					self.SatValueSelectorBg.Position = UDim2.fromOffset(selectorPos.X, selectorPos.Y)
					self.currentSaturation = saturation
					self.currentValue = value
					self:OnChangedSaturationValue()
				end
			else
				-- User clicked the hue ring
				-- Position the selector along the outer edge
				if fromCenter.X <= 0 then
					sweepAngle = 180 - sweepAngle
				elseif fromCenter.X >= 0 and fromCenter.Y <= 0 then
					sweepAngle = 360 + sweepAngle
				end

				self.currentHue = sweepAngle / 360
				local vectorPos = (fromCenter.Unit * HUE_RING_AVERAGE_RADIUS) + centerPos
				self.HueRingSelector.Position = UDim2.fromOffset(vectorPos.X, vectorPos.Y)
				self.HueRingSelectorBg.Position = UDim2.fromOffset(vectorPos.X, vectorPos.Y)
				self:OnChangedHue()
			end
		end
	end

	local function HandleInputEnd(input)
		if self.isSelectingColor then
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			if self.OnColorChangedCallback then
				self.OnColorChangedCallback(self.currentColor, true --[[isInputEnding]])
			end

			self.isSelectingColor = false
			self.isSelectingInnerRing = false
		end
	end

	HueRing.InputBegan:Connect(HandleInput)
	HueRing.InputChanged:Connect(HandleInput)
	HueRing.InputEnded:Connect(HandleInputEnd)

	self.editableTextureHueRing = self:GenerateHueRing(HueRing.AbsoluteSize)
	HueRing.ImageContent = Content.fromObject(self.editableTextureHueRing)

	local HueRingSelector = Instance.new("ImageLabel")
	HueRingSelector.Name = "HueRingSelector"
	HueRingSelector.Position = UDim2.fromOffset(50, 10)
	HueRingSelector.Size = UDim2.fromOffset(HUE_RING_SELECTOR_SIZE, HUE_RING_SELECTOR_SIZE)
	HueRingSelector.Parent = HueRing
	HueRingSelector.ZIndex = 2
	HueRingSelector.AnchorPoint = Vector2.new(0.5, 0.5)
	HueRingSelector.BorderSizePixel = 0
	self.HueRingSelector = HueRingSelector

	UIUtils.AddUICorner(HueRingSelector, 0, 0.5)

	local HueRingSelectorBg = Instance.new("ImageLabel")
	HueRingSelectorBg.Name = "HueRingSelectorBg"
	HueRingSelectorBg.Position = UDim2.fromOffset(50, 10)
	HueRingSelectorBg.Size = UDim2.fromOffset(
		HUE_RING_SELECTOR_SIZE + SELECTOR_BORDER_OFFSET,
		HUE_RING_SELECTOR_SIZE + SELECTOR_BORDER_OFFSET
	)
	HueRingSelectorBg.Parent = HueRing
	HueRingSelectorBg.ZIndex = 1
	HueRingSelectorBg.AnchorPoint = Vector2.new(0.5, 0.5)
	HueRingSelectorBg.BorderSizePixel = 0
	HueRingSelectorBg.BackgroundColor3 = Color3.new(1, 1, 1)
	self.HueRingSelectorBg = HueRingSelectorBg

	UIUtils.AddUICorner(HueRingSelectorBg, 0, 0.5)

	local SwatchList = Instance.new("Frame")
	SwatchList.Name = "SwatchList"
	SwatchList.AutomaticSize = Enum.AutomaticSize.Y
	-- TODO check SwatchList.Size = UDim2.fromOffset(HUE_RING_OUTER_RADIUS * 2, 80)
	SwatchList.Size = UDim2.fromOffset(HUE_RING_OUTER_RADIUS * 2, 0)
	SwatchList.BackgroundColor3 = UIConstants.BGColor
	SwatchList.BackgroundTransparency = 1
	SwatchList.LayoutOrder = 3
	SwatchList.Parent = Frame
	self.PreviousColorsFrame = SwatchList

	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellSize = UDim2.fromOffset(SWATCH_SIZE, SWATCH_SIZE)
	GridLayout.CellPadding = UDim2.fromOffset(CELL_PADDING, CELL_PADDING)
	GridLayout.Parent = SwatchList
	GridLayout.FillDirectionMaxCells = NUM_SWATCH_PER_ROW
	GridLayout.FillDirection = Enum.FillDirection.Horizontal
	GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Create list of previously used colors
	for i = 1, MAX_COLOR_HISTORY do
		local colorButton = Instance.new("ImageButton")
		colorButton.Name = "ColorButton" .. i
		colorButton.BackgroundColor3 = UIConstants.FGColor
		colorButton.BackgroundTransparency = 0
		colorButton.LayoutOrder = i
		colorButton.Parent = SwatchList

		UIUtils.AddUICorner(colorButton, 0, 0.5)

		colorButton.Activated:Connect(function()
			self:OnSwatchClicked(i)
		end)
	end

	self:OnChangedHue()
	self:OnChangedSaturationValue()
	self:SetDefaultColors()

	return self
end

function ColorPicker:GetColor()
	return self.currentColor
end

function ColorPicker:SetPreviouslyUsedColor(index, newColor)
	self.previouslyUsedColors[index] = newColor

	-- Refresh the ui list of previously used colors
	for _, child in pairs(self.PreviousColorsFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			local index = child.LayoutOrder
			if self.previouslyUsedColors[index] then
				child.BackgroundColor3 = self.previouslyUsedColors[index]
			else
				child.BackgroundColor3 = BLANK_COLOR
			end
		end
	end
end

function ColorPicker:OnSwatchClicked(index)
	local previousColor = self.previouslyUsedColors[index]
	if previousColor then
		self.currentColorIndex = index

		local hue, saturation, value = previousColor:ToHSV()
		self.currentHue = hue
		self.currentSaturation = saturation
		self.currentValue = value
		self:OnChangedHue(true)
		self:OnChangedSaturationValue()

		if self.OnColorChangedCallback then
			self.OnColorChangedCallback(self.currentColor, true --[[isInputEnding]])
		end
	end
end

function ColorPicker:SetDefaultColors()
	for i, color in DEFAULT_COLOR_HISTORY do
		self:SetPreviouslyUsedColor(i, color)
	end
end

function ColorPicker:OnChangedHue(omitFromPreviousColors)
	local newColor = Color3.fromHSV(self.currentHue, self.currentSaturation, self.currentValue)
	self.HueRingSelector.BackgroundColor3 = Color3.fromHSV(self.currentHue, 1, 1)
	self.SatValueSelector.BackgroundColor3 = newColor
	self.currentColor = newColor
	self:RegenerateSaturationValueCircleTexture()
	if omitFromPreviousColors ~= true and self.currentColorIndex > 0 then
		self:SetPreviouslyUsedColor(self.currentColorIndex, newColor)
	end

	if self.OnColorChangedCallback then
		self.OnColorChangedCallback(newColor, false --[[isInputEnding]])
	end

	-- Update the position of the hue ring indicator
	local sweepAngle = self.currentHue * 360
	local fromCenter = Vector2.new(1, 0) * HUE_RING_AVERAGE_RADIUS
	local vectorPos = Utils.RotatePoint(fromCenter, Vector2.zero, sweepAngle) + self.PickerCenterPos
	self.HueRingSelector.Position = UDim2.fromOffset(vectorPos.X, vectorPos.Y)
	self.HueRingSelectorBg.Position = UDim2.fromOffset(vectorPos.X, vectorPos.Y)
end

function ColorPicker:OnChangedSaturationValue()
	local newColor = Color3.fromHSV(self.currentHue, self.currentSaturation, self.currentValue)
	self.SatValueSelector.BackgroundColor3 = newColor
	self.currentColor = newColor
	if self.currentColorIndex > 0 then
		self:SetPreviouslyUsedColor(self.currentColorIndex, newColor)
	end

	if self.OnColorChangedCallback then
		self.OnColorChangedCallback(newColor, false --[[isInputEnding]])
	end

	-- Update the position of the sat/value indicator
	-- Map to -1, 1
	local normalizedX = self.currentSaturation * 2 - 1
	local normalizedY = self.currentValue * 2 - 1

	local widgetX, widgetY = self:MapSquarePointToCircle(normalizedX, normalizedY)
	widgetX = widgetX * SAT_VALUE_RADIUS + SAT_VALUE_RADIUS
	widgetY = -widgetY * SAT_VALUE_RADIUS + SAT_VALUE_RADIUS

	self.SatValueSelector.Position = UDim2.fromOffset(widgetX, widgetY)
	self.SatValueSelectorBg.Position = UDim2.fromOffset(widgetX, widgetY)
end

function ColorPicker:GenerateHueRing(size)
	local editableTextureHueRing = AssetService:CreateEditableImage({
		Size = size,
	})
	local hueTextureSize = editableTextureHueRing.Size

	-- Create hue ring texture
	local numPixels = hueTextureSize.X * hueTextureSize.Y
	local pixels = buffer.create(numPixels * 4)

	local centerPoint = Vector2.new(hueTextureSize.X / 2, hueTextureSize.Y / 2)
	for i = 1, numPixels do
		local x = i % hueTextureSize.X
		local y = math.floor(i / hueTextureSize.X)
		local distanceFromCenter =
			math.sqrt(math.pow(x - hueTextureSize.X / 2, 2) + math.pow(y - hueTextureSize.Y / 2, 2))
		if distanceFromCenter >= HUE_RING_INNER_RADIUS and distanceFromCenter <= HUE_RING_OUTER_RADIUS then
			local currentPoint = Vector2.new(x, y) - centerPoint
			local sweepAngle = math.deg(math.asin(currentPoint.Y / distanceFromCenter))
			if currentPoint.X <= 0 then
				sweepAngle = 180 - sweepAngle
			elseif currentPoint.X >= 0 and currentPoint.Y <= 0 then
				sweepAngle = 360 + sweepAngle
			end

			local hue = sweepAngle / 360
			local saturation = 1
			local value = 1
			local color = Color3.fromHSV(hue, saturation, value)

			local index = (i - 1) * 4
			buffer.writeu8(pixels, index, color.R * 255)
			buffer.writeu8(pixels, index + 1, color.G * 255)
			buffer.writeu8(pixels, index + 2, color.B * 255)
			buffer.writeu8(pixels, index + 3, 255)
		else
			local index = (i - 1) * 4
			buffer.writeu8(pixels, index, 0)
			buffer.writeu8(pixels, index + 1, 0)
			buffer.writeu8(pixels, index + 2, 0)
			buffer.writeu8(pixels, index + 3, 0)
		end
	end

	-- TODO might need bilinear interpolation on this huering to reduce pixelation

	editableTextureHueRing:WritePixelsBuffer(Vector2.zero, editableTextureHueRing.Size, pixels)
	return editableTextureHueRing
end

function ColorPicker:MapCirclePointToSquare(x, y)
	local newX = x / math.sqrt(1 - y * y / 2)
	local newY = y / math.sqrt(1 - x * x / 2)

	return newX, newY
end

-- Expects X and Y to be in the range [-1, 1]
function ColorPicker:MapSquarePointToCircle(x, y)
	local newX = x * math.sqrt(1 - y * y / 2)
	local newY = y * math.sqrt(1 - x * x / 2)

	return newX, newY
end

function ColorPicker:RegenerateSaturationValueCircleTexture()
	-- We start with a square and map that to a circle.
	local size = self.editableTextureSVcircle.Size
	local width = size.X
	local height = size.Y
	local numPixels = width * height
	local pixels = buffer.create(numPixels * 4)

	local radius = size.X / 2
	for i = 1, numPixels do
		local x = i % width
		local y = math.floor(i / width)

		local distanceFromCenter = math.sqrt(math.pow(x - size.X / 2, 2) + math.pow(y - size.Y / 2, 2))
		if distanceFromCenter <= radius then
			-- Map to -1, 1
			local normalizedX = (x / width) * 2 - 1
			local normalizedY = (y / height) * 2 - 1

			local squareX, squareY = self:MapCirclePointToSquare(normalizedX, normalizedY)
			squareX = ((squareX + 1) / 2) * width
			squareY = ((squareY + 1) / 2) * width

			-- Get saturation/value from point on square
			local saturation = squareX / width
			local value = (height - squareY) / height

			local color = Color3.fromHSV(self.currentHue, saturation, value)

			local index = (i - 1) * 4
			buffer.writeu8(pixels, index, color.R * 255)
			buffer.writeu8(pixels, index + 1, color.G * 255)
			buffer.writeu8(pixels, index + 2, color.B * 255)
			buffer.writeu8(pixels, index + 3, 255)
		else
			local index = (i - 1) * 4
			buffer.writeu8(pixels, index, 0)
			buffer.writeu8(pixels, index + 1, 0)
			buffer.writeu8(pixels, index + 2, 0)
			buffer.writeu8(pixels, index + 3, 0)
		end
	end

	self.editableTextureSVcircle:WritePixelsBuffer(Vector2.zero, size, pixels)
end

function ColorPicker:IsOpen()
	return self.Frame.Visible
end

function ColorPicker:Open(callbackFunction)
	self.Frame.Visible = true
	self.currentColorIndex = -1
	for i = 1, MAX_COLOR_HISTORY do
		if self.previouslyUsedColors[i] == nil then
			self.currentColorIndex = i
		end
	end

	self.OnColorChangedCallback = callbackFunction
end

function ColorPicker:Close()
	self.Frame.Visible = false
end

function ColorPicker:SetCallback(callback)
	self.OnColorChangedCallback = callback
end

return ColorPicker
