local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local SetPageLoaded = require(Modules.AvatarExperience.AvatarEditor.Actions.SetPageLoaded)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local ToggleCatalogUIFullView = require(Modules.AvatarExperience.Catalog.Actions.ToggleUIFullView)
local ToggleAvatarEditorUIFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleUIFullView)
local ToggleAvatarEditor3DFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.Toggle3DFullView)
local ToggleCatalog3DFullView = require(Modules.AvatarExperience.Catalog.Actions.Toggle3DFullView)
local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)
local CharacterLoader = require(Modules.AvatarExperience.Common.Managers.CharacterLoader)
local CharacterMover = require(Modules.AvatarExperience.Common.Managers.CharacterMover)
local CameraManager = require(Modules.AvatarExperience.Common.Managers.CameraManager)
local BackgroundSceneManager = require(Modules.AvatarExperience.Common.Managers.BackgroundSceneManager)
local AppPage = require(Modules.NotLApp.AppPage)
local Constants = require(Modules.NotLApp.Constants)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)

local UseTempHacks = require(Modules.Config.UseTempHacks)

local GetFFlagLuaAppEnableAERedesign = function() return true end
local GetFFlagAvatarExperienceUnselectTryOnFix = function() return true end
local FFlagLuaCatalogPageDisable3DView = false
local IsLuaCatalogPageEnabled = true
local FFlagLuaAppEnableAERedesign = function() return true end
local GetFFlagAvatarExperienceSaveManagerInitialization = function() return true end

local AvatarSceneManager = Roact.PureComponent:extend("AvatarSceneManager")

local function getTopPageFromProps(routeHistory)
	local route = routeHistory[#routeHistory]
	return route[#route]
end

function AvatarSceneManager:init()
	local store = RoactRodux.UNSTABLE_getStore(self)
	self.running = false

	self.firstTime = true

	coroutine.wrap(function()
		self.characterLoader = CharacterLoader.new(store)
		self.backgroundSceneManager = BackgroundSceneManager.new(store)
		self.cameraManager = CameraManager.new(store)
		self.characterMover = CharacterMover.new(store)
	end)()
end

function AvatarSceneManager:shouldRunMangers(page)
	if true then
		return self.props.sceneManagerEnabled
	end

	if FFlagLuaAppEnableAERedesign() and page.name == AppPage.AvatarEditor then
		return true
	end

	if page.name == AppPage.AvatarExperienceLandingPage then
		return true
	end

	if page.name == AppPage.ItemDetails then
		if FFlagLuaCatalogPageDisable3DView then
			local store = RoactRodux.UNSTABLE_getStore(self)
			local parentPage = AvatarExperienceUtils.getParentPage(store:getState())

			return parentPage == AppPage.AvatarEditor
		end

		return true
	end

	if IsLuaCatalogPageEnabled and page.name == AppPage.Catalog then
		if FFlagLuaCatalogPageDisable3DView then
			return false
		end

		return true
	end

	if IsLuaCatalogPageEnabled and page.name == AppPage.SearchPage then
		if FFlagLuaCatalogPageDisable3DView then
			return false
		end

		local searchUuid = page.detail

		local store = RoactRodux.UNSTABLE_getStore(self)
		local state = store:getState()

		local searchType = state.SearchesTypes[searchUuid]
		return searchType == Constants.SearchTypes.Catalog
	end

	return false
end

function AvatarSceneManager:willUnmount()
	if not GetFFlagAvatarExperienceSaveManagerInitialization() then
		if self.props.isVisible then
			self:stop()
		end
	elseif GetFFlagAvatarExperienceSaveManagerInitialization() and self.running then
		self:stop()
	end

	self:onDestroy()
end

function AvatarSceneManager:willUpdate(nextProps)
	local avatarEditorFullView = nextProps.avatarEditorFullView
	local catalogFullView = nextProps.catalogFullView
	local avatarEditorUIFullView = nextProps.avatarEditorUIFullView
	local catalogUIFullView = nextProps.catalogUIFullView
	local toggleAvatarEditorUIFullView = self.props.toggleAvatarEditorUIFullView
	local toggleCatalogUIFullView = self.props.toggleCatalogUIFullView
	local toggleAvatarEditor3DFullView = self.props.toggleAvatarEditor3DFullView
	local toggleCatalog3DFullView = self.props.toggleCatalog3DFullView
	local clearSelectedItem = self.props.clearSelectedItem
	local tryOnItem = nextProps.tryOnItem
	local closeAllItemDetails = self.props.closeAllItemDetails
	local oldPage = getTopPageFromProps(self.props.routeHistory)
	local newPage = getTopPageFromProps(nextProps.routeHistory)

	local oldShouldRunManagers = self.props.sceneManagerEnabled
	if self.firstTime then
		oldShouldRunManagers = false
		self.firstTime = false
	end
	local newShouldRunManagers = nextProps.sceneManagerEnabled  --self:shouldRunMangers(newPage)

	if oldPage ~= newPage then
		-- Close full view when leaving the avatar editor or catalog.
		if newPage.name ~= AppPage.AvatarEditor and avatarEditorFullView then
			toggleAvatarEditor3DFullView()
		elseif newPage.name ~= AppPage.Catalog and catalogFullView then
			toggleCatalog3DFullView()
		end

		-- Switch back to UI half view when leaving the avatar editor or catalog.
		if newPage.name ~= AppPage.AvatarEditor and avatarEditorUIFullView then
			toggleAvatarEditorUIFullView()
		elseif newPage.name ~= AppPage.Catalog and catalogUIFullView then
			toggleCatalogUIFullView()
		end

		if newPage.name ~= AppPage.ItemDetails then
			if IsLuaCatalogPageEnabled and tryOnItem.itemId ~= nil then
				closeAllItemDetails()
				if GetFFlagAvatarExperienceUnselectTryOnFix() then
					clearSelectedItem()
				end
			end
		end
	end

	if (not oldShouldRunManagers) and (newShouldRunManagers) then
		self:start()
	elseif (oldShouldRunManagers) and (not newShouldRunManagers) then
		self:stop()
	end
end

function AvatarSceneManager:render()
end

function AvatarSceneManager:start()
	if GetFFlagAvatarExperienceSaveManagerInitialization() and self.running then
		return
	end

	if UseTempHacks then
		coroutine.wrap(function()
			while not self.characterMover do
				wait()
			end

			-- TODO AVBURST-1456 - Investigate if we need to SetThrottleFramerateEnabled in the Avatar Editor still
			--RunService:setThrottleFramerateEnabled(false)
			self.running = true
			self.characterLoader:start()
			self.backgroundSceneManager:start()
			self.cameraManager:start()
			self.characterMover:start()
			self.props.setPageLoaded()
		end)()
	else
		-- TODO AVBURST-1456 - Investigate if we need to SetThrottleFramerateEnabled in the Avatar Editor still
		--RunService:setThrottleFramerateEnabled(false)
		self.running = true
		self.characterLoader:start()
		self.backgroundSceneManager:start()
		self.cameraManager:start()
		self.characterMover:start()
		self.props.setPageLoaded()
	end
end

function AvatarSceneManager:stop()
	if GetFFlagAvatarExperienceSaveManagerInitialization() and not self.running then
		return
	end

	--RunService:setThrottleFramerateEnabled(true)
	self.running = false
	self.characterLoader:stop()
	self.backgroundSceneManager:stop()
	self.cameraManager:stop()
	self.characterMover:stop()
end

function AvatarSceneManager:onDestroy()
	self.characterLoader:onDestroy()
	self.backgroundSceneManager:onDestroy()
	self.cameraManager:onDestroy()
	self.characterMover:onDestroy()
end

return RoactRodux.UNSTABLE_connect2(
	function(state, _props)
		return {
			avatarPageLoaded = GetFFlagLuaAppEnableAERedesign() and state.AvatarExperience.AvatarEditor.PageLoaded,
			avatarEditorFullView = FFlagLuaAppEnableAERedesign() and state.AvatarExperience.AvatarEditor.FullView or false,
			catalogFullView = IsLuaCatalogPageEnabled and state.AvatarExperience.Catalog.FullView,
			avatarEditorUIFullView = FFlagLuaAppEnableAERedesign() and state.AvatarExperience.AvatarEditor.UIFullView or false,
			catalogUIFullView = IsLuaCatalogPageEnabled and state.AvatarExperience.Catalog.UIFullView,
			routeHistory = state.Navigation.history,
			tryOnItem = IsLuaCatalogPageEnabled and state.AvatarExperience.AvatarScene.TryOn.SelectedItem or nil,
			sceneManagerEnabled = state.SceneManagerEnabled,
		}
	end,
	function(dispatch)
		return {
			toggleAvatarEditor3DFullView = function()
				dispatch(ToggleAvatarEditor3DFullView())
			end,
			toggleCatalog3DFullView = function()
				dispatch(ToggleCatalog3DFullView())
			end,
			closeAllItemDetails = function()
				dispatch(CloseAllItemDetails())
			end,
			setPageLoaded = function()
				dispatch(SetPageLoaded(true))
			end,
			toggleCatalogUIFullView = function()
				dispatch(ToggleCatalogUIFullView())
			end,
			toggleAvatarEditorUIFullView = function()
				dispatch(ToggleAvatarEditorUIFullView())
			end,
			clearSelectedItem = function()
				dispatch(ClearSelectedItem())
			end,
		}
	end
)(AvatarSceneManager)
