--[[
	Defines style properties for various UI components using CSS-like selectors.
	The rules are defined across multiple tables based on the type of component
	they apply to.

	If you are adding an additional rule table, make sure to update the RULES
	table so it is included in the style generation process.
]]
local GuiService = game:GetService("GuiService")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleThemes = require(Style:WaitForChild("StyleThemes"))

local tags = StyleConsts.tags
local styleTokens = StyleConsts.styleTokens
local fontTokens = StyleConsts.fontTokens
local themeTokens = StyleThemes.themeTokens

-- Rules that, generally, we want to apply to all components for convenience.
local DEFAULT_RULES = {
	-- General
	["TextLabel"] = {
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
	},
	-- Remove borders by default
	["Frame, ImageButton, TextButton, ScrollingFrame"] = {
		BorderSizePixel = 0,
	},
}

-- Components with these tags are typically parents of lots of UI elements, and
-- define the overall layout of the UI.
local UI_LAYOUT_RULES = {
	-- Base UI
	-- Base UI only contains the buy button; this just defines padding for it.
	[`.{tags.BaseUI}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XXLarge,
		PaddingRight = `${themeTokens.LocalMenuRightPadding}`,
	},
	-- Defines whether BaseUI elements are visible when a panel is open
	[`.{tags.CoreUIWithOpenPanel}`] = {
		Visible = `${themeTokens.CoreUIVisibilityWithPanel}`,
	},

	-- UI Parent
	-- Contains the parent frames for toolbar and panels, and helps define
	-- overall layout of the UI based on the theme.
	[`.{tags.UIParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, 0),
	},
	[`.{tags.UIParent}::UIPadding`] = {
		PaddingTop = `${themeTokens.UIParentPaddingTop}`,
		PaddingRight = `${themeTokens.UIParentPaddingRight}`,
	},
	[`.{tags.UIParent}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.Small,
	},

	-- Toolbar Parent
	-- Contains the bottom toolbar, defines layout based on the theme.
	[`.{tags.ToolbarParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = `${themeTokens.ToolbarLayoutOrder}`,
	},
	[`.{tags.ToolbarParent}::UIPadding`] = {
		PaddingBottom = `${themeTokens.ToolbarParentPaddingBottom}`,
	},
	[`.{tags.ToolbarParent}::UIFlexItem`] = {
		FlexMode = `${themeTokens.ToolbarParentFlexFill}`,
	},

	-- Panel Parent
	-- Contains side panels, defines layout based on the theme.
	[`.{tags.PanelParent}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = `${themeTokens.PanelLayoutOrder}`,
	},
	[`.{tags.PanelParent}::UIFlexItem`] = {
		FlexMode = `${themeTokens.PanelParentFlexFill}`,
	},

	-- Avatar Preview UI
	-- PreviewUIParent tag aligns items on the screen
	[`.{tags.PreviewUIParent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.PreviewUIParent}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.XXLarge,
		PaddingRight = styleTokens.Padding.XXLarge,
		PaddingBottom = styleTokens.Padding.XXLarge,
		PaddingTop = if GuiService:IsTenFootInterface()
			then styleTokens.Padding.Medium + styleTokens.TopBarHeight
			else styleTokens.Padding.Medium,
	},
	-- AvatarPreviewSwitcher tag specifies where on the screen the segmented
	-- control should go.
	[`.{tags.AvatarPreviewSwitcher}`] = {
		Position = `${themeTokens.AvatarPreviewPosition}`,
		AnchorPoint = `${themeTokens.AvatarPreviewAnchorPoint}`,
	},
}

-- Rules for the local menu (top right buttons for reset, preview and exit).
local LOCAL_MENU_RULES = {
	[`.{tags.LocalMenu}`] = {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1), -- Bottom right
		Position = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.LocalMenu}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XXSmall,
		PaddingRight = `${themeTokens.LocalMenuRightPadding}`,
	},
	[`.{tags.LocalMenu}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.None,
	},

	[`.{tags.LocalMenuConsole}`] = {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0), -- Top right
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(0, styleTokens.TopBarHeight.Offset),
		AutomaticSize = Enum.AutomaticSize.X,
	},
	[`.{tags.LocalMenuConsole}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Medium,
		PaddingRight = `${themeTokens.LocalMenuRightPadding}`,
	},
	[`.{tags.LocalMenuConsole}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.None,
	},

	[`.{tags.LocalMenuButtonGroup}`] = {
		BackgroundColor3 = styleTokens.OverMedia_0.Color3,
		BackgroundTransparency = styleTokens.OverMedia_0.Transparency,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.LocalMenuButtonGroup}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.XSmall,
		PaddingRight = styleTokens.Padding.XSmall,
	},
	[`.{tags.LocalMenuButtonGroup}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.LocalMenuButtonGroup}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.None,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.LocalMenuButton}`] = {
		Size = styleTokens.LocalMenuButtonSize,
		BackgroundTransparency = 1,
	},
	[`.{tags.LocalMenuButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.LocalMenuButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Small,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
	},
}

-- Rules for panels (sidesheets) which host the various editing tools. These
-- rules include styling for things like the scrollframe and tool containers
-- inside the panel.
local PANEL_RULES = {
	-- Panel
	[`.{tags.Panel}`] = {
		BackgroundColor3 = styleTokens.Surface_0.Color3,
		BackgroundTransparency = styleTokens.Surface_0.Transparency,
		Size = `${themeTokens.PanelSize}`,
		AutomaticSize = `${themeTokens.PanelAutomaticSize}`,
		AnchorPoint = `${themeTokens.PanelAnchorPoint}`,
		Position = `${themeTokens.PanelPosition}`,
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
		CornerRadius = `${themeTokens.PanelCornerRadius}`,
	},
	[`.{tags.Panel}::UISizeConstraint`] = {
		MaxSize = `${themeTokens.PanelMaxSize}`,
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
		FontFace = fontTokens.TitleLarge.Font,
		TextSize = fontTokens.TitleLarge.FontSize,
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
		AutomaticSize = `${themeTokens.PanelAutomaticSize}`,
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
		Padding = styleTokens.Padding.Large,
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
		FontFace = fontTokens.ToolTitleFont.Font,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		TextSize = fontTokens.ToolTitleFont.FontSize,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
}

-- Rules for color picker and sub-components, including the saturation/value
-- picker, hue picker, opacity picker, and the color dot.
local COLOR_PICKER_RULES = {
	-- ColorPicker
	[`.{tags.ColorPicker}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ColorPicker}::UIListLayout`] = {
		Padding = if not GuiService:IsTenFootInterface()
			then styleTokens.Padding.Small
			else styleTokens.Padding.XXLarge,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.SatValPicker}`] = {
		Size = styleTokens.SatValPickerSize,
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
		Rotation = 90, -- Bypass clip descendants in scrolling frames
	},
	[`.{tags.ColorDot}::UIStroke`] = {
		Color = styleTokens.System_Contrast.Color3,
		Transparency = styleTokens.System_Contrast.Transparency,
		Thickness = styleTokens.ColorDotStrokeThickness,
	},
	[`.{tags.ColorDot}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.OpacityPicker}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.HueSliderSize,
		Image = StyleConsts.uiImages.OpacityPicker,
	},
	[`.{tags.OpacityPicker}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.OpacityOverlay}`] = {
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.OpacityOverlay}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	-- Since the gradient color is dynamically styled in the color picker component, we don't use a psuedoinstance
	[`.{tags.OpacityGradient}`] = {
		Transparency = NumberSequence.new(1, 0),
	},
}

-- Rules for the toolbar at the bottom/side of the screen.
local TOOLBAR_RULES = {
	[`.{tags.Divider}`] = {
		Size = `${themeTokens.ToolbarDividerSize}`,
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
		FillDirection = `${themeTokens.ToolbarFillDirection}`,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.ToolbarButtonGroup}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.Toolbar}`] = {
		BackgroundColor3 = styleTokens.Surface_100.Color3,
		BackgroundTransparency = styleTokens.Surface_100.Transparency,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = `${themeTokens.ToolbarAnchorPoint}`,
		Position = `${themeTokens.ToolbarPosition}`,
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
		FillDirection = `${themeTokens.ToolbarFillDirection}`,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
}

-- Rules for modals (pop-ups) requiring interaction, including overlay.
local MODAL_RULES = {
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
		Padding = styleTokens.Padding.XSmall,
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
		FontFace = fontTokens.ModalTitleFont.Font,
		TextSize = fontTokens.ModalTitleFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.ModalBody}`] = {
		FontFace = fontTokens.ModalBodyFont.Font,
		TextSize = fontTokens.ModalBodyFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
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
}

-- Rules for the tile grid component, which is used for sticker/kitbash selection.
local GRID_RULES = {
	[`.{tags.BaseTile}`] = {
		BackgroundColor3 = styleTokens.OverMedia_200.Color3,
		BackgroundTransparency = styleTokens.OverMedia_200.Transparency,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.BaseTile}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
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
}

-- Rules for the item selector, used for selecting things like stickers on
-- different layers. This includes the counter and mini base tiles.
local ITEM_SELECTOR_RULES = {
	[`.{tags.ItemSelectorFrame}`] = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ItemSelectorFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},

	[`.{tags.ItemSelectorFlexFrame}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.ItemSelectorFlexFrame}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},

	[`.{tags.ItemSelectorScrollFrame}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		AutomaticSize = Enum.AutomaticSize.Y,

		-- ScrollBar
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = styleTokens.Shift_400.Color3,
		ScrollBarImageTransparency = styleTokens.Shift_400.Transparency,
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,

		TopImage = styleTokens.ScrollBarImages.Top,
		MidImage = styleTokens.ScrollBarImages.Middle,
		BottomImage = styleTokens.ScrollBarImages.Bottom,
	},
	[`.{tags.ItemSelectorScrollFrame}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XSmall,
	},

	[`.{tags.CounterLabel}`] = {
		FontFace = fontTokens.CounterLabelFont.Font,
		TextSize = fontTokens.CounterLabelFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.CounterFrame}`] = {
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},

	[`.{tags.MiniBaseTileGroup}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.MiniBaseTileGroupSize,
		AutomaticSize = Enum.AutomaticSize.X,
	},
	[`.{tags.MiniBaseTileGroup}::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.MiniBaseTileSelected}::UIStroke`] = {
		Color = styleTokens.System_Contrast.Color3,
		Transparency = styleTokens.System_Contrast.Transparency,
		Thickness = styleTokens.Stroke_Default.Thickness,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
	},
}

-- Rules for various types of buttons.
local BUTTON_RULES = {
	[`.{tags.MediumIconButton}`] = {
		Size = styleTokens.IconButtonSize,
		BackgroundTransparency = 1,
	},

	[`.{tags.MediumIconButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Large,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
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

		FontFace = fontTokens.ButtonFont.Font,
		TextSize = fontTokens.ButtonFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.DefaultButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.DefaultButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Large,
		PaddingRight = styleTokens.Padding.Large,
	},
}

-- Rules for the horizontal pillbar component, which is used in tool options.
local HORIZONTAL_PILLBAR_RULES = {
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
}

-- Rules for the toggle component, used for reflectivity.
local TOGGLE_RULES = {
	[`.{tags.ToggleFrame}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	},
	[`.{tags.ToggleFrame}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.Small,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	},

	[`.{tags.TogglePill}`] = {
		Size = styleTokens.TogglePillSize,
		Image = StyleConsts.uiImages.ToggleOff,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},

	[`.{tags.ToggleLabel}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		FontFace = fontTokens.ToolTitleFont.Font,
		TextSize = fontTokens.ToolTitleFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
	},
}

-- Rules for the progress bar component, used to count a max number of items.
local PROGRESS_BAR_RULES = {
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
		FontFace = fontTokens.CounterLabelFont.Font,
		TextSize = fontTokens.CounterLabelFont.FontSize,
	},

	[`.{tags.ProgressBarProgress}`] = {
		BackgroundColor = styleTokens.Colors.ContentEmphasis,
		-- Size is dynamic and set in the ProgressBar component
	},
	[`.{tags.ProgressBarProgress}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
}

-- Rules for the basic slider, used for things like size and spacing.
local SLIDER_RULES = {
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
}

-- Rules for the segmented control component, similar to the pillbar, but
-- with slightly different styling. Used for avatar preview.
local SEGMENTED_CONTROL_RULES = {
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

		FontFace = fontTokens.SegmentedControlButtonFont.Font,
		TextSize = fontTokens.SegmentedControlButtonFont.FontSize,
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
}

-- Rules for editing handles, such as for adjusting sticker size and rotation.
local EDITING_HANDLE_RULES = {
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
}

-- These rules need to apply on top of other rules, so we will give them higher
-- priority by generating them after the rest of the rules.
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
		FontFace = fontTokens.BuyButtonFont.Font,
		TextSize = fontTokens.BuyButtonFont.FontSize,
	},
}

local RULES = {
	UI_LAYOUT_RULES,

	LOCAL_MENU_RULES,
	PANEL_RULES,
	COLOR_PICKER_RULES,
	TOOLBAR_RULES,
	MODAL_RULES,
	GRID_RULES,
	ITEM_SELECTOR_RULES,

	BUTTON_RULES,
	HORIZONTAL_PILLBAR_RULES,
	TOGGLE_RULES,
	PROGRESS_BAR_RULES,
	SLIDER_RULES,
	SEGMENTED_CONTROL_RULES,
	EDITING_HANDLE_RULES,
}

function compileStandardRules()
	local compiledRules = {}

	for _, ruleSet in ipairs(RULES) do
		for selector, properties in pairs(ruleSet) do
			compiledRules[selector] = properties
		end
	end

	return compiledRules
end

return {
	lowPriorityRules = DEFAULT_RULES,
	standardRules = compileStandardRules(),
	highPriorityRules = HIGH_PRIORITY_RULE_MAP,
}
