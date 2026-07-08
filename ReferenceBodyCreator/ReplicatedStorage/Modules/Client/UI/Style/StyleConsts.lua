--[[
	Defines constants relevant for styling across UI components. Tags and icons
	are used by components throughout the experience; tags and tokens are used
	by the style manager (Style.lua) to enforce consistent visual design.
]]

-- Pseudo-enum of tags so tagging components is easier
local TAGS = {
	-- General
	BaseUI = "BaseUI",
	UIParent = "UIParent",
	MediumIconButton = "MediumIconButton",
	ButtonSelected = "ButtonSelected",
	Hidden = "Hidden",
	CoreUIWithOpenPanel = "CoreUIWithOpenPanel",
	BuyButton = "BuyButton",

	-- Panel
	Panel = "Panel",
	PanelHeader = "PanelHeader",
	PanelToolsContainer = "PanelToolsContainer",
	ToolFrame = "ToolFrame",
	ToolTitle = "ToolTitle",
	PanelParent = "PanelParent",

	-- Panel Components
	HorizontalPillbar = "HorizontalPillbar",
	PillbarButton = "PillbarButton",
	LargePillbarButton = "LargePillbarButton",
	SmallPillbarButton = "SmallPillbarButton",

	ColorPicker = "ColorPicker",
	SatValPicker = "SatValPicker",
	SatGradient = "SatGradient",
	ValGradient = "ValGradient",
	HuePicker = "HuePicker",
	ColorDot = "ColorDot",
	OpacityPicker = "OpacityPicker",
	OpacityOverlay = "OpacityOverlay",
	OpacityGradient = "OpacityGradient",

	-- Toggle
	ToggleFrame = "ToggleFrame",
	TogglePill = "TogglePill",
	ToggleLabel = "ToggleLabel",

	-- TopBar Menu
	LocalMenu = "LocalMenu",
	LocalMenuConsole = "LocalMenuConsole",
	LocalMenuButton = "LocalMenuButton",
	LocalMenuButtonGroup = "LocalMenuButtonGroup",

	-- Toolbar
	Toolbar = "Toolbar",
	Divider = "Divider",
	ToolbarButton = "ToolbarButton",
	ToolbarButtonGroup = "ToolbarButtonGroup",
	ToolbarParent = "ToolbarParent",

	-- Slider
	SliderFrame = "SliderFrame",
	SliderBar = "SliderBar",
	SliderInput = "SliderInput",
	SliderHandle = "SliderHandle",

	-- Grid
	BaseTile = "BaseTile",
	BaseTileButton = "BaseTileButton",
	TileGrid = "TileGrid",
	ScrollFrame = "ScrollFrame",

	-- Editing Handles
	MainHandle = "MainHandle",
	SmallHandle = "SmallHandle",

	-- Modals
	ModalFrame = "ModalFrame",
	ModalTextFrame = "ModalTextFrame",
	ModalTitle = "ModalTitle",
	ModalBody = "ModalBody",
	ButtonFrame = "ButtonFrame",

	DefaultButton = "DefaultButton",
	EmphasisButton = "EmphasisButton",

	Overlay = "Overlay",

	-- Avatar Preview
	SegmentedControl = "SegmentedControl",
	SegmentedControlButton = "SegmentedControlButton",
	AvatarPreviewSwitcher = "AvatarPreviewSwitcher",
	PreviewUIParent = "PreviewUIParent",

	-- Progress Bar
	ProgressBarFrame = "ProgressBarFrame",
	ProgressBarLabel = "ProgressBarLabel",
	ProgressBarBackground = "ProgressBarBackground",
	ProgressBarProgress = "ProgressBarProgress",

	-- Item Selector
	MiniBaseTile = "MiniBaseTile",
	MiniBaseTileGroup = "MiniBaseTileGroup",
	MiniBaseTileSelected = "MiniBaseTileSelected",

	ItemSelectorFrame = "ItemSelectorFrame",
	ItemSelectorScrollFrame = "ItemSelectorScrollFrame",
	ItemSelectorFlexFrame = "ItemSelectorFlexFrame",

	CounterFrame = "CounterFrame",
	CounterLabel = "CounterLabel",
}

-- Contains the image IDs of icons for direct use
local ICON_IMAGE_IDS = {
	AvatarPreview = "rbxassetid://101017308725269",
	ExitEditor = "rbxassetid://127961031559745",
	ResetChanges = "rbxassetid://78889107986995",
	XButton = "rbxassetid://71171759549271",
	Delete = "rbxassetid://126203593172385",
	Scale = "rbxassetid://96436562942369",
	Rotate = "rbxassetid://114067372218201",

	Paintbrush = "rbxassetid://105441125994290",
	Eraser = "rbxassetid://78016323272575",
	Recolor = "rbxassetid://133908426980046",
	Decal = "rbxassetid://110475569250921",
	Pattern = "rbxassetid://107153084986708",
	Kitbashing = "rbxassetid://135744896670779",

	PaintbrushMuted = "rbxassetid://114632118377883",
	EraserMuted = "rbxassetid://110165308214781",
	DecalMuted = "rbxassetid://81559320299149",
	PatternMuted = "rbxassetid://72120360636986",
}

-- Contains the image IDs of icons used to return to editing mode, indexed by
-- the model name.
local EDITOR_ICON_IMAGE_IDS = {
	RobotModel = "rbxassetid://110650241685215",
	TShirtModel = "rbxassetid://90986523398908",
	HatModel = "rbxassetid://116611995772177",
}

-- Contains the image IDs of icons for widget editing icons on the toolbar,
-- indexed by the widget control group name.
local WIDGET_ICON_IMAGE_IDS = {
	Head = "rbxassetid://123921714663008",
	Body = "rbxassetid://112231836235511",
	Shirt = "rbxassetid://112967115722385",

	HeadMuted = "rbxassetid://99155152631918",
	BodyMuted = "rbxassetid://116758126178214",
}

-- Contains the image IDs of icons for regions of models, indexed by the
-- expected region name.
local REGION_ICON_IMAGE_IDS = {
	RobotModel = "rbxassetid://71345610249564",
	TShirtModel = "rbxassetid://100393568259271",
	HatModel = "rbxassetid://100093471646213",

	Hair = "rbxassetid://93283252230357",
	Head = "rbxassetid://113048719521718",
	LeftArm = "rbxassetid://76154702937073",
	RightArm = "rbxassetid://85624010745922",
	Torso = "rbxassetid://125885421025912",
	LeftLeg = "rbxassetid://89780999293176",
	RightLeg = "rbxassetid://71728202659306",

	Brim = "rbxassetid://99409227712971",
	Band = "rbxassetid://104438137440192",
	Crown = "rbxassetid://110312846318583",
}

local UI_IMAGE_IDS = {
	ToggleOff = "rbxassetid://96061243919515",
	ToggleOn = "rbxassetid://129923601024951",
	OpacityPicker = "rbxassetid://79024368709423",
}

local REGION_ORDERING = {
	RobotModel = 1,
	TShirtModel = 1,
	HatModel = 1,

	Hair = 2,
	Head = 3,
	Torso = 4,
	RightArm = 5,
	LeftArm = 6,
	RightLeg = 7,
	LeftLeg = 8,

	Brim = 2,
	Band = 3,
	Crown = 4,
}

local MODEL_NAME_TO_DISPLAY_NAME = {
	RobotModel = "Body",
	TShirtModel = "T-Shirt",
	HatModel = "Hat",
}

-- Helper function to create the hue gradient
local function generateRainbowColorSequence(points: number): ColorSequence
	local keypoints = {}

	for i = 0, points do
		table.insert(keypoints, ColorSequenceKeypoint.new(i / points, Color3.fromHSV(i / points, 1, 1)))
	end

	return ColorSequence.new(keypoints)
end

local BUILDER_SANS_ASSET_ID = "rbxasset://fonts/families/BuilderSans.json"

-- Constant values for use in style rules
local STYLE_TOKENS = {
	-- General tokens
	CenterPosition = UDim2.fromScale(0.5, 0.5),
	CenterAnchor = Vector2.new(0.5, 0.5),

	Colors = {
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
		RainbowGradient = generateRainbowColorSequence(8),
		ContentEmphasis = Color3.fromHex("#F7F7F8"),
		ContentDefault = Color3.fromHex("#D5D7DD"),
	},

	ActionEmphasis = {
		Color3 = Color3.fromHex("#335FFF"),
		Transparency = 0,
	},
	OverMedia_0 = {
		Color3 = Color3.fromRGB(18, 18, 21),
		Transparency = 0.08,
	},
	OverMedia_200 = {
		Color3 = Color3.fromRGB(32, 34, 39),
		Transparency = 0.08,
	},
	Surface_0 = {
		Color3 = Color3.fromHex("#121215"),
		Transparency = 0,
	},
	Surface_100 = {
		Color3 = Color3.fromHex("#191A1F"),
		Transparency = 0,
	},
	Shift_200 = {
		Color3 = Color3.fromRGB(208, 217, 251),
		Transparency = 0.92,
	},
	Shift_300 = {
		Color3 = Color3.fromRGB(208, 217, 251),
		Transparency = 0.88,
	},
	Shift_400 = {
		Color3 = Color3.fromRGB(208, 217, 251),
		Transparency = 0.84,
	},
	System_Contrast = {
		Color3 = Color3.fromHex("F7F7F8"),
		Transparency = 0,
	},
	Shadow = {
		Color3 = Color3.fromRGB(0, 0, 0),
		Transparency = 0.5,
	},

	Stroke_Default = {
		Color = Color3.fromRGB(208, 217, 251),
		Transparency = 0.88,
		Thickness = 1,
	},
	Stroke_Muted = {
		Color = Color3.fromRGB(208, 217, 251),
		Transparency = 0.92,
		Thickness = 1,
	},

	IconSize = {
		XSmall = UDim2.fromOffset(14, 14),
		Small = UDim2.fromOffset(18, 18),
		Large = UDim2.fromOffset(24, 24),
	},
	Padding = {
		None = UDim.new(0, 0),
		XXSmall = UDim.new(0, 2),
		XSmall = UDim.new(0, 4),
		Small = UDim.new(0, 8),
		Medium = UDim.new(0, 12),
		Large = UDim.new(0, 16),
		XLarge = UDim.new(0, 20),
		XXLarge = UDim.new(0, 24),
	},
	Radius = {
		Small = UDim.new(0, 4),
		Medium = UDim.new(0, 8),
		Large = UDim.new(0, 16),
		Circle = UDim.new(0, 9999),
	},

	FontSize = {
		FontSize_300 = 15.12,
		FontSize_350 = 17.64,
		FontSize_400 = 20.16,
		FontSize_500 = 25.2,
	},

	FontWeight = {
		FontWeight_400 = Enum.FontWeight.Regular,
		FontWeight_600 = Enum.FontWeight.SemiBold,
		FontWeight_700 = Enum.FontWeight.Bold,
	},

	IconButtonSize = UDim2.fromOffset(40, 40),

	-- Local Menu Buttons
	LocalMenuButtonSize = UDim2.fromOffset(36, 36),

	TopBarHeight = UDim.new(0, 58),

	-- Panel
	PanelHeaderSize = UDim2.new(1, 0, 0, 44),
	PanelSize = UDim2.new(0, 320, 1, 0),
	PanelMaxSize = Vector2.new(math.huge, 558), -- Max height only

	ToolTitleSize = UDim2.new(1, 0, 0, 16),

	-- Pillbar
	LargePillbarIconSize = UDim2.fromOffset(20, 18),
	LargePillbarVerticalPadding = UDim.new(0, 11),
	LargePillbarHorizontalPadding = UDim.new(0, 10),
	MaxLargePillbarButtons = 6,

	-- Color Picker
	HueSliderSize = UDim2.new(1, 0, 0, 20),
	SatValPickerSize = UDim2.new(1, 0, 0, 149),
	ColorDotSize = UDim2.fromOffset(18, 18),
	ColorDotStrokeThickness = 3,

	-- Toggle
	TogglePillSize = UDim2.fromOffset(40, 24),

	-- Slider
	SliderBarSize = UDim2.new(1, 0, 0, 8),
	SliderInputPadding = UDim.new(0, 6),
	SliderInputSize = UDim2.new(1, 0, 0, 20),
	SliderHandleSize = UDim2.fromOffset(24, 24),

	-- Grid Components
	GridTileSize = UDim2.fromOffset(80, 80),

	-- Editing Handles
	MainHandleDefaultRadius = 76,
	MainHandleBorderThickness = 2,
	SmallHandleSize = UDim2.fromOffset(24, 24),
	SmallHandleIconSize = UDim2.fromOffset(14, 14),
	ScaleHandlePosDegrees = -45,
	RotateHandlePosDegrees = 45,

	-- Toolbar
	ToolbarButtonSize = UDim2.fromOffset(40, 40),
	ToolbarParentPadding = UDim.new(0, 22), -- Centered with local menu button

	-- Modal
	ModalTwoButtonSize = UDim2.fromOffset(376, 0),
	ModalThreeButtonSize = UDim2.fromOffset(480, 0),

	ButtonSize = UDim2.fromOffset(0, 40), -- X should be handled by flex

	-- Avatar Preview
	SegmentedControlPadding = UDim.new(0, 6),
	SegmentedControlButtonSize = UDim2.fromOffset(140, 36),

	-- Progress bar
	ProgressBarFrameSize = UDim2.new(1, 0, 0, 20),
	ProgressBarBackgroundSize = UDim2.fromOffset(0, 4), -- Flex will handle X

	-- Buy Button
	BuyButtonSize = UDim2.fromOffset(131, 48),

	-- Sticker Selector
	MiniBaseTileGroupSize = UDim2.fromOffset(0, 40),
	BaseTileMinSize = Vector2.new(40, 40),

	ScrollBarImages = {
		Top = "rbxassetid://76984408878669",
		Middle = "rbxassetid://90051606532809",
		Bottom = "rbxassetid://79403364428324",
	},
}

local FONT_TOKENS = {
	TitleLarge = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_700),
		FontSize = STYLE_TOKENS.FontSize.FontSize_400,
	},

	ToolTitleFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_350,
	},

	ModalTitleFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_700),
		FontSize = STYLE_TOKENS.FontSize.FontSize_500,
	},
	ModalBodyFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_400),
		FontSize = STYLE_TOKENS.FontSize.FontSize_350,
	},
	ButtonFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_350,
	},

	CounterLabelFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_300,
	},

	SegmentedControlButtonFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_400,
	},

	BuyButtonFont = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_400,
	},
}

local MOBILE_WIDTH_CUTOFF = 1024

local DEFAULT_COLOR_PICKER_COLOR = {
	h = 0,
	s = 1,
	v = 1,
}

local StyleConsts = {
	tags = TAGS,
	icons = ICON_IMAGE_IDS,
	styleTokens = STYLE_TOKENS,
	fontTokens = FONT_TOKENS,
	regionIcons = REGION_ICON_IMAGE_IDS,
	regionOrdering = REGION_ORDERING,
	modelDisplayName = MODEL_NAME_TO_DISPLAY_NAME,
	widgetIcons = WIDGET_ICON_IMAGE_IDS,
	editorIcons = EDITOR_ICON_IMAGE_IDS,
	uiImages = UI_IMAGE_IDS,

	-- Not in a group
	MobileWidthCutoff = MOBILE_WIDTH_CUTOFF,
	DefaultColorPickerColor = DEFAULT_COLOR_PICKER_COLOR,
}

return StyleConsts
