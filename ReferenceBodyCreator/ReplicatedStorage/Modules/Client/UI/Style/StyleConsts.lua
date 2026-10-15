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
	IconButtonMuted = "IconButtonMuted",
	ButtonSelected = "ButtonSelected",
	Hidden = "Hidden",
	CoreUIWithOpenPanel = "CoreUIWithOpenPanel",
	BuyButton = "BuyButton",
	StampActionBar = "StampActionBar",
	StampActionBarButton = "StampActionBarButton",
	ActionBarPreviewButton = "ActionBarPreviewButton",
	ToolbarWithStampActionBar = "ToolbarWithStampActionBar",

	-- Panel
	Panel = "Panel",
	PanelHeader = "PanelHeader",
	PanelToolsContainer = "PanelToolsContainer",
	ToolFrame = "ToolFrame",
	ToolTitle = "ToolTitle",
	PanelParent = "PanelParent",

	-- Panel Components
	StepButtons = "StepButtons",
	StepButtonDisabled = "StepButtonDisabled",
	ShapeControlDisabled = "ShapeControlDisabled",
	Banner = "Banner",
	BannerEmphasis = "BannerEmphasis",
	BannerCompact = "BannerCompact",
	BannerContent = "BannerContent",
	BannerAction = "BannerAction",

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

	SwatchBar = "SwatchBar",
	Swatch = "Swatch",
	SwatchCanvas = "SwatchCanvas",
	SwatchOpacityHalf = "SwatchOpacityHalf",
	SwatchBarPlusButton = "SwatchBarPlusButton",

	-- Toggle
	ToggleFrame = "ToggleFrame",
	TogglePill = "TogglePill",
	ToggleLabel = "ToggleLabel",
	Chip = "Chip",
	ChipActive = "ChipActive",
	ChipFrame = "ChipFrame",
	SideChip = "SideChip",
	SideChipActive = "SideChipActive",
	SideChipContainer = "SideChipContainer",

	-- Badge (non-interactive display pill)
	Badge = "Badge",
	TopBarLayerIndicator = "TopBarLayerIndicator",

	-- TopBar Menu
	LocalMenu = "LocalMenu",
	LocalMenuConsole = "LocalMenuConsole",
	LocalMenuWithOpenPanel = "LocalMenuWithOpenPanel",
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
	BrushSizeSliderTool = "BrushSizeSliderTool",
	BrushSizePreviewFrame = "BrushSizePreviewFrame",
	BrushSizePreviewTile = "BrushSizePreviewTile",
	BrushSizePreviewCircle = "BrushSizePreviewCircle",
	BrushSizePreviewCircleStroke = "BrushSizePreviewCircleStroke",

	-- Grid
	BaseTile = "BaseTile",
	BaseTileButton = "BaseTileButton",
	BaseTileInsetButton = "BaseTileInsetButton",
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
	ModalMiddleContent = "ModalMiddleContent",
	ModalTwoStateIconButton = "ModalTwoStateIconButton",
	ModalTwoStateIconButtonActive = "ModalTwoStateIconButtonActive",

	DefaultButton = "DefaultButton",
	SmallButton = "SmallButton",
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

	-- Layers
	LayerTile = "LayerTile",
	LayerTileThumbnail = "LayerTileThumbnail",
	LayerTileButton = "LayerTileButton",
	LayerOpacitySlider = "LayerOpacitySlider",
	AddLayerButton = "AddLayerButton",

	LayerStack = "LayerStack",
	LayersContainer = "LayersContainer",

	-- Collapsibles
	CollapsiblePrimarySelection = "CollapsiblePrimarySelection",
	CollapsibleSecondarySelection = "CollapsibleSecondarySelection",

	CollapsibleChild = "CollapsibleChild",

	CollapsibleContainer = "CollapsibleContainer",
	CollapsibleContainerVisibleContent = "CollapsibleContainerVisibleContent",
	CollapsibleIndicatorButton = "CollapsibleIndicatorButton",

	-- Brush Picker
	BrushPickerScroll = "BrushPickerScroll",
	BrushPickerTile = "BrushPickerTile",
	BrushPickerThumbnail = "BrushPickerThumbnail",
	BrushPickerSelectionOutline = "BrushPickerSelectionOutline",
	BrushPickerCaption = "BrushPickerCaption",
	BrushPickerArrows = "BrushPickerArrows",
	BrushPickerCardTinted = "BrushPickerCardTinted",

	-- Dropdown Menu
	DropdownMenu = "DropdownMenu",
	DropdownMenuTitle = "DropdownMenuTitle",
	DropdownMenuOption = "DropdownMenuOption",
	DropdownMenuOptionHover = "DropdownMenuOptionHover",
	DropdownMenuOptionDisabled = "DropdownMenuOptionDisabled",
	DropdownMenuOptionInfo = "DropdownMenuOptionInfo",
	DropdownMenuOptionRight = "DropdownMenuOptionRight",
	DropdownMenuFooter = "DropdownMenuFooter",

	-- Makeup category section (title row + swappable card/group-list body)
	MakeupSection = "MakeupSection",
	MakeupSectionTitle = "MakeupSectionTitle",
	MakeupSectionBody = "MakeupSectionBody",
	AddItemButton = "AddItemButton",
	AddItemButtonDisabled = "AddItemButtonDisabled",

	-- Group Card (empty-state card shown before any group exists in a category)
	GroupCard = "GroupCard",
	GroupCardIconContainer = "GroupCardIconContainer",
	GroupCardIconFrame = "GroupCardIconFrame",
	GroupCardIcon = "GroupCardIcon",
	GroupCardTitle = "GroupCardTitle",
	GroupCardSubtitle = "GroupCardSubtitle",
}

-- Contains the image IDs of icons for direct use
local ICON_IMAGE_IDS = {
	Undo = "rbxassetid://88426119016076",
	Redo = "rbxassetid://92828349045901",
	AvatarPreview = "rbxassetid://92557342249373",
	ExitEditor = "rbxassetid://119832619238783",
	ResetChanges = "rbxassetid://114749082581711",
	ResetCamera = "rbxassetid://90843304828210",
	ShoppingCart = "rbxassetid://81151284655009",
	KebabMenu = "rbxassetid://85955162450849",
	XButton = "rbxassetid://71171759549271",
	PlusButton = "rbxassetid://78300979449956",
	Delete = "rbxassetid://126203593172385",
	Scale = "rbxassetid://96436562942369",
	Rotate = "rbxassetid://114067372218201",
	MakeupLayers = "rbxassetid://83793140934269",
	Visibility = "rbxassetid://92151848570366",
	VisibilityOff = "rbxassetid://127494382138817",
	MoreOptions = "rbxassetid://120404578167908",

	Eyelashes = "rbxassetid://83413478792862",
	Eyebrows = "rbxassetid://83709593483152",
	FaceMakeup = "rbxassetid://76606949528636",
	EyeMakeup = "rbxassetid://98111172937157",
	LipsMakeup = "rbxassetid://71237731317105",
	MakeupCard = "rbxassetid://110424726794085",
	BrowsLashesCard = "rbxassetid://106051104700213",

	Paintbrush = "rbxassetid://105441125994290",
	Eraser = "rbxassetid://78016323272575",
	Blend = "rbxassetid://87793039173139",
	Recolor = "rbxassetid://133908426980046",
	Decal = "rbxassetid://110475569250921",
	Stamp = "rbxassetid://101810724391179",
	Pattern = "rbxassetid://107153084986708",
	Kitbashing = "rbxassetid://97650330811050",
	MakeupPreview = "rbxassetid://82285963786126",
	BrowsLashesCatalog = "rbxassetid://133848590318001",

	PaintbrushMuted = "rbxassetid://114632118377883",
	EraserMuted = "rbxassetid://110165308214781",
	BlendMuted = "rbxassetid://133997465513372",
	DecalMuted = "rbxassetid://81559320299149",
	StampMuted = "rbxassetid://139292430801716",
	PatternMuted = "rbxassetid://72120360636986",

	ChevronUp = "rbxassetid://116723929230007",
	ChevronDown = "rbxassetid://110431113506663",
	ChevronLeft = "rbxassetid://123151184807074",
	ChevronRight = "rbxassetid://124614901205408",
	Checkmark = "rbxassetid://111362765797035",

	MirrorPlane = "rbxassetid://104401956471026",
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
	MakeupHeadModel = "rbxassetid://113048719521718",

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
	SwatchTransparencyBackground = "rbxassetid://133364742010525",
}

local REGION_ORDERING = {
	RobotModel = 1,
	TShirtModel = 1,
	HatModel = 1,
	MakeupHeadModel = 1,

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
	MakeupHeadModel = "Makeup",
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
		ContentMuted = Color3.fromHex("#BCBEC8"),
	},

	ActionEmphasis = {
		Color3 = Color3.fromHex("#335FFF"),
		Transparency = 0,
	},
	ActionSoftEmphasis = {
		Color3 = Color3.fromHex("#335FFF"),
		Transparency = 0.6,
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
	Surface_200 = {
		Color3 = Color3.fromHex("#202227"),
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
	Stroke_ActionEmphasis = {
		Color = Color3.fromHex("#000000"),
		Transparency = 0,
		Thickness = 1,
	},

	IconSize = {
		XSmall = UDim2.fromOffset(14, 14),
		Small = UDim2.fromOffset(18, 18),
		Medium = UDim2.fromOffset(20, 20),
		Large = UDim2.fromOffset(24, 24),
		XXLarge = UDim2.fromOffset(48, 48),
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

	SwatchSize = UDim2.fromOffset(22, 22),

	-- Local Menu Buttons
	LocalMenuButtonSize = UDim2.fromOffset(36, 36),

	TopBarHeight = UDim.new(0, 58),
	BadgeSize = UDim2.fromOffset(0, 24),

	-- Panel
	PanelHeaderSize = UDim2.new(1, 0, 0, 44),
	PanelSize = UDim2.new(0, 320, 1, 0),
	PanelMaxSize = Vector2.new(math.huge, 660), -- Max height only

	ToolTitleSize = UDim2.new(1, 0, 0, 16),

	BannerEmphasisTransparency = 0.96,
	BannerCompactHeight = 72,
	BannerLeadingSize = UDim2.fromOffset(48, 48),
	BannerTextHeight = 20,

	-- Pillbar
	LargePillbarIconSize = UDim2.fromOffset(20, 18),
	LargePillbarVerticalPadding = UDim.new(0, 11),
	LargePillbarHorizontalPadding = UDim.new(0, 10),
	MaxLargePillbarButtons = 6,

	-- Chip
	SideChipWidth = 45,
	SideChipContainerPadding = UDim.new(0, -13),

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
	GridTileInsetButtonHeight = 24,
	GridTileInsetButtonZIndex = 2,

	-- Editing Handles
	MainHandleDefaultRadius = 76,
	MainHandleBorderThickness = 2,
	SmallHandleSize = UDim2.fromOffset(24, 24),
	SmallHandleIconSize = UDim2.fromOffset(14, 14),
	ScaleHandlePosDegrees = -45,
	RotateHandlePosDegrees = 45,
	-- Clamp pixel radius, preventing the edit circle from having extreme sizes
	MinHandleRadius = 20,
	MaxHandleRadius = 250,

	-- Toolbar
	ToolbarButtonSize = UDim2.fromOffset(40, 40),
	ToolbarParentPadding = UDim.new(0, 22), -- Centered with local menu button

	-- Modal
	ModalTwoButtonSize = UDim2.fromOffset(376, 0),
	ModalThreeButtonSize = UDim2.fromOffset(480, 0),

	ButtonSize = UDim2.fromOffset(0, 40), -- X should be handled by flex
	SmallButtonSize = UDim2.fromOffset(0, 32),
	SmallButtonMinSize = Vector2.new(32, 32),
	StepButtonSize = UDim2.fromOffset(126, 32),
	StepButtonDisabledTextTransparency = 0.6,

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

	-- Brush Picker
	BrushPickerThumbnailSize = UDim2.fromOffset(68, 46),
	BrushPickerCaptionHeight = 20,
	BrushPickerTintTransparency = 0.3,

	-- Dropdown Menu
	DropdownMenuSize = UDim2.fromOffset(200, 0), -- Width fixed; height auto
	-- Header and option rows: full menu width, fixed 40px tall.
	DropdownMenuRowSize = UDim2.new(1, 0, 0, 40),

	ScrollBarThickness = 4,
	ScrollBarImages = {
		Top = "rbxassetid://76984408878669",
		Middle = "rbxassetid://90051606532809",
		Bottom = "rbxassetid://79403364428324",
	},

	-- Layer Tile
	LayerTileThumbnailSize = UDim2.fromOffset(32, 32),

	-- Collapsibles
	CollapsibleChildSize = UDim2.new(1, 0, 0, 44),
	CollapsibleChildPadding = UDim.new(0, 44),

	StampActionBarMaxSize = Vector2.new(600, 40),

	-- Group Card
	AddItemButtonSize = UDim2.fromOffset(75, 32),
	AddItemButtonMinSize = Vector2.new(48, 32),
	AddItemButtonTextSize = 14,
	AddItemButtonDisabledTransparency = 0.6,
	GroupCardStrokeTransparency = 0.84,
	GroupCardIconContainerSize = UDim2.fromScale(0.75, 1),
	GroupCardIconAspectRatio = 205 / 120,
}

local FONT_TOKENS = {
	TitleSmall = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_700),
		FontSize = STYLE_TOKENS.FontSize.FontSize_300,
	},
	TitleLarge = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_700),
		FontSize = STYLE_TOKENS.FontSize.FontSize_400,
	},
	BodyMedium = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_400),
		FontSize = STYLE_TOKENS.FontSize.FontSize_350,
	},
	BodySmall = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_400),
		FontSize = STYLE_TOKENS.FontSize.FontSize_300,
	},
	LabelSmall = {
		Font = Font.new(BUILDER_SANS_ASSET_ID, STYLE_TOKENS.FontWeight.FontWeight_600),
		FontSize = STYLE_TOKENS.FontSize.FontSize_300,
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

local SWATCH_BAR_MAX_ROWS = 4

local SWATCH_BAR_DEFAULT_COLORS = {
	Color3.fromHex("#FED857"),
	Color3.fromHex("#C29952"),
	Color3.fromHex("#B49380"),
	Color3.fromHex("#9C7876"),
	Color3.fromHex("#825B42"),
	Color3.fromHex("#5A4134"),
	Color3.fromHex("#703E23"),
	Color3.fromHex("#755463"),
	Color3.fromHex("#BB8DA3"),
	Color3.fromHex("#C76A96"),
	Color3.fromHex("#B3599E"),
	Color3.fromHex("#E66EC4"),
	Color3.fromHex("#FF91E0"),
	Color3.fromHex("#E88177"),
	Color3.fromHex("#FFA265"),
	Color3.fromHex("#F3B58C"),
	Color3.fromHex("#FFC6C8"),
	Color3.fromHex("#70889F"),
	Color3.fromHex("#447DB2"),
	Color3.fromHex("#00929E"),
	Color3.fromHex("#98C587"),
	Color3.fromHex("#429D40"),
	Color3.fromHex("#759D65"),
	Color3.fromHex("#5F8269"),
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
	SwatchBarMaxRows = SWATCH_BAR_MAX_ROWS,
	SwatchBarDefaultColors = SWATCH_BAR_DEFAULT_COLORS,
}

return StyleConsts
