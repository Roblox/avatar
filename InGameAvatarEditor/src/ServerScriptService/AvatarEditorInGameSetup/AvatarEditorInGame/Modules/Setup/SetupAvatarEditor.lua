local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalizationService = game:GetService("LocalizationService")
local BrowserService = game:GetService("BrowserService")
local NotificationService = game:GetService("NotificationService")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayersService.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local AvatarEditorInGame = LocalPlayer.PlayerGui.AvatarEditorInGame
local Modules = LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local Rodux = require(Modules.Packages.Rodux)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local SetScreenSize = require(Modules.Setup.Actions.SetScreenSize)
local SetGlobalGuiInset = require(Modules.Setup.Actions.SetGlobalGuiInset)
local SetLocalUserId = require(Modules.Setup.Actions.SetLocalUserId)
local SetDeviceOrientation = require(Modules.Setup.Actions.SetDeviceOrientation)
local SetLastInputType = require(Modules.Setup.Actions.SetLastInputType)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)

local Localization = require(Modules.Localization.Localization)
local LocalizationProvider = require(Modules.Localization.LocalizationProvider)

local RoactServices = require(Modules.Common.RoactServices)
local RoactLocalization = require(Modules.Services.RoactLocalization)
local AppBrowserService = require(Modules.Services.AppBrowserService)
local AppNotificationService = require(Modules.Services.AppNotificationService)
local AppGuiService = require(Modules.Services.AppGuiService)
local AppRunService = require(Modules.Services.AppRunService)
local AppUserInputService = require(Modules.Services.AppUserInputService)

local InGameAssetGranter = require(Modules.InGameEditor.InGameAssetGranter)

local ProviderContainer = require(Modules.Setup.ProviderContainer)
local AppDarkTheme = require(Modules.Common.DarkTheme)
local AppFont = require(Modules.Common.Gotham)

local DisplayedPageManager = require(Modules.InGameEditor.Components.DisplayedPageManager)
local AvatarSceneManager = require(Modules.AvatarExperience.Common.Managers.AvatarSceneManager)

local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local RunAvatarSceneManager = require(Modules.Setup.Actions.RunAvatarSceneManager)
local AppPage = require(Modules.NotLApp.AppPage)

local Reducer = Rodux.combineReducers({
	AvatarExperience = require(Modules.AvatarExperience.Common.Reducers.AvatarExperience),

	CurrentToastMessage = require(Modules.NotLApp.Reducers.CurrentToastMessage),
	CentralOverlay = require(Modules.NotLApp.Reducers.CentralOverlay),

	Navigation = require(Modules.NotLApp.Reducers.Navigation),

	Search = require(Modules.Setup.Reducers.Search),
	SearchesParameters = require(Modules.Setup.Reducers.SearchParameters),
	SearchesTypes = require(Modules.Setup.Reducers.SearchesTypes),

	LastSearch = require(Modules.Setup.Reducers.LastSearch),

	RequestsStatus = require(Modules.Setup.Reducers.RequestsStatus),

	ScreenSize = require(Modules.Setup.Reducers.ScreenSize),
	GlobalGuiInset = require(Modules.Setup.Reducers.GlobalGuiInset),
	FetchingStatus = require(Modules.Setup.Reducers.FetchingStatus),
	LocalUserId = require(Modules.Setup.Reducers.LocalUserId),
	UserRobux = require(Modules.Setup.Reducers.UserRobux),
	DeviceOrientation = require(Modules.Setup.Reducers.DeviceOrientation),
	SceneManagerEnabled = require(Modules.Setup.Reducers.SceneManagerEnabled),

	ItemDetailsProps = require(Modules.Setup.Reducers.ItemDetailsProps),

	LastInputType = require(Modules.Setup.Reducers.LastInputType),
})

local function screenSizeUpdated(store, absSize)
	store:dispatch(SetScreenSize(absSize))

	if absSize.X > absSize.Y then
		store:dispatch(SetDeviceOrientation(DeviceOrientationMode.Landscape))
	else
		store:dispatch(SetDeviceOrientation(DeviceOrientationMode.Portrait))
	end
end

local function SetupAvatarEditor()
	local providers = {}

	local middlewareList = { Rodux.thunkMiddleware }

	local store = Rodux.Store.new(Reducer, nil, middlewareList)

	InGameAssetGranter(store)

	screenSizeUpdated(store, AvatarEditorInGame.AbsoluteSize)
	AvatarEditorInGame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		screenSizeUpdated(store, AvatarEditorInGame.AbsoluteSize)
	end)

	store:dispatch(SetLastInputType(UserInputService:GetLastInputType()))

	UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		store:dispatch(SetLastInputType(lastInputType))
	end)

	store:dispatch(SetLocalUserId(tostring(LocalPlayer.UserId)))

	local topLeft, bottomRight = GuiService:GetGuiInset()
	store:dispatch(SetGlobalGuiInset(topLeft.X, topLeft.Y, bottomRight.X, bottomRight.Y))

	table.insert(providers, {
		class = RoactRodux.StoreProvider,
		props = {
			store = store,
		},
	})

	local localization = Localization.new(LocalizationService.RobloxLocaleId)

	table.insert(providers, {
		class = RoactServices.ServiceProvider,
		props = {
			services = {
				-- Remove RoactLocalization when migration to LocalizationProvider is done
				[RoactLocalization] = localization,
				[AppBrowserService] = BrowserService,
				[AppNotificationService] = NotificationService,
				[AppGuiService] = GuiService,
				[AppRunService] = RunService,
				[AppUserInputService] = UserInputService,
			},
		},
	})

	local appStyle = {
		Theme = AppDarkTheme,
		Font = AppFont,
	}
	table.insert(providers, {
		class = UIBlox.Core.Style.Provider,
		props = {
			style = appStyle,
		},
	})

	table.insert(providers, {
		class = LocalizationProvider,
		props = {
			localization = localization,
		},
	})

	local root = Roact.createElement(ProviderContainer, {
		providers = providers,
	}, {
		Folder = Roact.createElement("Folder", {

		}, {
			DisplayedPageManager = Roact.createElement(DisplayedPageManager),

			AvatarSceneManager = Roact.createElement(AvatarSceneManager),
		}),
	})

	Roact.mount(root, PlayerGui.AvatarEditorInGame, "AvatarEditor")
	store:dispatch(NavigateDown({ name = AppPage.AvatarEditor }))

	PlayerGui.AvatarEditorInGame.Enabled = false
	store:dispatch(RunAvatarSceneManager(false))

	return store
end

return SetupAvatarEditor