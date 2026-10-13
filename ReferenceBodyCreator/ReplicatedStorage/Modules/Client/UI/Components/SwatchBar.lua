--[[
	Creates a swatch bar for saving and loading colors with opacity.

    Takes in callbacks for where to find the colors to be saved as well
    as where to put the colors when they are requested to be loaded.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))
local Swatch = require(Components:WaitForChild("Swatch"))

local MAX_SWATCH_ROWS: number = StyleConsts.SwatchBarMaxRows
local CELL_SIZE: UDim2 = StyleConsts.styleTokens.SwatchSize
local CELL_WIDTH: number = CELL_SIZE.X.Offset
local MIN_CELL_PADDING: number = StyleConsts.styleTokens.Padding.XSmall.Offset

local SwatchBarInternal = {}
SwatchBarInternal.__index = SwatchBarInternal

function SwatchBarInternal:addSwatch(color: Color3, opacity: number?)
	local function onActivated()
		self.onSelectSwatchColorCallback(color)
		if self.onSelectSwatchOpacityCallback then
			self.onSelectSwatchOpacityCallback(opacity or 1)
		end
	end

	local newSwatch = Swatch.createComponentFrame(onActivated, color, opacity)
	newSwatch.Parent = self.frame
	newSwatch.LayoutOrder = self.numSwatches

	self.numSwatches += 1
end

function SwatchBarInternal.new(
	onSelectSwatchColorCallback: (Color3) -> (),
	setSwatchColorCallback: (() -> Color3)?,
	onSelectSwatchOpacityCallback: (number) -> ()?,
	setSwatchOpacityCallback: (() -> number)?,
	swatchBarDefaultColors: { Color3 }?
)
	local self = {}
	setmetatable(self, SwatchBarInternal)

	self.onSelectSwatchColorCallback = onSelectSwatchColorCallback
	self.onSelectSwatchOpacityCallback = onSelectSwatchOpacityCallback

	self.frame = Instance.new("Frame")
	self.frame.Name = "SwatchBar"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.SwatchBar)

	-- Padding and GridLayout can't be psuedoinstances as they are not constants, they are created
	-- dynamically based on the current frame size and the size of the swatches
	local uiPadding = Instance.new("UIPadding")
	uiPadding.Parent = self.frame

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.Parent = self.frame

	local gridPadding: number = 0

	local function updateCellPadding()
		local frameWidth = self.frame.AbsoluteSize.X

		-- The maximum number of cells per row given that they are separated by MIN_CELL_PADDING
		local cellsPerRow = math.floor((frameWidth + MIN_CELL_PADDING) / (CELL_WIDTH + MIN_CELL_PADDING))
		if cellsPerRow > 1 then
			-- The necessary padding given cellPerRow cells, always >= MIN_CELL_PADDING
			gridPadding = math.floor((frameWidth - cellsPerRow * CELL_WIDTH) / (cellsPerRow - 1))
			uiGridLayout.CellPadding = UDim2.fromOffset(gridPadding, gridPadding)

			-- There can be a large remainder here - to avoid obvious wrapping weirdness center
			-- the swatches within the maximum frame
			local contentWidth = cellsPerRow * CELL_WIDTH + (cellsPerRow - 1) * gridPadding
			local remainder = frameWidth - contentWidth
			uiPadding.PaddingLeft = UDim.new(0, math.floor(remainder / 2)) -- Ensure a full swatchBar is centered
		end
	end

	self.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCellPadding)
	updateCellPadding()

	uiGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.frame.Size = UDim2.new(
			1,
			0,
			0,
			math.min(
				uiGridLayout.AbsoluteContentSize.Y,
				MAX_SWATCH_ROWS * CELL_SIZE.Y.Offset + (MAX_SWATCH_ROWS - 1) * gridPadding
			)
		)
	end)

	self.numSwatches = 0

	if setSwatchColorCallback then
		local function onPlusClicked()
			self:addSwatch(
				setSwatchColorCallback(),
				if setSwatchOpacityCallback then setSwatchOpacityCallback() else nil
			)
		end

		local plusButton = IconButton.createComponentFrame(StyleConsts.icons.PlusButton, onPlusClicked)
		plusButton.LayoutOrder = 99 -- Plus button should always be last
		plusButton.Parent = self.frame
		StyleUtils.AddStyleTag(plusButton, StyleConsts.tags.SwatchBarPlusButton)
	end

	if swatchBarDefaultColors then
		for _, color in swatchBarDefaultColors do
			self:addSwatch(color, nil)
		end
	end

	return self
end

local SwatchBarPublic = {}

function SwatchBarPublic.createComponentFrame(
	onSelectSwatchColorCallback: (Color3) -> (), -- On swatch click, outputs color
	setSwatchColorCallback: (() -> Color3)?, -- On new swatch request, determines color
	onSelectSwatchOpacityCallback: ((number) -> ())?, -- On swatch click, outputs opacity
	setSwatchOpacityCallback: (() -> number)?, -- On new swatch request, determines opacity
	swatchBarDefaultColors: { Color3 }? -- Optional default colors to populate the swatch bar with
)
	local swatchBar = SwatchBarInternal.new(
		onSelectSwatchColorCallback,
		setSwatchColorCallback,
		onSelectSwatchOpacityCallback,
		setSwatchOpacityCallback,
		swatchBarDefaultColors
	)

	return swatchBar.frame
end

return SwatchBarPublic
