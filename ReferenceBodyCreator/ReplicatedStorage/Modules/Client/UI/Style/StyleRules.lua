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
	[`.{tags.ScrollFrame}, .{tags.ItemSelectorScrollFrame}`] = {
		ScrollBarThickness = styleTokens.ScrollBarThickness,
		ScrollBarImageColor3 = styleTokens.Shift_400.Color3,
		ScrollBarImageTransparency = styleTokens.Shift_400.Transparency,
		TopImage = styleTokens.ScrollBarImages.Top,
		MidImage = styleTokens.ScrollBarImages.Middle,
		BottomImage = styleTokens.ScrollBarImages.Bottom,
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

-- Rules for the local menu (top right editing controls).
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
		Size = styleTokens.IconSize.Medium,
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
		PaddingRight = styleTokens.Padding.Small,
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
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(1, 0),
	},
	[`.{tags.ScrollFrame}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},
	[`.{tags.ScrollFrame}::UIPadding`] = {
		PaddingRight = styleTokens.Padding.Small,
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

local BANNER_RULES = {
	[`.{tags.Banner}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.Banner}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.Banner}::UIStroke`] = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		Color = styleTokens.Stroke_Default.Color,
		Transparency = styleTokens.Stroke_Default.Transparency,
		Thickness = styleTokens.Stroke_Default.Thickness,
	},
	[`.{tags.Banner}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Medium,
		PaddingBottom = styleTokens.Padding.Medium,
		PaddingLeft = styleTokens.Padding.Medium,
		PaddingRight = styleTokens.Padding.Medium,
	},
	[`.{tags.Banner}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.Small,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},
	[`.{tags.Banner}.{tags.BannerEmphasis}`] = {
		BackgroundColor3 = styleTokens.Shift_200.Color3,
		BackgroundTransparency = styleTokens.BannerEmphasisTransparency,
	},
	[`.{tags.Banner}.{tags.BannerCompact}`] = {
		Size = UDim2.new(1, 0, 0, styleTokens.BannerCompactHeight),
		AutomaticSize = Enum.AutomaticSize.None,
	},
	[`.{tags.Banner} > #Leading`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.BannerLeadingSize,
		LayoutOrder = 1,
	},
	[`.{tags.Banner} > #Leading > GuiObject`] = {
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.BannerContent}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	},
	[`.{tags.BannerContent}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},
	[`.{tags.BannerContent}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.XXSmall,
	},
	[`.{tags.BannerContent} > TextLabel`] = {
		Size = UDim2.new(1, 0, 0, styleTokens.BannerTextHeight),
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = false,
	},
	[`.{tags.BannerContent} > #Title`] = {
		FontFace = fontTokens.TitleSmall.Font,
		TextSize = fontTokens.TitleSmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		LayoutOrder = 1,
	},
	[`.{tags.BannerContent} > #Description`] = {
		FontFace = fontTokens.BodySmall.Font,
		TextSize = fontTokens.BodySmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentMuted,
		LayoutOrder = 2,
	},
	[`.{tags.BannerAction}`] = {
		LayoutOrder = 3,
	},
}

-- Rules for color picker and sub-components, including the saturation/value
-- picker, hue picker, opacity picker, and the color dot.
local colorDotPadding = UDim.new(0, styleTokens.ColorDotSize.X.Offset / 2 + styleTokens.ColorDotStrokeThickness)
local COLOR_PICKER_RULES = {
	-- ColorPicker
	[`.{tags.ColorPicker}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.ColorPicker}::UIPadding`] = {
		-- Keep edge-positioned dots and their outlines inside the scrolling viewport.
		PaddingLeft = colorDotPadding,
		PaddingRight = colorDotPadding,
		PaddingTop = colorDotPadding,
		PaddingBottom = colorDotPadding,
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
		BackgroundColor3 = styleTokens.Colors.White,
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
	-- Controls whether the toolbar stays visible while the stamp action bar is open.
	[`.{tags.ToolbarWithStampActionBar}`] = {
		Visible = `${themeTokens.ToolbarVisibleWithStampActionBar}`,
	},
}

-- Rules for the controls shown while positioning a stamp.
local STAMP_ACTION_BAR_RULES = {
	[`.{tags.StampActionBar}`] = {
		BackgroundColor3 = styleTokens.Surface_0.Color3,
		BackgroundTransparency = styleTokens.Surface_0.Transparency,
		AnchorPoint = `${themeTokens.StampActionBarAnchorPoint}`,
		Position = `${themeTokens.StampActionBarPosition}`,
		Size = UDim2.new(
			1,
			-(styleTokens.PanelSize.X.Offset + styleTokens.Padding.XXLarge.Offset * 4),
			0,
			styleTokens.ToolbarButtonSize.Y.Offset
		),
		ZIndex = 20,
	},
	[`.{tags.StampActionBar}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Small,
		PaddingBottom = styleTokens.Padding.Small,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.StampActionBar}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.StampActionBar}::UISizeConstraint`] = {
		MaxSize = styleTokens.StampActionBarMaxSize,
	},

	[`.{tags.StampActionBar} > Frame`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.StampActionBar} > Frame::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},

	[`.{tags.StampActionBarButton}`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		FontFace = fontTokens.ButtonFont.Font,
		TextSize = fontTokens.ButtonFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.StampActionBarButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},
	[`.{tags.StampActionBarButton}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
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
		Selectable = false,
		AutoButtonColor = false,
	},

	[`.{tags.ModalMiddleContent}`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	},
	[`.{tags.ModalMiddleContent}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.Padding.Large,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},
	[`.{tags.ModalMiddleContent} > TextLabel`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		FontFace = fontTokens.ButtonFont.Font,
		TextSize = fontTokens.ButtonFont.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.ModalTwoStateIconButton}`] = {
		Size = styleTokens.IconSize.Large,
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		AutoButtonColor = false,
	},
	[`.{tags.ModalTwoStateIconButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.ModalTwoStateIconButton} > ImageLabel`] = {
		Size = UDim2.fromScale(1, 1),
	},
}

-- Rules for the tile grid component, which is used for sticker/kitbash selection.
local GRID_RULES = {
	[`.{tags.BaseTile}`] = {
		BackgroundColor3 = styleTokens.OverMedia_200.Color3,
		BackgroundTransparency = styleTokens.OverMedia_200.Transparency,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.BaseTile}::UICorner, .{tags.BaseTileButton} >> ImageLabel::UICorner, .{tags.BaseTileButton} >> ViewportFrame::UICorner`] = {
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
	[`.{tags.BaseTileButton} > ImageLabel, .{tags.BaseTileButton} > ViewportFrame`] = {
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.BaseTileButton} > ViewportFrame`] = {
		BackgroundTransparency = 1,
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
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
}

-- Rules for the swatch bar component, used for saving and selecting colors.
local SWATCH_BAR_RULES = {
	[`.{tags.SwatchBar}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, styleTokens.SwatchSize.Y.Offset),
		ClipsDescendants = true,
	},

	-- UIGridLayout is used dynamically so a psuedoinstance doesn't work here.
	[`.{tags.SwatchBar} > UIGridLayout`] = {
		CellSize = styleTokens.SwatchSize,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.SwatchCanvas}`] = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	},
	[`.{tags.SwatchCanvas}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
	},

	[`.{tags.Swatch}`] = {
		Image = StyleConsts.uiImages.SwatchTransparencyBackground,
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.Swatch} > Frame`] = {
		Size = UDim2.fromScale(0.5, 1),
	},

	[`.{tags.SwatchOpacityHalf}`] = {
		Position = UDim2.fromScale(0.5, 0),
	},

	[`.{tags.SwatchBarPlusButton}`] = {
		Size = UDim2.fromScale(1, 1), -- grid layout handles sizing
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},
	[`.{tags.SwatchBarPlusButton} > ImageLabel`] = {
		Size = UDim2.fromScale(1, 1),
	},
	[`.{tags.SwatchBarPlusButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Small,
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
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	},
	[`.{tags.ItemSelectorScrollFrame}::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.XSmall,
	},

	[`.{tags.CounterLabel}`] = {
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
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

-- Rules for the brush picker: a horizontally scrolling row of captioned brush
-- preview tiles with a single-selection highlight.
local BRUSH_PICKER_RULES = {
	[`.{tags.BrushPickerScroll}`] = {
		BackgroundTransparency = 1,
		-- Hard code this to fix clipping of the captions when at the bottom of scrolling frame
		Size = UDim2.new(
			1,
			0,
			0,
			styleTokens.BrushPickerThumbnailSize.Y.Offset
				+ styleTokens.Padding.XXSmall.Offset
				+ styleTokens.BrushPickerCaptionHeight
		),
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.fromOffset(0, 0),

		-- ScrollBar
		ScrollBarThickness = 0,
	},
	[`.{tags.BrushPickerScroll}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.BrushPickerTile}`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.BrushPickerThumbnailSize,
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.BrushPickerTile}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = styleTokens.Padding.XXSmall,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	},

	[`.{tags.BrushPickerThumbnail}`] = {
		Size = styleTokens.BrushPickerThumbnailSize,
		BackgroundColor3 = styleTokens.OverMedia_200.Color3,
		BackgroundTransparency = styleTokens.OverMedia_200.Transparency,
	},
	[`.{tags.BrushPickerThumbnail}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},

	[`.{tags.BrushPickerSelectionOutline}`] = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
	},
	[`.{tags.BrushPickerSelectionOutline}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},

	[`.{tags.BrushPickerCaption}`] = {
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Center,
	},

	-- Scroll arrows housed in the tool title bar (top right of the picker).
	[`.{tags.BrushPickerArrows}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.BrushPickerArrows}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.XSmall,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},

	[`.{tags.BrushPickerArrows} > TextButton`] = {
		Size = styleTokens.IconSize.Large,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},
	[`.{tags.BrushPickerArrows} > TextButton > ImageLabel`] = {
		Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = styleTokens.Colors.ContentDefault,
		ImageTransparency = 0,
	},

	[`.{tags.BrushPickerCardTinted}`] = {
		ImageColor3 = styleTokens.Shift_400.Color3,
		ImageTransparency = styleTokens.BrushPickerTintTransparency,
	},
}

-- Rules for the dropdown popover menu that opens under an anchor button.
local DROPDOWN_MENU_RULES = {
	-- The popover anchored under the button.
	[`.{tags.DropdownMenu}`] = {
		BackgroundColor3 = styleTokens.Surface_200.Color3,
		BackgroundTransparency = styleTokens.Surface_200.Transparency,
		Size = styleTokens.DropdownMenuSize,
		AutomaticSize = Enum.AutomaticSize.Y,
		-- Render above the overlay and the rest of the panel UI.
		ZIndex = 10,
	},
	[`.{tags.DropdownMenu}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Large,
	},
	-- Roblox UIStroke is all-sides; the design's border-top reads as the seam
	-- under the button.
	[`.{tags.DropdownMenu}::UIStroke`] = {
		Color = styleTokens.Stroke_Default.Color,
		Transparency = styleTokens.Stroke_Default.Transparency,
		Thickness = styleTokens.Stroke_Default.Thickness,
	},
	-- Horizontal padding insetting the header and rows from the menu edges.
	[`.{tags.DropdownMenu}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.Medium,
		PaddingBottom = styleTokens.Padding.Medium,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.DropdownMenu}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	-- Header text row spanning the menu width.
	[`.{tags.DropdownMenuTitle}`] = {
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
		Size = styleTokens.DropdownMenuRowSize,
	},
	[`.{tags.DropdownMenuTitle}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Medium,
		PaddingRight = styleTokens.Padding.Medium,
	},

	-- Each selectable row: transparent so the menu surface shows through, with a
	-- rounded highlight on hover. The fixed height gives the highlight room
	-- rather than shrink-wrapping the content.
	[`.{tags.DropdownMenuOption}`] = {
		Size = styleTokens.DropdownMenuRowSize,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},
	[`.{tags.DropdownMenuOption}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.DropdownMenuOption}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Medium,
		PaddingRight = styleTokens.Padding.Medium,
	},
	[`.{tags.DropdownMenuOption}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		-- Center the content line within the row height.
		VerticalAlignment = Enum.VerticalAlignment.Center,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
	},

	-- Left-aligned icon + name group inside a row.
	[`.{tags.DropdownMenuOptionInfo}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.DropdownMenuOptionInfo}::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
	},
	[`.{tags.DropdownMenuOptionInfo} > ImageLabel`] = {
		Size = styleTokens.IconSize.Medium,
		BackgroundTransparency = 1,
	},
	[`.{tags.DropdownMenuOptionInfo} > TextLabel`] = {
		FontFace = fontTokens.BodyMedium.Font,
		TextSize = fontTokens.BodyMedium.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		AutomaticSize = Enum.AutomaticSize.XY,
	},

	-- Right-aligned text for a row.
	[`.{tags.DropdownMenuOptionRight}`] = {
		FontFace = fontTokens.BodyMedium.Font,
		TextSize = fontTokens.BodyMedium.FontSize,
		TextColor3 = styleTokens.Colors.ContentDefault,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextXAlignment = Enum.TextXAlignment.Right,
	},

	-- Footer text.
	[`.{tags.DropdownMenuFooter}`] = {
		FontFace = fontTokens.BodySmall.Font,
		TextSize = fontTokens.BodySmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentMuted,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	-- Align the footer's left edge with the header and rows.
	[`.{tags.DropdownMenuFooter}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Medium,
		PaddingRight = styleTokens.Padding.Medium,
	},
}

-- Rules for the GroupCard: the empty-state card shown in a makeup category
-- section before any group exists. Icon, primary label, smaller secondary
-- label, and an action button stacked vertically and centered.
local GROUP_CARD_RULES = {
	-- Section, title row, body, and card all fill width and grow to fit content.
	[`.{tags.MakeupSection}, .{tags.MakeupSectionTitle}, .{tags.MakeupSectionBody}, .{tags.GroupCard}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.MakeupSection}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.MakeupSectionTitle}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},
	[`.{tags.MakeupSectionTitle} > TextLabel`] = {
		FontFace = fontTokens.ToolTitleFont.Font,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		TextSize = fontTokens.ToolTitleFont.FontSize,
		AutomaticSize = Enum.AutomaticSize.XY,
	},

	[`.{tags.MakeupSectionBody}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},
	-- Inset on all sides so the card's outward UIStroke isn't clipped by the
	-- scrolling frame (including the last card's bottom border at the canvas edge).
	[`.{tags.MakeupSectionBody}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.XSmall,
		PaddingRight = styleTokens.Padding.XSmall,
	},

	[`.{tags.GroupCard}::UIStroke`] = {
		Color = styleTokens.Colors.ContentEmphasis,
		Transparency = styleTokens.GroupCardStrokeTransparency,
		Thickness = 1,
	},
	[`.{tags.GroupCard}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.GroupCard}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XLarge,
		PaddingBottom = styleTokens.Padding.Large,
	},
	[`.{tags.GroupCard}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	[`.{tags.GroupCardIconContainer}`] = {
		Size = styleTokens.GroupCardIconContainerSize,
		BackgroundTransparency = 1,
	},
	[`.{tags.GroupCardIconContainer}::UIAspectRatioConstraint`] = {
		AspectRatio = styleTokens.GroupCardIconAspectRatio,
		AspectType = Enum.AspectType.FitWithinMaxSize,
		DominantAxis = Enum.DominantAxis.Width,
	},
	[`.{tags.GroupCardIconFrame}`] = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	},
	[`.{tags.GroupCardIcon}`] = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	},
	[`.{tags.GroupCardTitle}`] = {
		FontFace = fontTokens.BodyMedium.Font,
		TextSize = fontTokens.BodyMedium.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.GroupCardSubtitle}`] = {
		FontFace = fontTokens.BodySmall.Font,
		TextSize = fontTokens.BodySmall.FontSize,
		TextColor3 = styleTokens.Colors.ContentMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.GroupCard} > .{tags.DefaultButton}`] = {
		Size = styleTokens.ButtonSize,
		AutomaticSize = Enum.AutomaticSize.X,
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
	[`.{tags.AddItemButton}`] = {
		TextTransparency = 0,
		Active = true,
		Interactable = true,
		Selectable = true,
		AutoButtonColor = true,
	},
	[`.{tags.DefaultButton}.{tags.SmallButton}`] = {
		Size = styleTokens.SmallButtonSize,
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
	},
	[`.{tags.DefaultButton}.{tags.SmallButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.DefaultButton}.{tags.SmallButton}::UISizeConstraint`] = {
		MinSize = styleTokens.SmallButtonMinSize,
		MaxSize = Vector2.new(math.huge, styleTokens.SmallButtonSize.Y.Offset),
	},

	[`.{tags.StepButtons}`] = {
		Size = UDim2.new(1, 0, 0, styleTokens.StepButtonSize.Y.Offset),
		BackgroundTransparency = 1,
	},
	-- Shared layout for button rows with controls at opposite ends.
	[`.{tags.StepButtons}::UIListLayout, .{tags.StampActionBar}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
		VerticalAlignment = Enum.VerticalAlignment.Center,
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

	[`.{tags.Chip}`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		TextColor3 = styleTokens.Colors.White,
		TextXAlignment = Enum.TextXAlignment.Center,
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
		AutoButtonColor = false,
	},
	[`.{tags.Chip}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.Chip}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.Chip}::UIStroke`] = { -- Background colored outline to allow side chip to be distinct
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = styleTokens.Surface_0.Color3,
		Transparency = styleTokens.Surface_0.Transparency,
		Thickness = 2,
	},

	[`.{tags.SideChip}`] = {
		Size = UDim2.fromOffset(
			styleTokens.SideChipWidth,
			fontTokens.LabelSmall.FontSize + styleTokens.Padding.XSmall.Offset * 2
		),
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
		AutoButtonColor = false,
	},
	[`.{tags.SideChip}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.SideChip} > ImageLabel`] = {
		Size = styleTokens.IconSize.Medium,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -styleTokens.Padding.Small.Offset, 0.5, 0), -- justify right with padding
		BackgroundTransparency = 1,
		ImageColor3 = styleTokens.Colors.White,
	},

	[`.{tags.SideChipContainer}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.SideChipContainer}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = styleTokens.SideChipContainerPadding,
	},

	-- Container that lays out chips horizontally in a row.
	[`.{tags.ChipFrame}`] = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.ChipFrame}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
}

-- Rules for the generic Badge: a non-interactive display pill.
local BADGE_RULES = {
	[`.{tags.Badge}`] = {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = styleTokens.BadgeSize,
		BackgroundColor3 = styleTokens.Surface_0.Color3,
		BackgroundTransparency = styleTokens.Shadow.Transparency,
	},
	[`.{tags.Badge} > TextLabel`] = {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
	},
	[`.{tags.Badge} > ImageLabel`] = {
		BackgroundTransparency = 1,
		Size = styleTokens.IconSize.Small,
		ImageColor3 = styleTokens.Colors.ContentEmphasis,
		ScaleType = Enum.ScaleType.Fit,
	},
	[`.{tags.Badge}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = styleTokens.Padding.XSmall,
	},
	[`.{tags.Badge}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.Badge}::UIPadding`] = {
		PaddingTop = styleTokens.Padding.None,
		PaddingBottom = styleTokens.Padding.None,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},

	-- Places the layer indicator badge centered along the top bar, vertically
	-- centered within the top bar's height.
	[`.{tags.TopBarLayerIndicator}`] = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, (styleTokens.TopBarHeight.Offset - styleTokens.BadgeSize.Y.Offset) / 2),
		ClipsDescendants = true,
	},
	[`.{tags.TopBarLayerIndicator} > TextLabel`] = {
		TextTruncate = Enum.TextTruncate.AtEnd,
	},
	[`.{tags.TopBarLayerIndicator} > TextLabel::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Shrink,
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
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
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
		-- Inset both the track and input area so endpoint handles stay inside the viewport.
		PaddingLeft = UDim.new(0, styleTokens.SliderHandleSize.X.Offset / 2),
		PaddingRight = UDim.new(0, styleTokens.SliderHandleSize.X.Offset / 2),
		PaddingTop = styleTokens.Padding.XSmall,
		PaddingBottom = styleTokens.Padding.XSmall,
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
	},
	[`.{tags.SliderHandle}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},

	[`.{tags.BrushSizeSliderTool}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.BrushSizeSliderTool}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Large,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	},
	[`.{tags.BrushSizeSliderTool} > .{tags.ToolFrame}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},
	[`.{tags.BrushSizeSliderTool} > .{tags.BrushSizePreviewFrame}::UIFlexItem`] = {
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
	},
	[`.{tags.BrushSizePreviewFrame}`] = {
		Size = styleTokens.IconSize.XXLarge,
		BackgroundTransparency = 1,
	},
	[`.{tags.BrushSizePreviewTile}::UIStroke`] = {
		Color = styleTokens.Stroke_Default.Color,
		Transparency = styleTokens.Stroke_Default.Transparency,
		Thickness = styleTokens.Stroke_Default.Thickness,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
	},
	[`.{tags.BrushSizePreviewCircle}`] = {
		AnchorPoint = styleTokens.CenterAnchor,
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	},
	[`.{tags.BrushSizePreviewCircle}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Circle,
	},
	[`.{tags.BrushSizePreviewCircle}::UIAspectRatioConstraint`] = {
		AspectRatio = 1,
	},
	[`.{tags.BrushSizePreviewCircleStroke}`] = {
		Color = styleTokens.Colors.White,
		Transparency = 0,
		Thickness = styleTokens.Stroke_Default.Thickness * 2,
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

-- Rules for layer tiles
local LAYER_TILE_RULES = {
	[`.{tags.LayerTile}`] = {
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	},
	[`.{tags.LayerTile}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
	},
	[`.{tags.LayerTile}::UIFlexItem`] = {
		FlexMode = Enum.UIFlexMode.Fill,
	},

	[`.{tags.LayerTile} >> TextLabel`] = {
		FontFace = fontTokens.BodyMedium.Font,
		TextSize = fontTokens.BodyMedium.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},

	-- Info and Button sections
	[`.{tags.LayerTile} > Frame`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	},
	[`.{tags.LayerTile} > Frame::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
	},

	-- Thumbnail
	-- LayerTileThumbnail size is set in the high priority rules to override base tile.
	[`.{tags.LayerTileThumbnail}::UIPadding`] = {
		PaddingTop = UDim.new(0, styleTokens.Stroke_Default.Thickness),
		PaddingBottom = UDim.new(0, styleTokens.Stroke_Default.Thickness),
		PaddingLeft = UDim.new(0, styleTokens.Stroke_Default.Thickness),
		PaddingRight = UDim.new(0, styleTokens.Stroke_Default.Thickness),
	},
	[`.{tags.LayerTileThumbnail}::UIStroke`] = {
		Color = styleTokens.System_Contrast.Color3,
		Transparency = styleTokens.System_Contrast.Transparency,
		Thickness = styleTokens.Stroke_Default.Thickness,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
	},

	-- Right side icon buttons
	[`.{tags.LayerTileButton}`] = {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	},
	[`.{tags.LayerTileButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Medium,
	},
}

-- Rules for layer stacks, which are used to group layers together.
local LAYER_STACK_RULES = {
	[`.{tags.LayerStack}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.LayerStack}::UIListLayout`] = {
		Padding = styleTokens.Padding.None,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	[`.{tags.LayerStack} > TextButton`] = {
		Size = styleTokens.ButtonSize,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	},
	[`.{tags.AddLayerButton}::UIListLayout`] = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = styleTokens.Padding.Small,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	},
	[`.{tags.AddLayerButton} > Frame`] = {
		Size = styleTokens.LayerTileThumbnailSize,
		BackgroundTransparency = 1,
	},
	[`.{tags.AddLayerButton} > Frame > ImageLabel`] = {
		Size = styleTokens.IconSize.Medium,
		Position = styleTokens.CenterPosition,
		AnchorPoint = styleTokens.CenterAnchor,
		BackgroundTransparency = 1,
	},
	[`.{tags.AddLayerButton} > TextLabel`] = {
		AutomaticSize = Enum.AutomaticSize.XY,
		FontFace = fontTokens.BodyMedium.Font,
		TextSize = fontTokens.BodyMedium.FontSize,
		TextColor3 = styleTokens.Colors.ContentEmphasis,
	},
	[`.{tags.LayersContainer}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.LayersContainer}::UIListLayout`] = {
		Padding = styleTokens.Padding.Medium,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
}

-- Rules for Collapsibles and their children.
local COLLAPSIBLE_RULES = {
	[`.{tags.CollapsibleChild}`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.CollapsibleChild}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},

	-- Selection Button
	[`.{tags.CollapsibleChild} > ImageButton`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.CollapsibleChild} > ImageButton::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Small + styleTokens.CollapsibleChildPadding,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.CollapsibleChild} > ImageButton::UIListLayout`] = {
		Padding = styleTokens.Padding.None,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	-- Visible and Collapsible contents
	[`.{tags.CollapsibleChild} > ImageButton > Frame`] = {
		Size = styleTokens.CollapsibleChildSize,
		BackgroundTransparency = 1,
	},
	-- Center contents vertically
	[`.{tags.CollapsibleChild} > ImageButton > Frame > GuiObject`] = {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
	},

	[`.{tags.CollapsibleContainer}, .{tags.CollapsibleContainer} > Frame`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.CollapsibleContainer}::UICorner, .{tags.CollapsibleContainerVisibleContent}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.CollapsibleContainer}::UIListLayout`] = {
		Padding = styleTokens.Padding.None,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	-- Collapsible Container Visible Content
	-- Image button takes up entire frame so everywhere is clickable
	[`.{tags.CollapsibleContainerVisibleContent} > ImageButton`] = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	},
	[`.{tags.CollapsibleContainerVisibleContent} > ImageButton::UIPadding`] = {
		PaddingBottom = styleTokens.Padding.Small,
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
		PaddingTop = styleTokens.Padding.Small,
	},
	[`.{tags.CollapsibleContainerVisibleContent} > ImageButton::UIListLayout`] = {
		Padding = styleTokens.Padding.Small,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ItemLineAlignment = Enum.ItemLineAlignment.Center,
	},

	[`.{tags.CollapsibleIndicatorButton}`] = {
		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	},
	[`.{tags.CollapsibleIndicatorButton} > ImageLabel`] = {
		Size = styleTokens.IconSize.Medium,
	},
}

-- These rules need to apply on top of other rules, so we will give them higher
-- priority by generating them after the rest of the rules.
local HIGH_PRIORITY_RULE_MAP = {
	[`.{tags.AddItemButton}`] = {
		Size = styleTokens.AddItemButtonSize,
		AutomaticSize = Enum.AutomaticSize.None,
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = styleTokens.AddItemButtonTextSize,
		-- TextScaled enables wrapping, so use a fixed small font for a single line.
		TextScaled = false,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	},
	[`.{tags.AddItemButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Medium,
		PaddingRight = styleTokens.Padding.Medium,
	},
	[`.{tags.AddItemButton}::UISizeConstraint`] = {
		MinSize = styleTokens.AddItemButtonMinSize,
		MaxSize = Vector2.new(math.huge, styleTokens.AddItemButtonSize.Y.Offset),
	},
	[`.{tags.AddItemButton}::UIStroke`] = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		Color = styleTokens.Stroke_ActionEmphasis.Color,
		Transparency = styleTokens.Stroke_ActionEmphasis.Transparency,
		Thickness = styleTokens.Stroke_ActionEmphasis.Thickness,
	},
	[`.{tags.AddItemButtonDisabled}`] = {
		Active = false,
		Interactable = false,
		Selectable = false,
		AutoButtonColor = false,
		TextTransparency = styleTokens.AddItemButtonDisabledTransparency,
	},

	[`.{tags.StepButtons} > .{tags.DefaultButton}`] = {
		Size = styleTokens.StepButtonSize,
		FontFace = fontTokens.LabelSmall.Font,
		TextSize = fontTokens.LabelSmall.FontSize,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	},
	[`.{tags.StepButtons} > .{tags.DefaultButton}::UICorner`] = {
		CornerRadius = styleTokens.Radius.Medium,
	},
	[`.{tags.StepButtons} > .{tags.DefaultButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Small,
		PaddingRight = styleTokens.Padding.Small,
	},
	[`.{tags.StepButtons} > .{tags.DefaultButton}::UISizeConstraint`] = {
		MinSize = Vector2.new(0, styleTokens.StepButtonSize.Y.Offset),
		MaxSize = Vector2.new(math.huge, styleTokens.StepButtonSize.Y.Offset),
	},
	[`.{tags.StepButtonDisabled}`] = {
		Interactable = false,
		Selectable = false,
		TextTransparency = styleTokens.StepButtonDisabledTextTransparency,
	},
	[`.{tags.ActionBarPreviewButton}`] = {
		BackgroundColor3 = styleTokens.Colors.White,
		BackgroundTransparency = 0,
		TextColor3 = styleTokens.Colors.Black,
	},
	[`.{tags.ShapeControlDisabled} > .{tags.ToolTitle} > TextLabel`] = {
		TextColor3 = styleTokens.Colors.ContentMuted,
	},
	[`.{tags.BaseTileInsetButton}`] = {
		Size = UDim2.new(1, -2 * styleTokens.Padding.XSmall.Offset, 0, styleTokens.GridTileInsetButtonHeight),
		AnchorPoint = Vector2.new(styleTokens.CenterAnchor.X, 1),
		Position = UDim2.new(styleTokens.CenterPosition.X.Scale, 0, 1, -styleTokens.Padding.XSmall.Offset),
		BackgroundColor3 = styleTokens.Colors.White,
		BackgroundTransparency = 0,
		TextColor3 = styleTokens.Colors.Black,
		FontFace = fontTokens.LabelSmall.Font,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = styleTokens.GridTileInsetButtonZIndex,
	},
	[`.{tags.BaseTileInsetButton}::UITextSizeConstraint`] = {
		MaxTextSize = fontTokens.LabelSmall.FontSize,
	},
	[`.{tags.BaseTileInsetButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.XXSmall,
		PaddingRight = styleTokens.Padding.XXSmall,
	},

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

	-- Requires both tags to exist
	[`.{tags.LocalMenu}.{tags.LocalMenuWithOpenPanel}`] = {
		Position = `${themeTokens.LocalMenuPositionWithOpenPanel}`,
	},

	-- Active state for the toggle text button: white background, dark text.
	[`.{tags.ChipActive}`] = {
		BackgroundColor3 = styleTokens.Colors.White,
		BackgroundTransparency = 0,
		TextColor3 = styleTokens.OverMedia_200.Color3,
	},

	-- Active state for the side chip: white oval, dark icon.
	[`.{tags.SideChipActive}`] = {
		BackgroundColor3 = styleTokens.Colors.White,
		BackgroundTransparency = 0,
	},
	[`.{tags.SideChipActive} > ImageLabel`] = {
		ImageColor3 = styleTokens.OverMedia_200.Color3,
	},

	[`.{tags.EmphasisButton}`] = {
		BackgroundColor3 = styleTokens.ActionEmphasis.Color3,
		BackgroundTransparency = styleTokens.ActionEmphasis.Transparency,
	},

	-- Hover highlight for a dropdown menu option.
	[`.{tags.DropdownMenuOptionHover}`] = {
		BackgroundColor3 = styleTokens.Shift_300.Color3,
		BackgroundTransparency = styleTokens.Shift_300.Transparency,
	},
	[`.{tags.DropdownMenuOptionDisabled}`] = {
		Active = false,
		Selectable = false,
		AutoButtonColor = false,
	},
	[`.{tags.DropdownMenuOptionDisabled} >> ImageLabel`] = {
		ImageTransparency = 0.6,
	},
	[`.{tags.DropdownMenuOptionDisabled} >> TextLabel`] = {
		TextColor3 = styleTokens.Colors.ContentMuted,
	},

	[`.{tags.ModalTwoStateIconButtonActive}`] = {
		BackgroundColor3 = styleTokens.System_Contrast.Color3,
		BackgroundTransparency = styleTokens.System_Contrast.Transparency,
	},

	[`.{tags.BuyButton}`] = {
		Size = styleTokens.BuyButtonSize,
		-- Position in bottom right of screen
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		FontFace = fontTokens.BuyButtonFont.Font,
		TextSize = fontTokens.BuyButtonFont.FontSize,
	},

	[`.{tags.CollapsiblePrimarySelection}`] = {
		BackgroundColor3 = styleTokens.ActionSoftEmphasis.Color3,
		BackgroundTransparency = styleTokens.ActionSoftEmphasis.Transparency,
	},

	[`.{tags.CollapsibleSecondarySelection}`] = {
		BackgroundColor3 = styleTokens.Shift_200.Color3,
		BackgroundTransparency = styleTokens.Shift_200.Transparency,
	},

	-- The brush picker reuses BaseTile for its thumbnails, but needs a
	-- non-square size. This overrides the BaseTile's aspect ratio constraint
	[`.{tags.BrushPickerThumbnail}::UIAspectRatioConstraint`] = {
		AspectRatio = styleTokens.BrushPickerThumbnailSize.X.Offset / styleTokens.BrushPickerThumbnailSize.Y.Offset,
	},

	-- Reduce the vertical gap between the title and brush-size slider.
	[`.{tags.BrushSizeSliderTool} > .{tags.ToolFrame}::UIListLayout`] = {
		Padding = styleTokens.Padding.XSmall,
	},

	-- The preview tile fills its fixed-size parent with a transparent background.
	[`.{tags.BrushSizePreviewFrame} > .{tags.BrushSizePreviewTile}`] = {
		BackgroundTransparency = 1,
	},

	-- Fades an icon button to signal a muted/disabled state. Higher priority than
	-- the button's base rule so it wins while the tag is set.
	[`.{tags.IconButtonMuted}`] = {
		Active = false,
		Selectable = false,
		AutoButtonColor = false,
	},
	[`.{tags.IconButtonMuted} > ImageLabel`] = {
		ImageTransparency = 0.6,
	},

	[`.{tags.LayerTileThumbnail}`] = {
		Size = styleTokens.LayerTileThumbnailSize,
		BackgroundColor3 = styleTokens.Surface_0.Color3,
		BackgroundTransparency = styleTokens.Surface_0.Transparency,
	},
	[`.{tags.LayerOpacitySlider}`] = {
		-- Keep the handle inside the panel when it is centered on the track's endpoint.
		Size = UDim2.fromScale(1, 0),
	},
	[`.{tags.LayerOpacitySlider}::UIPadding`] = {
		PaddingLeft = UDim.new(0, styleTokens.SliderHandleSize.X.Offset / 2) + styleTokens.Padding.Small,
		PaddingRight = UDim.new(0, styleTokens.SliderHandleSize.X.Offset / 2) + styleTokens.Padding.Small,
	},
	[`.{tags.AddLayerButton}::UIPadding`] = {
		PaddingLeft = styleTokens.Padding.Small + styleTokens.CollapsibleChildPadding,
		PaddingRight = styleTokens.Padding.Small,
	},
}

local RULES = {
	UI_LAYOUT_RULES,

	LOCAL_MENU_RULES,
	PANEL_RULES,
	BANNER_RULES,
	COLOR_PICKER_RULES,
	TOOLBAR_RULES,
	STAMP_ACTION_BAR_RULES,
	MODAL_RULES,
	GRID_RULES,
	SWATCH_BAR_RULES,
	ITEM_SELECTOR_RULES,
	BRUSH_PICKER_RULES,
	DROPDOWN_MENU_RULES,
	GROUP_CARD_RULES,

	BUTTON_RULES,
	HORIZONTAL_PILLBAR_RULES,
	TOGGLE_RULES,
	BADGE_RULES,
	PROGRESS_BAR_RULES,
	SLIDER_RULES,
	SEGMENTED_CONTROL_RULES,
	EDITING_HANDLE_RULES,
	LAYER_TILE_RULES,
	LAYER_STACK_RULES,
	COLLAPSIBLE_RULES,
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
