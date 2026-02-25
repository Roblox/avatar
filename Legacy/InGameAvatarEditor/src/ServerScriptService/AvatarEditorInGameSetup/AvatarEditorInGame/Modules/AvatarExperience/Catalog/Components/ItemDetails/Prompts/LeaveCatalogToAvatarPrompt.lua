-- Props:
-- itemType
-- itemSubType
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local Functional = require(Modules.Common.Functional)
local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)
local AppPage = require(Modules.NotLApp.AppPage)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetCategoryAndSubcategory)

local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local GetFFlagLuaAppEnableAERedesign = function() return true end

local FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory = true

local UIBlox = require(Modules.Packages.UIBlox)
local InteractiveAlert = UIBlox.App.Dialog.Alert.InteractiveAlert
local ButtonType = UIBlox.App.Button.Enum.ButtonType

local LeaveCatalogToAvatarPrompt = Roact.PureComponent:extend("LeaveCatalogToAvatarPrompt")

function LeaveCatalogToAvatarPrompt:init()
	self.openAvatarPage = function()
		local itemType = self.props.itemType
		local itemSubType = self.props.itemSubType

		if GetFFlagLuaAppEnableAERedesign() then
			local category
			local subcategory
			if itemType == CatalogConstants.ItemType.Asset then
				category = AvatarEditorConstants.AssetTypeToCategory[itemSubType]
				subcategory = AvatarEditorConstants.AssetTypeToSubcategory[itemSubType]
			elseif itemType == CatalogConstants.ItemType.Bundle then
				if FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory then
					category = AvatarEditorConstants.BundleTypeToCategory[itemSubType]
				else
					category = AvatarEditorConstants.AvatarEditorStructure.Categories.Characters
				end
			end

			self.props.setCategoryAndSubcategory(category, subcategory)
		end

		self.props.closePrompt()
		self.props.navigateToAvatarEditor()
	end
end

function LeaveCatalogToAvatarPrompt:didMount()
	-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE this temporary fix.
	local pageFilter = self.props.pageFilter
	local currentPage = self.props.currentPage
	if pageFilter and not Functional.Find(pageFilter, currentPage) then
		self.props.closePrompt()
	end
end

function LeaveCatalogToAvatarPrompt:renderAlertLocalized(localized)
	return Roact.createElement(InteractiveAlert, {
		title = localized.titleText,
		bodyText = localized.messageText,
		buttonStackInfo = {
			buttons = {
				{
					props = {
						onActivated = self.props.closePrompt,
						text = localized.cancelButtonText,
					},
				},
				{
					buttonType = ButtonType.PrimarySystem,
					props = {
						onActivated = self.openAvatarPage,
						text = localized.confirmButtonText,
					},
				},
			},
		},
		screenSize = self.props.screenSize,
	})
end

function LeaveCatalogToAvatarPrompt:render()
	return withLocalization({
		titleText = "Feature.Catalog.Action.Customize",
		messageText = "Feature.Catalog.Label.ShopToAvatarPage",
		confirmButtonText = "Feature.Catalog.Action.Customize",
		cancelButtonText = "Feature.Catalog.Action.Cancel",
	})(function(localized)
		return self:renderAlertLocalized(localized)
	end)
end

LeaveCatalogToAvatarPrompt = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE currentRoute/currentPage.
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			currentPage = currentRoute[#currentRoute].name,
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			closePrompt = function()
				dispatch(CloseCentralOverlay())
			end,
			navigateToAvatarEditor = function(page)
				--[[
				if FFlagEnableAvatarExperienceLandingPage then
					dispatch(NavigateToRoute({
						{ name = AppPage.AvatarExperienceLandingPage },
						{ name = AppPage.AvatarEditor }
					}))
				else
					dispatch(NavigateToRoute({ { name = AppPage.AvatarEditor } }))
				end
				--]]
				dispatch(NavigateDown({name = AppPage.AvatarEditor}))
			end,
			setCategoryAndSubcategory = function(category, subcategory)
				dispatch(SetCategoryAndSubcategory(category, subcategory))
			end,
		}
	end
)(LeaveCatalogToAvatarPrompt)

return LeaveCatalogToAvatarPrompt
