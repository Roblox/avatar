local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local Categories = require(Modules.AvatarExperience.Catalog.Categories)

local CatalogItemsList = require(Modules.AvatarExperience.Catalog.Components.ItemsList.ItemsList)
local CatalogNavigation = require(Modules.AvatarExperience.Catalog.Components.NavBar.CatalogNavigation)

local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Thunks.SetCategoryAndSubcategory)

local MAIN_NAV_HEIGHT = 40
local SUB_NAV_HEIGHT = 40

local NavigationItemsView = Roact.PureComponent:extend("NavigationItemsView")

NavigationItemsView.defaultProps = {
    swipeNavigationEnabled = false,
}

function NavigationItemsView:init()
	self.itemsListRef = Roact.createRef()

	self.selectCategory = function(index)
		self.props.setCategoryAndSubcategory(index, nil)
	end

	self.selectSubcategory = function(index)
		self.props.setCategoryAndSubcategory(nil, index)
	end

    self.navigate = function(direction)
        local swipeNavigationEnabled = self.props.swipeNavigationEnabled
        if not swipeNavigationEnabled then
            return
        end

        local categoryIndex = self.props.categoryIndex
        local subcategoryIndex = self.props.subcategoryIndex

        local subcategories = Categories[categoryIndex].Subcategories

        if subcategories and subcategoryIndex ~= 0 then
            local newSubcategoryIndex = subcategoryIndex + direction
            if newSubcategoryIndex > 0 and newSubcategoryIndex <= #subcategories then
                self.selectSubcategory(newSubcategoryIndex)
                return
            end
        end

        local newCategoryIndex = categoryIndex + direction
        if newCategoryIndex > 0 and newCategoryIndex <= #Categories then
            self.selectCategory(newCategoryIndex)
        end
    end

    self.onNavBarSizeChanged = function(absoluteSize)
        if self.itemsListRef.current then
            self.itemsListRef.current.Size = UDim2.new(1, 0, 1, -absoluteSize.Y)
        end
    end

    self.navigateLeft = function()
        self.navigate(-1)
    end

    self.navigateRight = function()
        self.navigate(1)
    end
end

function NavigationItemsView:render()
    local categoryIndex = self.props.categoryIndex
    local subcategoryIndex = self.props.subcategoryIndex

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),

        [Roact.Ref] = self.props.ref,
    }, {
        ListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        }),

        NavBar = Roact.createElement(CatalogNavigation, {
            layoutOrderMain = 1,
            layoutOrderSub = 2,
            navHeightMain = MAIN_NAV_HEIGHT,
            navHeightSub = SUB_NAV_HEIGHT,
            absoluteSizeChanged = self.onNavBarSizeChanged,
        }),

        ItemsList = Roact.createElement(CatalogItemsList, {
            size = UDim2.new(1, 0, 1, 0),
            ref = self.itemsListRef,
            categoryIndex = categoryIndex,
            subcategoryIndex = subcategoryIndex,
            layoutOrder = 2,

            navigateLeft = self.navigateLeft,
            navigateRight = self.navigateRight,
        }),
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

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(NavigationItemsView)
