local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local AppPage = require(Modules.NotLApp.AppPage)

local SearchPage = require(Modules.NotLApp.SearchPage)

local AvatarEditorPage = require(Modules.AvatarExperience.AvatarEditor.Components.AvatarEditorPage)

local CatalogPage = require(Modules.AvatarExperience.Catalog.Components.CatalogPage)

local ItemDetailsPeekView = require(Modules.AvatarExperience.Catalog.Components.ItemDetailsPeekView)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)

local CentralOverlay = require(script.Parent.CentralOverlay)

local DisplayedPageManager = Roact.PureComponent:extend("DisplayedPageManager")

function DisplayedPageManager:init()
	self.peekViewCount = 0
end

function DisplayedPageManager:willUpdate(nextProps)
	if self.props.itemId ~= nextProps.itemId then
		self.peekViewCount = self.peekViewCount + 1
	end
end

function DisplayedPageManager:render()
	local page = self.props.page

	local pages = {}

	pages.CentralOverlay = Roact.createElement(CentralOverlay)

	if page == AppPage.AvatarEditor then
		pages.AvatarEditor = Roact.createElement(AvatarEditorPage)
	elseif page == AppPage.Catalog then
		pages.Catalog = Roact.createElement(CatalogPage)
	elseif page == AppPage.ItemDetails then
		pages.Catalog = Roact.createElement(CatalogPage)
		pages["ItemDetails" .. tostring(self.peekViewCount)] = Roact.createElement(ItemDetailsPeekView, {
			itemId = self.props.itemId,
			itemType = self.props.itemType,
		})
	elseif page == AppPage.SearchPage then
		pages.SearchPage = Roact.createElement(SearchPage, {
			searchUuid = self.props.lastSearchUUid,
		})
	end
	return Roact.createFragment(pages)
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			page = AvatarExperienceUtils.getCurrentPage(state),
			lastSearchUUid = state.LastSearch,
			itemId = state.ItemDetailsProps.itemId,
			itemType = state.ItemDetailsProps.itemType,
		}
	end, nil)(DisplayedPageManager)