local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)

local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetCategoryAndSubcategory)
local NavigationFrame = require(Modules.AvatarExperience.Common.Components.NavBar.NavigationFrame)
local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)

local Navigation = Roact.PureComponent:extend("Navigation")

local function hasNotBeenAccessed(state)
	return function(key)
		return PerformFetch.GetStatus(state, key) == RetrievalStatus.NotStarted
	end
end

function Navigation:init()
	self.setCategory = function(index)
		self.props.setCategoryAndSubcategory(index, nil)
	end
	self.setSubcategory = function(categoryIndex, tabIndex)
		self.props.setCategoryAndSubcategory(nil, tabIndex)
	end
end

function Navigation:updateAssets()
	local categoryIndex = self.props.categoryIndex
	local subcategoryIndex = self.props.subcategoryIndex

	return function(prevProps, scrollingFrameRef)
		local oldCategoryIndex = prevProps.categoryIndex
		local oldSubcategory = prevProps.subcategoryIndex

		local changedCategory = categoryIndex ~= oldCategoryIndex
		local changedSubcategory = subcategoryIndex ~= oldSubcategory

		if not (changedCategory or changedSubcategory) then
			return
		end

		if changedCategory and scrollingFrameRef.current then
			scrollingFrameRef.current.CanvasPosition = Vector2.new()
		end
	end
end

function Navigation:willUpdate(nextProps)
	if (nextProps.categoryIndex ~= self.props.categoryIndex
		or nextProps.subcategoryIndex ~= self.props.subcategoryIndex) and self.props.selectedItem.itemId ~= nil then
		self.props.deselectPeekedItem()
		self.props.closeAllItemDetails()
	end
end

function Navigation:render()
	local layoutOrderMain = self.props.layoutOrderMain
	local layoutOrderSub = self.props.layoutOrderSub
	local navHeightMain = self.props.navHeightMain
	local navHeightSub = self.props.navHeightSub
	local categoryIndex = self.props.categoryIndex
	local subcategoryIndex = self.props.subcategoryIndex
	local absoluteSizeChanged = self.props.absoluteSizeChanged

	return Roact.createElement(NavigationFrame, {
		layoutOrderMain = layoutOrderMain,
		navHeightMain = navHeightMain,
		layoutOrderSub = layoutOrderSub,
		navHeightSub = navHeightSub,
		categoryTable = Categories,
		categoryIndex = categoryIndex,
		selectCategory = self.setCategory,
		subcategoryIndex = subcategoryIndex,
		subcategoryTable = Categories[categoryIndex].Subcategories,
		update = self:updateAssets(),
		selectSubcategory = self.setSubcategory,
		absoluteSizeChanged = absoluteSizeChanged,
	})
end

local function mapStateToProps(state)
	return {
		selectedItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem,
		categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category,
		subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory,
		hasNotBeenAccessed = hasNotBeenAccessed(state),
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setCategoryAndSubcategory = function(category, subcategory)
			dispatch(SetCategoryAndSubcategory(category, subcategory))
		end,
		deselectPeekedItem = function()
			dispatch(ClearSelectedItem())
		end,
		closeAllItemDetails = function()
			dispatch(CloseAllItemDetails())
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(Navigation)
