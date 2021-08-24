return {
	-- tempFixEmptyGridView: This is a temp/hacky fix to a problem in UI layout code.  Real/better
	-- fix is coming on C++ side, this is a stopgap measure to fix the problem ASAP in prod.
	tempFixEmptyGridView = false,

	-- enableAlertTitleIconConfig: turning this on allows the Alert component to take
	-- in an optional titleIcon prop, which displays an icon above the Alert's title.
	enableAlertTitleIconConfig = false,

	-- styleRefactorConfig: DEPRECATED: this is a no-op, but is left in so that it's easier to upgrade consumers of
	-- UIBlox that try to assign a value to it (the config layer will throw if assigning to a value that's not in the
	-- default config)
	styleRefactorConfig = false,

	--enableExperimentalGamepadSupport: Enables support of gamepad navigation via the roact-gamepad
	-- library. This is currently experimental and not yet ready for release.
	enableExperimentalGamepadSupport = false,

	--useNewUICornerRoundedCorners: Uses the new roblox CornerUI Instance instead of mask-based UI corners
	useNewUICornerRoundedCorners = false,

	-- genericSliderFilterOldTouchInputs: Filters inputObjects that trigger inputBegan with a
	-- non Enum.UserInputState.Begin UserInputState in the GenericSlider component
	genericSliderFilterOldTouchInputs = false,

	-- useAnimatedXboxCursors: Uses the new animated selection cursors when selecting UI elements in xbox
	useAnimatedXboxCursors = false,

	--allowSystemBarToAcceptString: Allows you to pass a string as the value for 'badgeValue'. Passing a
	--string will show the badge even if the string is empty.
	allowSystemBarToAcceptString = false,

	-- emptyStateControllerSupport: Enables controller support for the EmptyState component.
	emptyStateControllerSupport = false,

	-- useTileThumbnailV2: Controls the usage of TileThumbnailV2
	useTileThumbnailV2 = false,

	-- enableAlertCustomTitleFooterConfig: Enables custom title and footer content for the Alert
	enableAlertCustomTitleFooterConfig = false,

	-- useUpdatedCheckbox: Enables FitFrame for InputButton and gives Checkbox a gamepad
	-- selection cursor.
	useUpdatedCheckbox = false,

	-- fixDropdownMenuListPositionAndSize: Uses the bottom inset for positioning the dropdown menu list for
	-- mobile view, allows sizing relative to parent container size, and limits dropdown width for wide view.
	fixDropdownMenuListPositionAndSize = false,

	-- enableSubtitleOnTile: Enables a subtitle label positioned below the title
	-- that can be passed in as a prop.
	enableSubtitleOnTile = false,

	-- renameKeyProp: Renames the current props named `key` to `id` to allow migration to Roact 17
	renameKeyProp = false,

	-- Warning for deprecated components.
	-- This is not a flag but a temporary config to show a warning for using deprecated components.
	-- current deprecated components are,
	-- src\App\Loading\Enum\LoadingState.lua
	-- src\App\Loading\Enum\ReloadingStyle.lua
	devHasDeprecationWarning = false,

	-- useNewContext: Switch off of Roact's deprecated _context API and onto the upstream-aligned
	-- createContext API to allow migration to Roact 17
	useNewContext = false,

	-- addIsEmptyToBadge: A smaller badge with no contents will show when the value for badge is BadgeStates.isEmpty
	-- applies to NavBar items too.
	addIsEmptyToBadge = false,

	-- verticalScrollViewEnableDynamicMargins: when on, VerticalScrollView will use margins based off its
	-- container's size, when not explicitly passed a paddingHorizontal prop
	verticalScrollViewUseDefaultDynamicMargins = false,
}
