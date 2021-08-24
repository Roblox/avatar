--[[
    Creates a Roact Component which includes a frame for both a main navigation bar and sub navigation bar within
        a list layout

	Props:
        layoutOrderMain: (number) Used tp set the layout order of the main navigation bar within the list layout
        layoutOrderSub: (number) Used tp set the layout order of the sub navigation bar within the list layout
        navHeightMain: (number) Defines the height of the main navigation bar
        navHeightSub: (number) Defines the height of the sub navigation bar
        categories : (table) Table of main categories (see AECategories.lua or Categories.lua)
        categoryIndex : (number) Index of the current category that is selected
        subcategories: (table) Table of sub categories (see AECategories.lua or Categories.lua)
        subcategoryIndex: (number) Index of the current subcategory that is selected
        selectCategory: (function) Dispatch to a thunk that updates the selected category
        selectSubcategory: (function) Dispatch to a thunk that updates the selected subcategory
        update: (function) Function that is called when a category/subcategory is selected
        absoluteSizeChanged: (function - optional)  Function that is called when the NavigationFrame changes size
            (can be used to change the size of an itemlist frame if the nav bar needs to take up more vertical room)
]]

local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local FitChildren = require(Modules.NotLApp.FitChildren)
local withStyle = UIBlox.Style.withStyle

local MainNavigation = require(Modules.AvatarExperience.Common.Components.NavBar.MainNavigation)
local SubNavigation = require(Modules.AvatarExperience.Common.Components.NavBar.SubNavigation)

local NavigationFrame = Roact.PureComponent:extend("NavigationFrame")

function NavigationFrame:init()
    self.onAbsoluteSizeChanged = function(rbx)
        local absoluteSizeChanged = self.props.absoluteSizeChanged

        if absoluteSizeChanged then
            absoluteSizeChanged(rbx.AbsoluteSize)
        end
    end
end

function NavigationFrame:render()
    local layoutOrderMain = self.props.layoutOrderMain
    local layoutOrderSub = self.props.layoutOrderSub
    local navHeightMain = self.props.navHeightMain
    local navHeightSub = self.props.navHeightSub
    local categories = self.props.categoryTable
    local categoryIndex = self.props.categoryIndex
    local subcategories = self.props.subcategoryTable
    local subcategoryIndex = self.props.subcategoryIndex
    local selectCategory = self.props.selectCategory
    local update = self.props.update
    local selectSubcategory = self.props.selectSubcategory
    local subcategoriesExist = categories[categoryIndex].Subcategories

    return withStyle(function(stylePalette)
        local theme = stylePalette.Theme

        return Roact.createElement(FitChildren.FitFrame, {
            BackgroundColor3 = theme.BackgroundContrast.Color,
            BackgroundTransparency = theme.BackgroundContrast.Transparency,
            BorderSizePixel = 0,
            LayoutOrder = layoutOrderMain,
            Size = UDim2.new(1, 0, 0, navHeightMain),
            ZIndex = 3,

            [Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,

            fitFields = {
                Size = FitChildren.FitAxis.Height,
            },
        }, {
            ListLayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
            }),

            Main = Roact.createElement(MainNavigation, {
                layoutOrder = layoutOrderMain,
                navHeight = navHeightMain,
                zIndex = 1,
                categories = categories,
                categoryIndex = categoryIndex,
                selectCategory = selectCategory,
                subcategorySelected = subcategoryIndex ~= 0 and subcategoriesExist,
            }),

            Sub = Roact.createElement(SubNavigation, {
                layoutOrder = layoutOrderSub,
                navHeight = navHeightSub,
                categoryIndex = categoryIndex,
                subcategoryIndex = subcategoryIndex,
                subcategories = subcategories,
                update = update,
                selectSubcategory = selectSubcategory
            })
        })
    end)
end

return NavigationFrame