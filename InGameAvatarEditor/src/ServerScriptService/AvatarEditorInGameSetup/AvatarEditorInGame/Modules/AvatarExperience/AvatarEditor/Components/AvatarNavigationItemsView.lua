local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local CategoryContent = require(Modules.AvatarExperience.AvatarEditor.Components.CategoryContent)
local Navigation = require(Modules.AvatarExperience.AvatarEditor.Components.Navigation)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetCategoryAndSubcategory)

local NavigationItemsView = Roact.PureComponent:extend("NavigationItemsView")

NavigationItemsView.defaultProps = {
	swipeNavigationEnabled = false,
}

function NavigationItemsView:init()
	self.contentRef = Roact.createRef()

	self.setCategory = function(index)
		self.props.setCategoryAndSubcategory(index, nil)
	end
	self.setSubcategory = function(tabIndex)
		self.props.setCategoryAndSubcategory(nil, tabIndex)
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
                self.setSubcategory(newSubcategoryIndex)
                return
            end
        end

        local newCategoryIndex = categoryIndex + direction
        if newCategoryIndex > 0 and newCategoryIndex <= #Categories then
            self.setCategory(newCategoryIndex)
        end
	end

	self.onNavBarSizeChanged = function(absoluteSize)
		if self.contentRef.current then
			self.contentRef.current.Size = UDim2.new(1, 0, 1, -absoluteSize.Y)
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
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		return Roact.createElement("Frame", {
			BackgroundColor3 = theme.BackgroundDefault.Color,
			BackgroundTransparency = theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),

			[Roact.Ref] = self.props.ref,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			NavBar = Roact.createElement(Navigation, {
				layoutOrderMain = 1,
				layoutOrderSub = 2,
				navHeightMain = 40,
				navHeightSub = 40,
				absoluteSizeChanged = self.onNavBarSizeChanged,
			}),

			CategoryContent = Roact.createElement(CategoryContent, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 2,
				ref = self.contentRef,

				navigateLeft = self.navigateLeft,
				navigateRight = self.navigateRight,
			}),
		})
	end)
end


local function mapStateToProps(state)
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory

	return {
		categoryIndex = categoryIndex,
		subcategoryIndex = subcategoryIndex,
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
