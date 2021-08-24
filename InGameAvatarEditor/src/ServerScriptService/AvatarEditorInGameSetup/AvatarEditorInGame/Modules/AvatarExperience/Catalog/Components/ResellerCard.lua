--[[
	Props:
		itemId (string)
		itemType (string)
		itemPrice (int)
		sellerId (string)
		sellerName (string)
		productId (string)
		serialNumber (int)
]]
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)
local RoactLocalization = require(Modules.Services.RoactLocalization)
local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local Constants = require(Modules.NotLApp.Constants)
local FitChildren = require(Modules.NotLApp.FitChildren)
local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local ImageSetButton = UIBlox.Core.ImageSet.Button
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local UrlBuilder = require(Modules.NotLApp.Http.UrlBuilder)
local NumberLocalization = require(Modules.Packages.Localization.NumberLocalization)

local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local withStyle = UIBlox.Style.withStyle
local Images = UIBlox.App.ImageSet.Images

local DEFAULT_THUMBNAIL_ICON = Constants.AVATAR_PLACEHOLDER_IMAGE
local BACKGROUND_IMAGE_9_SLICE = Images["component_assets/circle_17"]
local USER_THUMBNAIL_MASK = "rbxasset://textures/ui/LuaApp/graphic/profilemask.png"
local LIMITED_ITEM_ICON = Images["icons/status/item/limited"]
local ROBUX_ICON = Images["icons/common/robux"]

local THUMBNAIL_TYPE = CatalogConstants.ThumbnailType.AvatarHeadShot
local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["48"]
local AVATAR_THUMBNAIL_SIZE = 48

local ROBUX_ICON_SIZE = 25
local BUY_BUTTON_HEIGHT = 44
local SERIAL_NUMBER_PADDING = 4

local INNER_PADDING = 24
local PADDING_BETWEEN_IMAGE = 12

local ResellerCard = Roact.PureComponent:extend("ResellerCard")

function ResellerCard:init()
    self.viewProfile = function()
        self.props.navigateDown({
            name = AppPage.GenericWebPage,
            detail = UrlBuilder.user.profile({
                userId = self.props.sellerId,
            }),
            extraProps = {
                titleKey = "CommonUI.Features.Label.Profile",
            },
        })
	end

	self.openPurchasePrompt = function()
		local productId = self.props.productId
        self.props.openPurchasePrompt(productId)
	end
end

function ResellerCard:render()
    local serialNumber = self.props.serialNumber
    local sellerId = self.props.sellerId
    local sellerName = self.props.sellerName
    local itemPrice = self.props.itemPrice
	local layoutOrder = self.props.LayoutOrder
	local localization = self.props.localization

	local userThumbnail = CatalogUtils.MakeRbxThumbUrl(THUMBNAIL_TYPE, sellerId, THUMBNAIL_SIZE, THUMBNAIL_SIZE)

    return withStyle(function(stylePalette)
        local theme = stylePalette.Theme
        local font = stylePalette.Font

        local maskColor = theme.BackgroundDefault.Color

        local serialNumberFont = font.Footer
        local serialNumberFontSize = serialNumberFont.RelativeSize * font.BaseSize

		local parsedItemPrice = string.format("%.0f", itemPrice)
		local itemPriceText = NumberLocalization.localize(parsedItemPrice, localization:GetLocale())

        return Roact.createElement(FitChildren.FitFrame, {
			LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = theme.BackgroundDefault.Color,
            fitAxis = FitChildren.FitAxis.Height,
        }, {
            UIListLayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
            }),
			PagePadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, INNER_PADDING),
				PaddingRight = UDim.new(0, INNER_PADDING),
			}),
            ProfileButton = Roact.createElement(FitChildren.FitImageButton, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                fitAxis = FitChildren.FitAxis.Height,
                LayoutOrder = 1,

                [Roact.Event.Activated] = self.viewProfile,
            }, {
                UserAndStatsFrame = Roact.createElement(FitChildren.FitFrame, {
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    fitAxis = FitChildren.FitAxis.Height,
                }, {
                    UIListLayout = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = serialNumber and Enum.VerticalAlignment.Bottom
                            or Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, PADDING_BETWEEN_IMAGE)
                    }),
                    UserThumbnail = Roact.createElement(ImageSetLabel, {
                        Size = UDim2.new(0, AVATAR_THUMBNAIL_SIZE, 0, AVATAR_THUMBNAIL_SIZE),
                        BackgroundTransparency = 1,
                        Image = userThumbnail or DEFAULT_THUMBNAIL_ICON,
                        LayoutOrder = 1,
                    }, {
                        MaskFrame = Roact.createElement(ImageSetLabel, {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Image = USER_THUMBNAIL_MASK,
                            ImageColor3 = maskColor,
                        })
                    }),
                    SerialAndUsernameFrame = Roact.createElement(FitChildren.FitFrame, {
                        BackgroundTransparency = 1,
                        fitAxis = FitChildren.FitAxis.Both,
                        LayoutOrder = 2,
                    }, {
                        UIListLayout = Roact.createElement("UIListLayout", {
                            FillDirection = Enum.FillDirection.Vertical,
                            SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 3),
                        }),
                        Username = Roact.createElement(FitTextLabel, {
                            BackgroundTransparency = 1,
                            Font = font.Header2.Font,
                            TextColor3 = theme.TextEmphasis.Color,
                            TextSize = font.Header2.RelativeSize * font.BaseSize,
                            Text = sellerName,
                            fitAxis = FitChildren.FitAxis.Both,
                            LayoutOrder = 1,
                        }),
                        SerialNumberLabel = serialNumber and Roact.createElement(FitChildren.FitImageLabel, {
                            BackgroundTransparency = 1,
                            Image = BACKGROUND_IMAGE_9_SLICE,
                            ImageColor3 = theme.UIDefault.Color,
                            ImageTransparency = theme.UIDefault.Transparency,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(8, 8, 9, 9),
                            fitAxis = FitChildren.FitAxis.Both,
                            LayoutOrder = 2,
                        }, {
                            UIListLayout = Roact.createElement("UIListLayout", {
                                FillDirection = Enum.FillDirection.Horizontal,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(0, 1),
                            }),
                            UIPadding = Roact.createElement("UIPadding", {
                                PaddingTop = UDim.new(0, SERIAL_NUMBER_PADDING),
                                PaddingBottom = UDim.new(0, SERIAL_NUMBER_PADDING),
                                PaddingLeft = UDim.new(0, SERIAL_NUMBER_PADDING),
                                PaddingRight = UDim.new(0, SERIAL_NUMBER_PADDING),
                            }),
                            LimitedIcon = Roact.createElement(ImageSetLabel, {
                                Size = UDim2.new(0, serialNumberFontSize, 0, serialNumberFontSize),
                                BackgroundTransparency = 1,
                                Image = LIMITED_ITEM_ICON,
                                ImageColor3 = theme.TextEmphasis.Color,
                                LayoutOrder = 1,
                            }),
                            SerialNumberText = Roact.createElement(FitTextLabel, {
                                Size = UDim2.new(0, 0, 0, serialNumberFontSize),
                                BackgroundTransparency = 1,
                                Font = serialNumberFont.Font,
                                TextColor3 = theme.TextEmphasis.Color,
                                TextSize = serialNumberFontSize,
                                Text = "#" .. serialNumber,
                                fitAxis = FitChildren.FitAxis.Width,
                                LayoutOrder = 2,
                            }),
                        }),
                    }),
                }),
            }),
            BuyButton = Roact.createElement(ImageSetButton, {
                Size = UDim2.new(1, 0, 0, BUY_BUTTON_HEIGHT),
                BackgroundTransparency = 1,
                Image = BACKGROUND_IMAGE_9_SLICE,
                ImageColor3 = theme.ContextualPrimaryDefault.Color,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(8, 8, 9, 9),
                LayoutOrder = 2,

                [Roact.Event.Activated] = self.openPurchasePrompt,
            }, {
                PriceFrame = Roact.createElement(FitChildren.FitFrame, {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    fitAxis = FitChildren.FitAxis.Both,
                }, {
                    UIListLayout = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 4),
                    }),
                    RobuxIcon = Roact.createElement(ImageSetLabel, {
                        Size = UDim2.new(0, ROBUX_ICON_SIZE, 0, ROBUX_ICON_SIZE),
                        BackgroundTransparency = 1,
                        Image = ROBUX_ICON,
                        ImageColor3 = theme.ContextualPrimaryContent.Color,
                        ImageTransparency = theme.ContextualPrimaryContent.Transparency,
                        LayoutOrder = 1,
                    }),
                    Price = Roact.createElement(FitTextLabel, {
                        BackgroundTransparency = 1,
                        Font = font.Header2.Font,
                        TextColor3 = theme.ContextualPrimaryContent.Color,
                        TextTransparency = theme.ContextualPrimaryContent.Transparency,
                        TextSize = font.Header2.RelativeSize * font.BaseSize,
                        Text = itemPriceText,
                        fitAxis = FitChildren.FitAxis.Both,
                        LayoutOrder = 2,
                    })
                })
            }),
        })
    end)
end

local function mapDispatchToProps(dispatch)
    return {
        navigateDown = function(page)
            dispatch(NavigateDown(page))
        end,
        openPurchasePrompt = function(productId)
            MarketplaceService:PromptProductPurchase(
                Players.LocalPlayer,
                productId,
                false
            )
		end,
    }
end

local function mapStateToProps(state, props)
    local user = state.Users[props.sellerId]
	local localUserId = state.LocalUserId
	local currentRoute = state.Navigation.history[#state.Navigation.history]

    return {
		currentPage = currentRoute[#currentRoute].name,
		userRobux = state.UserRobux[localUserId],
        userName = user and user.name,
	}
end

ResellerCard = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ResellerCard)

return RoactServices.connect({
	localization = RoactLocalization,
})(ResellerCard)
