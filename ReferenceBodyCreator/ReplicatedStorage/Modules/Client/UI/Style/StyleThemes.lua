--[[
	Defines style tokens for different themes (mobile, desktop) used by the
	style manager. These allow UI to adapt its appearance and layout based on
	the screen size.
]]

local Style = script.Parent
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local styleTokens = StyleConsts.styleTokens

-- Any themes must exactly match these tokens as keys in order to be used by the
-- Style manager's theme switching logic.
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

-- Mobile Theme
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

-- Desktop Theme
local THEME_DESKTOP_TOKENS = {
	[THEME_TOKENS.PanelSize] = UDim2.fromOffset(320, 0),
	[THEME_TOKENS.PanelCornerRadius] = styleTokens.Radius.Medium,
	[THEME_TOKENS.PanelAutomaticSize] = Enum.AutomaticSize.Y,
	[THEME_TOKENS.PanelAnchorPoint] = Vector2.new(1, 0), -- Top right
	[THEME_TOKENS.PanelPosition] = UDim2.fromScale(1, 0),
	[THEME_TOKENS.UIParentPaddingTop] = styleTokens.Padding.Medium + styleTokens.TopBarHeight,
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

return {
	themeTokens = THEME_TOKENS,
	mobileThemeTokens = THEME_MOBILE_TOKENS,
	desktopThemeTokens = THEME_DESKTOP_TOKENS,
}
