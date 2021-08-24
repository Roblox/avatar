local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local RoactRodux = require(Modules.Packages.RoactRodux)
local Immutable = require(Modules.Common.Immutable)

local OverlayType = require(Modules.NotLApp.Enum.OverlayType)
local Colors = require(Modules.Common.Colors)
local getSafeAreaSize = require(Modules.NotLApp.getSafeAreaSize)

local LeaveCatalogToAvatarPrompt =
	require(Modules.AvatarExperience.Catalog.Components.ItemDetails.Prompts.LeaveCatalogToAvatarPrompt)
local CatalogContextMenu = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.CatalogContextFrame)
local CategoryFiltersPrompt = require(Modules.AvatarExperience.Catalog.Components.Search.Prompts.CategoryFiltersPrompt)
local PriceFilterPrompt = require(Modules.AvatarExperience.Catalog.Components.Search.Prompts.PriceFilterPrompt)

local GetFFlagCatalogSortAndFilters = function() return false end

local OverlayWithBackground = {
	[OverlayType.PlacesList] = true,
	[OverlayType.PeopleList] = true,
	[OverlayType.PurchaseGame] = true,
	[OverlayType.PurchaseGameRobuxShortfall] = true,
	[OverlayType.LeaveRobloxAlert] = true,
	[OverlayType.ConfirmSignOut] = true,
	[OverlayType.AutoUpgradePrompt] = true,
	[OverlayType.DevSubMore] = true,
	[OverlayType.DevSubConfirmCancel] = true,
	[OverlayType.PurchaseCatalogItem] = true,
	[OverlayType.LeaveCatalogToAvatarPrompt] = true,
	[OverlayType.SignUpBirthdayPickerOverlay] = true,
	[OverlayType.CategoryFiltersPrompt] = true,
	[OverlayType.PriceFilterPrompt] = true,
}

local OverlayComponent = {
	[OverlayType.LeaveCatalogToAvatarPrompt] = LeaveCatalogToAvatarPrompt,
	[OverlayType.CatalogContextMenu] = CatalogContextMenu,
	[OverlayType.CategoryFiltersPrompt] = CategoryFiltersPrompt,
	[OverlayType.PriceFilterPrompt] = PriceFilterPrompt,
}

local CentralOverlay = Roact.PureComponent:extend("CentralOverlay")

function CentralOverlay:render()
	local overlayComponent = self.props.overlayComponent
	local arguments = self.props.arguments
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local shouldCreateBackgroundWrapper = self.props.shouldCreateBackgroundWrapper

	if screenSize.X <= 0 or screenSize.Y <= 0 then
		return nil
	end

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)

	return withStyle(function(stylePalette)
		local backgroundColor = Colors.Black
		local backgroundTransparency = 0.3
		if stylePalette then
			--Display on top of bottom bar
			if not GetFFlagCatalogSortAndFilters() or self.props.includeStatusBar then
				safeAreaSize = UDim2.new(0, safeAreaSize.X.Offset, 0, safeAreaSize.Y.Offset + 0)
			end
			backgroundColor = stylePalette.Theme.Overlay.Color
			backgroundTransparency = stylePalette.Theme.Overlay.Transparency
		end
		return overlayComponent and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 10,
		}, {
			OverlayComponent = shouldCreateBackgroundWrapper and Roact.createElement("Frame", {
				Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
				Size = UDim2.new(0, screenSize.X * 2, 0, screenSize.Y * 2),
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = backgroundTransparency,
				BorderSizePixel = 0,
				-- Absorb input
				Active = true,
			}, {
				SafeAreaFrame = Roact.createElement("Frame", {
					Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
					Size = safeAreaSize,
					BackgroundTransparency = 1,
					ClipsDescendants = true,
				}, {
					Prompt = Roact.createElement(overlayComponent, Immutable.JoinDictionaries(arguments, {
						containerWidth = safeAreaSize.X.Offset,
					})),
				}),
			}) or Roact.createElement(overlayComponent, arguments),
		})
	end)
end

CentralOverlay = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local overlayType = state.CentralOverlay.OverlayType

		return {
			overlayComponent = OverlayComponent[overlayType],
			shouldCreateBackgroundWrapper = OverlayWithBackground[overlayType],
			arguments = state.CentralOverlay.Arguments,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
		}
	end
)(CentralOverlay)

return CentralOverlay
