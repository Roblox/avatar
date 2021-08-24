local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local Categories = require(Modules.AvatarExperience.Catalog.Categories)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Thunks.SetCategoryAndSubcategory)
local NavigationFrame = require(Modules.AvatarExperience.Common.Components.NavBar.NavigationFrame)

local CatalogNavigation = Roact.PureComponent:extend("CatalogNavigation")

function CatalogNavigation:init()
	self.selectCategory = function(index)
		self.props.setCategoryAndSubcategory(index, nil)
	end

	self.selectSubcategory = function(_, subCategoryIndex)
		self.props.setCategoryAndSubcategory(nil, subCategoryIndex)
    end

    self.updateAssets = function(prevProps, scrollingFrameRef)
        local categoryIndex = self.props.categoryIndex
        local oldCategoryIndex = prevProps.categoryIndex

        local changedCategory = categoryIndex ~= oldCategoryIndex

        if changedCategory then
            if scrollingFrameRef.current then
                scrollingFrameRef.current.CanvasPosition = Vector2.new()
            end
        end
    end
end

function CatalogNavigation:render()
    local layoutOrderMain = self.props.layoutOrderMain
    local layoutOrderSub = self.props.layoutOrderSub
    local navHeightMain = self.props.navHeightMain
    local navHeightSub = self.props.navHeightSub
    local categoryIndex = self.props.categoryIndex
    local subcategoryIndex = self.props.subcategoryIndex
	local absoluteSizeChanged = self.props.absoluteSizeChanged

    local selectCategory = self.selectCategory
    local selectSubcategory = self.selectSubcategory

    return Roact.createElement(NavigationFrame, {
        layoutOrderMain = layoutOrderMain,
        navHeightMain = navHeightMain,
        layoutOrderSub = layoutOrderSub,
        navHeightSub = navHeightSub,
        categoryTable = Categories,
        categoryIndex = categoryIndex,
        selectCategory = selectCategory,
        subcategoryIndex = subcategoryIndex,
        subcategoryTable = Categories[categoryIndex].Subcategories,
        update = self.updateAssets,
        selectSubcategory = selectSubcategory,
        absoluteSizeChanged = absoluteSizeChanged,
    })
end

local function mapStateToProps(state)
    return {
        categoryIndex = state.AvatarExperience.Catalog.Categories.category,
        subcategoryIndex = state.AvatarExperience.Catalog.Categories.subcategory,
    }
end

local function mapDispatchToProps(dispatch)
    return {
		setCategoryAndSubcategory = function(category, subcategory)
			dispatch(SetCategoryAndSubcategory(category, subcategory))
		end,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogNavigation)
