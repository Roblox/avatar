local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local BrowserService = game:GetService("BrowserService")
local NotificationService = game:GetService("NotificationService")
local GuiService = game:GetService("GuiService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarEvents = ReplicatedStorage:WaitForChild("AvatarEvents")
local avatarEditorClosed = AvatarEvents.AvatarEditorClosed

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer.PlayerGui
while not PlayerGui do
	LocalPlayer.ChildAdded:Wait()
	PlayerGui = LocalPlayer.PlayerGui
end

local AvatarEditorInGame = script.Parent

local AvatarEditorInGameScreenGui = AvatarEditorInGame:FindFirstChild("AvatarEditorInGame")

AvatarEditorInGameScreenGui.Parent = PlayerGui

local Modules = PlayerGui:WaitForChild("AvatarEditorInGame"):WaitForChild("Modules")

local SetItemDetailsProps = require(Modules.Setup.Actions.SetItemDetailsProps)

local InGameAssetGranter = require(Modules.InGameEditor.InGameAssetGranter)

local UIBlox = require(Modules.Packages.UIBlox)

UIBlox.init()

local Roact = require(Modules.Packages.Roact)

Roact.setGlobalConfig({
	elementTracing = true,
})

local RoactLocalization = require(Modules.Services.RoactLocalization)
local AppBrowserService = require(Modules.Services.AppBrowserService)
local AppNotificationService = require(Modules.Services.AppNotificationService)
local AppGuiService = require(Modules.Services.AppGuiService)
local AppRunService = require(Modules.Services.AppRunService)
local AppUserInputService = require(Modules.Services.AppUserInputService)

local RoactServices = require(Modules.Common.RoactServices)

local ProviderContainer = require(Modules.Setup.ProviderContainer)

local AvatarSceneManager = require(Modules.AvatarExperience.Common.Managers.AvatarSceneManager)

local AppDarkTheme = require(Modules.Common.DarkTheme)
local AppFont = require(Modules.Common.Gotham)

local Rodux = require(Modules.Packages.Rodux)
local RoactRodux = require(Modules.Packages.RoactRodux)

local Localization = require(Modules.Localization.Localization)
local LocalizationProvider = require(Modules.Localization.LocalizationProvider)

local SetScreenSize = require(Modules.Setup.Actions.SetScreenSize)
local SetGlobalGuiInset = require(Modules.Setup.Actions.SetGlobalGuiInset)
local SetLocalUserId = require(Modules.Setup.Actions.SetLocalUserId)
local SetDeviceOrientation = require(Modules.Setup.Actions.SetDeviceOrientation)
local SetLastInputType = require(Modules.Setup.Actions.SetLastInputType)

local RunAvatarSceneManager = require(Modules.Setup.Actions.RunAvatarSceneManager)

local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local AppPage = require(Modules.NotLApp.AppPage)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)

local DisplayedPageManager = require(Modules.InGameEditor.Components.DisplayedPageManager)

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

local InGameManager = {}
InGameManager.__index = InGameManager

function InGameManager.new()
	local self = setmetatable({}, InGameManager)

	--AvatarEditorService:PromptAllowInventoryReadAccess()

	--AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Wait()

	local providers = {}

	local middlewareList = { Rodux.thunkMiddleware }

	self.store = Rodux.Store.new(Reducer, nil, middlewareList)

	InGameAssetGranter(self.store)

	screenSizeUpdated(self.store, PlayerGui.AvatarEditorInGame.AbsoluteSize)
	PlayerGui.AvatarEditorInGame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		screenSizeUpdated(self.store, PlayerGui.AvatarEditorInGame.AbsoluteSize)
	end)

	self.store:dispatch(SetLastInputType(UserInputService:GetLastInputType()))

	UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		self.store:dispatch(SetLastInputType(lastInputType))
	end)

	self.store:dispatch(SetLocalUserId(tostring(LocalPlayer.UserId)))

	local topLeft, bottomRight = GuiService:GetGuiInset()
	self.store:dispatch(SetGlobalGuiInset(topLeft.X, topLeft.Y, bottomRight.X, bottomRight.Y))

	table.insert(providers, {
		class = RoactRodux.StoreProvider,
		props = {
			store = self.store,
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
	self.store:dispatch(NavigateDown({ name = AppPage.AvatarEditor }))

	PlayerGui.AvatarEditorInGame.Enabled = false
	self.store:dispatch(RunAvatarSceneManager(false))
	self.isShowingAvatarEditor = false

	return self
end

function InGameManager:showAvatarEditor()
	self.isShowingAvatarEditor = true
	PlayerGui.AvatarEditorInGame.Enabled = true
	self.store:dispatch(RunAvatarSceneManager(true))
end

function InGameManager:hideAvatarEditor()
	self.isShowingAvatarEditor = false
	PlayerGui.AvatarEditorInGame.Enabled = false
	self.store:dispatch(RunAvatarSceneManager(false))

	avatarEditorClosed:FireServer()
end

function InGameManager:closeItemDetails()
	local wasOpen = self.store:getState().ItemDetailsProps.itemId ~= nil

	self.store:dispatch(SetItemDetailsProps(nil, nil))

	return wasOpen
end

function InGameManager:showingAvatarEditor()
	return self.isShowingAvatarEditor
end

return InGameManager.new()
