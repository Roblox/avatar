--[[
	Style manager using StyleSheets and tags to facilitate styling of several
	UI components.
	Uses tags and tokens defined in StyleConsts.lua.

	Style rules are defined in RULE_MAP using a selector -> property list mapping.
	These are later added to the StyleSheet object. This also defines methods
	for adding tags to components and linking a ScreenGUI.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utils = require(Modules:WaitForChild("Utils"))
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local Style = {}
Style.__index = Style

local tags = StyleConsts.tags
local styleTokens = StyleConsts.styleTokens

local THEME_TOKENS = {
	PanelSize = "PanelSize",
	PanelCornerRadius = "PanelCornerRadius",
	PanelAutomaticSize = "PanelAutomaticSize",
	PanelAnchorPoint = "PanelAnchorPoint",
	PanelPosition = "PanelPosition",
	UIParentPaddingTop = "UIParentPaddingTop",
	UIParentPaddingRight = "UIParentPaddingRight",
	PanelMaxSize = "PanelMaxSize",
	ToolbarDividerSize = "ToolbarDividerSize",
	ToolbarFillDirection = "ToolbarFillDirection",
	ToolbarAnchorPoint = "ToolbarAnchorPoint",
	ToolbarPosition = "ToolbarPosition",
	ToolbarParentPaddingBottom = "ToolbarParentPaddingBottom",
	ToolbarLayoutOrder = "ToolbarLayoutOrder",
	PanelLayoutOrder = "PanelLayoutOrder",
	ToolbarParentFlexFill = "ToolbarParentFlexFill",
	PanelParentFlexFill = "PanelParentFlexFill",

	AvatarPreviewAnchorPoint = "AvatarPreviewAnchorPoint",
	AvatarPreviewPosition = "AvatarPreviewPosition",

	CoreUIVisibilityWithPanel = "CoreUIVisibilityWithPanel",

	LocalMenuRightPadding = "LocalMenuRightPadding",
}

local RULE_MAP = {
	-- General
	["TextLabel"] = {
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
	},
	-- Remove borders by default
	["Frame, ImageButton, TextButton"] = {
		BorderSizePixel = 0,
	},

	[`.{tags.CoreUIWithOpenPanel}`] = {
		Visible = `${THEME_TOKENS.CoreUIVisibilityWithPanel}`,
	},

	-- Parent frames
	[`.{tags.UIParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, 0),
	},
	[`.{tags.UIParent}::UIPadding`] = {
		PaddingTop = `${THEME_TOKENS.UIParentPaddingTop}`,
		PaddingRight = `${THEME_TOKENS.UIParentPaddingRight}`,
	},
	[`.{tags.UIParent}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.Small,
	},

	[`.{tags.BaseUI}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XXLarge,
		PaddingRight = `${THEME_TOKENS.LocalMenuRightPadding}`,
	},

	[`.{tags.PanelParent}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = `${THEME_TOKENS.PanelLayoutOrder}`,
	},
	[`.{tags.PanelParent}::UIFlexItem`] = {
		FlexMode = `${THEME_TOKENS.PanelParentFlexFill}`,
	},

	[`.{tags.ToolbarParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = `${THEME_TOKENS.ToolbarLayoutOrder}`,
	},
	[`.{tags.ToolbarParent}::UIPadding`] = {
		PaddingBottom = `${THEME_TOKENS.ToolbarParentPaddingBottom}`,
	},
	[`.{tags.ToolbarParent}::UIFlexItem`] = {
		FlexMode = `${THEME_TOKENS.ToolbarParentFlexFill}`,
	},

	[`.{tags.MediumIconButton}`] = {
		Size = styleTokens.IconButtonSize,
		BackgroundTransparency = 1,
	},

	[`.{tags.MediumIconButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Large,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
	},

	-- Local Menu
	[`.{tags.LocalMenu}`] = {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1), -- Bottom right
		Position = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.LocalMenu}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XXSmall,
		PaddingRight = `${THEME_TOKENS.LocalMenuRightPadding}`,
	},
	[`.{tags.LocalMenu}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.None,
	},

	[`.{tags.LocalMenuButton}`] = {
		Size = styleTokens.LocalMenuButtonSize,
		BackgroundColor3 = styleTokens.OverMedia_0.Color3,
		BackgroundTransparency = styleTokens.OverMedia_0.Transparency,
	},
	[`.{tags.LocalMenuButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.LocalMenuButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Small,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
	},

	-- Panel
	[`.{tags.Panel}`] = {
		BackgroundColor3 = styleTokens.Surface_0.Color3,
		BackgroundTransparency = styleTokens.Surface_0.Transparency,
		Size = `${THEME_TOKENS.PanelSize}`,
		AutomaticSize = `${THEME_TOKENS.PanelAutomaticSize}`,
		AnchorPoint = `${THEME_TOKENS.PanelAnchorPoint}`,
		Position = `${THEME_TOKENS.PanelPosition}`,
	},
	[`.{tags.Panel}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Small,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Medium, -- Slightly changed to allow more space; device inset weirdness
		PaddingBottom = styleTokens.Padding.XLarge,
	},
	[`.{tags.Panel}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = styleTokens.Padding.Large,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.Panel}::UICorner`] = {
		CornerRadius = `${THEME_TOKENS.PanelCornerRadius}`,
	},
	[`.{tags.Panel}::UISizeConstraint`] = {
		MaxSize = `${THEME_TOKENS.PanelMaxSize}`,
	},

	[`.{tags.PanelHeader}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.PanelHeaderSize,
	},
	[`.{tags.PanelHeader}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.XLarge,
		PaddingRight = styleTokens.Padding.Medium,
	},
	[`.{tags.PanelHeader}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Medium,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},
	[`.{tags.PanelHeader} > TextLabel`] = {
		Font = styleTokens.TitleLarge.Font,
		TextSize = styleTokens.TitleLarge.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		Size = UDim2.fromScale(0, 1), -- Flex handles horizontal size
		LayoutOrder = 1,
	},

	[`.{tags.PanelHeader} > Frame`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1), -- Flex handles horizontal size
		LayoutOrder = 2,
	},
	[`.{tags.PanelHeader} > Frame::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.XXSmall,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	},

	[`.{tags.PanelToolsContainer}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = `${THEME_TOKENS.PanelAutomaticSize}`,
	},
	[`.{tags.PanelToolsContainer}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},
	[`.{tags.PanelToolsContainer}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.XLarge,
		PaddingRight = styleTokens.Padding.XLarge,
		PaddingBottom = styleTokens.Padding.XLarge,
	},
	[`.{tags.PanelToolsContainer}::UIListLayout, .{tags.ScrollFrame}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = styleTokens.Padding.XLarge,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},

	[`.{tags.ScrollFrame}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(1, 0),
	},
	[`.{tags.ScrollFrame}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},

	[`.{tags.ToolFrame}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ToolFrame}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.ToolTitle}`] = {
		Size = styleTokens.ToolTitleSize,
		BackgroundTransparency = 1,
	},
	[`.{tags.ToolTitle}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
	},
	[`.{tags.ToolTitle} > TextLabel`] = {
		FontFace = styleTokens.ToolTitleFont.Font,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		TextSize = styleTokens.ToolTitleFont.FontSize,
		AutomaticSize = Enum.AutomaticSize.XY,
	},

	-- HorizontalPillbar
	[`.{tags.HorizontalPillbar}`] = {
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.HorizontalPillbar}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.HorizontalPillbar}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.XSmall,
		PaddingRight = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
	},
	[`.{tags.HorizontalPillbar}::UIListLayout`] = {
		Padding = styleTokens.Padding.XSmall,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},

	[`.{tags.LargePillbarButton}, .{tags.SmallPillbarButton}`] = {
		BackgroundTransparency = 1,

		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.LargePillbarButton}::UICorner, .{tags.SmallPillbarButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.LargePillbarButton}::UIListLayout, .{tags.SmallPillbarButton}::UIListLayout`] = {
		-- Make sure the icon is centered; autosizing doesn't play nice with center anchor points :(
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},
	[`.{tags.LargePillbarButton}::UIPadding`] = {
		PaddingTop = styleTokens.LargePillbarVerticalPadding,
		PaddingLeft = styleTokens.LargePillbarHorizontalPadding,
		PaddingRight = styleTokens.LargePillbarHorizontalPadding,
		PaddingBottom = styleTokens.LargePillbarVerticalPadding,
	},
	[`.{tags.SmallPillbarButton}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.XSmall,
		PaddingRight = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
	},

	[`.{tags.LargePillbarButton} > ImageLabel`] = {
		Size = styleTokens.LargePillbarIconSize,
	},
	[`.{tags.SmallPillbarButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Small,
	},

	-- ColorPicker
	[`.{tags.ColorPicker}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ColorPicker}::UIListLayout`] = {
		Padding = styleTokens.Padding.XSmall,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.SatValPicker}`] = {
		Size = styleTokens.SatValPickerSize,
		AutoButtonColor = false,
		-- Background color styling is handled in the component
	},
	[`.{tags.SatValPicker}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.SatGradient}`] = {
		BackgroundColor3 = styleTokens.Colors.White,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	},
	[`.{tags.SatGradient}::UIGradient`] = {
		Transparency = NumberSequence.new(0, 1),
	},
	[`.{tags.SatGradient}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.ValGradient}`] = {
		BackgroundColor3 = styleTokens.Colors.Black,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
	},
	[`.{tags.ValGradient}::UIGradient`] = {
		Transparency = NumberSequence.new(1, 0),
		Rotation = 90,
	},
	[`.{tags.ValGradient}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.HuePicker}`] = {
		BackgroundColor3 = styleTokens.Colors.White,
		Size = styleTokens.HueSliderSize,
		AutoButtonColor = false,
	},
	[`.{tags.HuePicker}::UIGradient`] = {
		Color = styleTokens.Colors.RainbowGradient,
	},
	[`.{tags.HuePicker}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.ColorDot}`] = {
		Size = styleTokens.ColorDotSize,
		AnchorPoint = styleTokens.CenterAnchor,
		ZIndex = 100, -- Render above everything else
	},
	[`.{tags.ColorDot}::UIStroke`] = {
		Color = styleTokens.System_Contrast.Color3,
		Transparency = styleTokens.System_Contrast.Transparency,
		Thickness = styleTokens.ColorDotStrokeThickness,
	},
	[`.{tags.ColorDot}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	-- Slider
	[`.{tags.SliderFrame}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.SliderFrame}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Medium,
		PaddingBottom = styleTokens.Padding.Medium,
	},
	[`.{tags.SliderInput}`] = {
		Size = styleTokens.SliderInputSize,
		BackgroundTransparency = 1,
	},

	[`.{tags.SliderBar}`] = {
		Size = styleTokens.SliderBarSize,
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		-- Center in frame
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
	},
	[`.{tags.SliderBar}::UICorner, .{tags.SliderBar} > Frame::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.SliderBar} > Frame` --[[Progress bar]]] = {
		BackgroundColor3 = styleTokens.System_Contrast.Color3,
		BackgroundTransparency = styleTokens.System_Contrast.Transparency,
	},

	[`.{tags.SliderHandle}`] = {
		Size = styleTokens.SliderHandleSize,
		BackgroundColor3 = styleTokens.System_Contrast.Color3,
		BackgroundTransparency = styleTokens.System_Contrast.Transparency,
		-- Center on end of progress frame
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Rotation = 90, -- Bypass clip descendants in scrolling frames
	},
	[`.{tags.SliderHandle}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	-- Grid components
	[`.{tags.BaseTile}`] = {
		BackgroundColor3 = styleTokens.OverMedia_200.Color3,
		BackgroundTransparency = styleTokens.OverMedia_200.Transparency,
	},
	[`.{tags.BaseTile}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.BaseTile}::UISizeConstraint`] = {
		MinSize = styleTokens.BaseTileMinSize,
		MaxSize = styleTokens.BaseTileMaxSize,
	},
	[`.{tags.BaseTile}::UIAspectRatioConstraint`] = {
		AspectRatio = 1,
	},

	[`.{tags.BaseTileButton}`] = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},
	[`.{tags.BaseTileButton} > ImageLabel`] = {
		Size = UDim2.fromScale(1, 1),
	},

	[`.{tags.TileGrid}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.TileGrid}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XXSmall,
		PaddingBottom = styleTokens.Padding.XXSmall,
		PaddingLeft = styleTokens.Padding.XXSmall,
		PaddingRight = styleTokens.Padding.XXSmall,
	},
	[`.{tags.TileGrid}::UIGridLayout`] = {
		CellPadding = UDim2.new(styleTokens.Padding.Small, styleTokens.Padding.Small),
		CellSize = styleTokens.GridTileSize,
	},

	-- Editing Handles
	[`.{tags.MainHandle}`] = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		-- Size is determined by the tool, e.g. StickerTool.lua
		BackgroundTransparency = 1,
	},
	[`.{tags.MainHandle}::UIStroke`] = {
		Color = styleTokens.Colors.White,
		Transparency = 0,
		Thickness = styleTokens.MainHandleBorderThickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	},
	[`.{tags.MainHandle}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.SmallHandle}`] = {
		Size = styleTokens.SmallHandleSize,
		BackgroundColor3 = styleTokens.Colors.White,
		AnchorPoint = Vector2.new(0.5, 0.5),
	},
	[`.{tags.SmallHandle} > ImageLabel`] = {
		Size = styleTokens.SmallHandleIconSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	},
	[`.{tags.SmallHandle}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	-- Toolbar
	[`.{tags.Divider}`] = {
		Size = `${THEME_TOKENS.ToolbarDividerSize}`,
		BackgroundColor3 = styleTokens.Stroke_Default.Color,
		BackgroundTransparency = styleTokens.Stroke_Default.Transparency,
	},

	[`.{tags.ToolbarButton}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.ToolbarButtonSize,
	},
	[`.{tags.ToolbarButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Large,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
	},

	[`.{tags.ToolbarButtonGroup}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.ToolbarButtonGroup}::UIListLayout`] = {
		FillDirection = `${THEME_TOKENS.ToolbarFillDirection}`,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.ToolbarButtonGroup}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.Toolbar}`] = {
		BackgroundColor3 = styleTokens.Surface_100.Color3,
		BackgroundTransparency = styleTokens.Surface_100.Transparency,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = `${THEME_TOKENS.ToolbarAnchorPoint}`,
		Position = `${THEME_TOKENS.ToolbarPosition}`,
	},
	[`.{tags.Toolbar}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.XSmall,
		PaddingRight = styleTokens.Padding.XSmall,
	},
	[`.{tags.Toolbar}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.Toolbar}::UIStroke`] = {
		Color = styleTokens.Stroke_Default.Color,
		Transparency = styleTokens.Stroke_Default.Transparency,
		Thickness = 1,
	},
	[`.{tags.Toolbar}::UIListLayout`] = {
		Padding = styleTokens.Padding.XSmall,
		FillDirection = `${THEME_TOKENS.ToolbarFillDirection}`,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	-- Modal
	[`.{tags.ModalFrame}`] = {
		BackgroundColor3 = styleTokens.Surface_100.Color3,
		BackgroundTransparency = styleTokens.Surface_100.Transparency,

		-- Center on screen
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),

		-- Modal size is based on the number of buttons and is handled in the
		-- component.
		AutomaticSize = Enum.AutomaticSize.Y,
		-- Modals should appear over other UI elements in its screenGui
		ZIndex = 10,
	},
	[`.{tags.ModalFrame}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Large,
	},
	[`.{tags.ModalFrame}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XLarge,
		PaddingBottom = styleTokens.Padding.XLarge,
		PaddingLeft = styleTokens.Padding.XLarge,
		PaddingRight = styleTokens.Padding.XLarge,
	},
	[`.{tags.ModalFrame}::UIStroke`] = {
		Color = styleTokens.Stroke_Muted.Color,
		Transparency = styleTokens.Stroke_Muted.Transparency,
		Thickness = styleTokens.Stroke_Muted.Thickness,
	},
	[`.{tags.ModalFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.XLarge,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.ModalTextFrame}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.ModalTextFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.None,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.ModalTextFrame}::UIPadding`] = {
		PaddingRight = styleTokens.Padding.XXLarge,
	},

	[`.{tags.ModalTitle}, .{tags.ModalBody}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
	},
	[`.{tags.ModalTitle}`] = {
		Font = styleTokens.ModalTitleFont.Font,
		TextSize = styleTokens.ModalTitleFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.ModalBody}`] = {
		Font = styleTokens.ModalBodyFont.Font,
		TextSize = styleTokens.ModalBodyFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
	},

	[`.{tags.ButtonFrame}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ButtonFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},

	[`.{tags.DefaultButton}`] = {
		Size = styleTokens.ButtonSize,
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,

		Font = styleTokens.ButtonFont.Font,
		TextSize = styleTokens.ButtonFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.DefaultButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.DefaultButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Large,
		PaddingRight = styleTokens.Padding.Large,
	},

	[`.{tags.Overlay}`] = {
		BackgroundColor3 = styleTokens.Shadow.Color3,
		BackgroundTransparency = styleTokens.Shadow.Transparency,
		Size = UDim2.fromScale(1, 1),
		-- Overlay should be under other UI elements in its screenGui
		ZIndex = 1,
		-- While this is a button in order to sink input, it really shouldn't
		-- appear to do anything.
		Active = false,
		Selectable = false,
		AutoButtonColor = false,
	},

	-- Avatar Preview

	[`.{tags.SegmentedControl}`] = {
		BackgroundColor3 = styleTokens.Surface_100.Color3,
		BackgroundTransparency = styleTokens.Surface_100.Transparency,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.SegmentedControl}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.SegmentedControl}::UIPadding`] = {
		PaddingLeft = styleTokens.SegmentedControlPadding,
		PaddingRight = styleTokens.SegmentedControlPadding,
		PaddingTop = styleTokens.SegmentedControlPadding,
		PaddingBottom = styleTokens.SegmentedControlPadding,
	},
	[`.{tags.SegmentedControl}::UIListLayout`] = {
		Padding = styleTokens.Padding.XSmall,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.SegmentedControlButton}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.SegmentedControlButtonSize,

		Font = styleTokens.SegmentedControlButtonFont.Font,
		TextSize = styleTokens.SegmentedControlButtonFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,

		TextTruncate = Enum.TextTruncate.AtEnd,
	},
	[`.{tags.SegmentedControlButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},
	[`.{tags.SegmentedControlButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},

	[`.{tags.PreviewUIParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.PreviewUIParent}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.XXLarge,
		PaddingRight = styleTokens.Padding.XXLarge,
		PaddingBottom = styleTokens.Padding.XXLarge,
		PaddingTop = styleTokens.Padding.Medium,
	},
	[`.{tags.AvatarPreviewSwitcher}`] = {
		Position = `${THEME_TOKENS.AvatarPreviewPosition}`,
		AnchorPoint = `${THEME_TOKENS.AvatarPreviewAnchorPoint}`,
	},

	-- Progress bar
	[`.{tags.ProgressBarFrame}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.ProgressBarFrameSize,
	},
	[`.{tags.ProgressBarFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
	},

	[`.{tags.ProgressBarBackground}`] = {
		Size = styleTokens.ProgressBarBackgroundSize,
		BackgroundColor = styleTokens.Shift_200.Color3,
		BackgroundTransparency = styleTokens.Shift_200.Transparency,
	},
	[`.{tags.ProgressBarBackground}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},
	[`.{tags.ProgressBarBackground}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.ProgressBarLabel}`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		TextColor = styleTokens.Colors.ContentDefault,
		Font = styleTokens.ProgressLabelFont.Font,
		TextSize = styleTokens.ProgressLabelFont.FontSize,
	},

	[`.{tags.ProgressBarProgress}`] = {
		BackgroundColor = styleTokens.Colors.ContentEmphasis,
		-- Size is dynamic and set in the ProgressBar component
	},
	[`.{tags.ProgressBarProgress}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
}

-- These rules need to apply on top of other rules, so we will give them higher priority by generating them after the rest of the rules.
local HIGH_PRIORITY_RULE_MAP = {
	-- General
	[`.{tags.ButtonSelected}`] = {
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		AutoButtonColor = false,
		TextColor = styleTokens.Colors.ContentEmphasis,
	},

	[`.{tags.Hidden}`] = {
		Visible = false,
	},

	[`.{tags.EmphasisButton}`] = {
		BackgroundColor3 = styleTokens.ActionEmphasis.Color3,
		BackgroundTransparency = styleTokens.ActionEmphasis.Transparency,
	},

	[`.{tags.BuyButton}`] = {
		Size = styleTokens.BuyButtonSize,
		-- Position in bottom right of screen
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		Font = styleTokens.BuyButtonFont.Font,
		TextSize = styleTokens.BuyButtonFont.FontSize,
	},
}

local function createThemeTokens()
	local guiInset: Vector2 = GuiService:GetGuiInset()

	-- These must have the same set of tokens!
	local THEME_MOBILE_TOKENS = {
		[THEME_TOKENS.PanelSize] = UDim2.new(0, 320, 1, 0),
		[THEME_TOKENS.PanelCornerRadius] = UDim.new(0, 0),
		[THEME_TOKENS.PanelAutomaticSize] = Enum.AutomaticSize.None,
		[THEME_TOKENS.PanelAnchorPoint] = Vector2.new(0, 0),
		[THEME_TOKENS.PanelPosition] = UDim2.fromScale(0, 0),
		[THEME_TOKENS.UIParentPaddingTop] = UDim.new(0, 0),
		[THEME_TOKENS.UIParentPaddingRight] = UDim.new(0, 0),
		[THEME_TOKENS.PanelMaxSize] = Vector2.new(math.huge, math.huge), -- No max size
		-- Toolbar is horizontal, with vertical dividers
		[THEME_TOKENS.ToolbarDividerSize] = UDim2.fromOffset(
			styleTokens.Stroke_Default.Thickness,
			styleTokens.ToolbarButtonSize.Y.Offset
		),
		[THEME_TOKENS.ToolbarFillDirection] = Enum.FillDirection.Horizontal,
		[THEME_TOKENS.ToolbarAnchorPoint] = Vector2.new(0.5, 1), -- Bottom center
		[THEME_TOKENS.ToolbarPosition] = UDim2.fromScale(0.5, 1),
		[THEME_TOKENS.ToolbarParentPaddingBottom] = styleTokens.Padding.XXLarge,
		[THEME_TOKENS.ToolbarLayoutOrder] = 0,
		[THEME_TOKENS.PanelLayoutOrder] = 1,
		[THEME_TOKENS.ToolbarParentFlexFill] = Enum.UIFlexMode.Fill,
		[THEME_TOKENS.PanelParentFlexFill] = Enum.UIFlexMode.None,

		[THEME_TOKENS.AvatarPreviewAnchorPoint] = Vector2.new(0.5, 1), -- Bottom center
		[THEME_TOKENS.AvatarPreviewPosition] = UDim2.fromScale(0.5, 1),
		[THEME_TOKENS.CoreUIVisibilityWithPanel] = false, -- Hide buttons when behind panel
		[THEME_TOKENS.LocalMenuRightPadding] = styleTokens.Padding.XSmall,
	}

	local THEME_DESKTOP_TOKENS = {
		[THEME_TOKENS.PanelSize] = UDim2.fromOffset(320, 0),
		[THEME_TOKENS.PanelCornerRadius] = styleTokens.Radius.Medium,
		[THEME_TOKENS.PanelAutomaticSize] = Enum.AutomaticSize.Y,
		[THEME_TOKENS.PanelAnchorPoint] = Vector2.new(1, 0), -- Top right
		[THEME_TOKENS.PanelPosition] = UDim2.fromScale(1, 0),
		[THEME_TOKENS.UIParentPaddingTop] = UDim.new(0, guiInset.Y) + styleTokens.Padding.Medium,
		[THEME_TOKENS.UIParentPaddingRight] = styleTokens.ToolbarParentPadding,
		[THEME_TOKENS.PanelMaxSize] = styleTokens.PanelMaxSize,
		-- Toolbar is vertical, with horizontal dividers
		[THEME_TOKENS.ToolbarDividerSize] = UDim2.fromOffset(
			styleTokens.ToolbarButtonSize.X.Offset,
			styleTokens.Stroke_Default.Thickness
		),
		[THEME_TOKENS.ToolbarFillDirection] = Enum.FillDirection.Vertical,
		[THEME_TOKENS.ToolbarAnchorPoint] = Vector2.new(0, 0),
		[THEME_TOKENS.ToolbarPosition] = UDim2.fromScale(0, 0),
		[THEME_TOKENS.ToolbarParentPaddingBottom] = UDim.new(0, 0),
		[THEME_TOKENS.ToolbarLayoutOrder] = 1,
		[THEME_TOKENS.PanelLayoutOrder] = 0,
		[THEME_TOKENS.ToolbarParentFlexFill] = Enum.UIFlexMode.None,
		[THEME_TOKENS.PanelParentFlexFill] = Enum.UIFlexMode.Fill,

		[THEME_TOKENS.AvatarPreviewAnchorPoint] = Vector2.new(1, 0), -- Top right
		[THEME_TOKENS.AvatarPreviewPosition] = UDim2.fromScale(1, 0),
		[THEME_TOKENS.CoreUIVisibilityWithPanel] = true,
		[THEME_TOKENS.LocalMenuRightPadding] = styleTokens.Padding.XXLarge,
	}

	return THEME_MOBILE_TOKENS, THEME_DESKTOP_TOKENS
end

local function createTheme(name, tokens)
	local themeSheet = Instance.new("StyleSheet")
	themeSheet.Name = name

	for label, value in tokens do
		themeSheet:SetAttribute(label, value)
	end

	themeSheet.Parent = ReplicatedStorage

	return themeSheet
end

function Style.new()
	local self = {}
	setmetatable(self, Style)

	self.coreSheet = Instance.new("StyleSheet")
	self.coreSheet.Name = "AvatarCreationStyleSheet"
	self.coreSheet.Parent = ReplicatedStorage

	local mobileTokens, desktopToken = createThemeTokens()

	self.phoneTheme = createTheme("MobileTheme", mobileTokens)
	self.desktopTheme = createTheme("DesktopTheme", desktopToken)

	self.themeDerive = Instance.new("StyleDerive")
	self.themeDerive.Parent = self.coreSheet
	self.themeDerive.StyleSheet = self.phoneTheme

	self:GenerateRules()

	return self
end

function Style:Destroy()
	self.coreSheet:Destroy()
end

function Style:LinkGui(screenGui: ScreenGui)
	local styleLink = Instance.new("StyleLink")
	styleLink.Parent = screenGui
	styleLink.StyleSheet = self.coreSheet

	local screenSizeChangedSignal = screenGui:GetPropertyChangedSignal("AbsoluteSize")
	screenSizeChangedSignal:Connect(function()
		self:UpdateTheme(screenGui)
	end)
	self:UpdateTheme(screenGui)
end

function Style:UpdateTheme(screenGui: ScreenGui)
	if Utils.getIsMobile(screenGui) then
		self.themeDerive.StyleSheet = self.phoneTheme
	else
		self.themeDerive.StyleSheet = self.desktopTheme
	end
end

function Style:AddRule(selector: string, properties: {}, priority: number?)
	local rule = Instance.new("StyleRule")
	rule.Parent = self.coreSheet
	rule.Selector = selector
	rule.Priority = if priority then priority else 0
	rule.Name = selector
	rule:SetProperties(properties)
end

function Style:GenerateRules()
	for selector, props in RULE_MAP do
		self:AddRule(selector, props)
	end

	for selector, props in HIGH_PRIORITY_RULE_MAP do
		self:AddRule(selector, props, 100)
	end
end

return Style
