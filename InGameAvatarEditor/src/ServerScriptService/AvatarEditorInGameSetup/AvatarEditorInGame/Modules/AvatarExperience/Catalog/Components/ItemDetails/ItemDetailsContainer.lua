local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local LoadableImage = UIBlox.Loading.LoadableImage

local LoadingStateWrapper = require(Modules.NotLApp.LoadingStateWrapper)
local FitChildren = require(Modules.NotLApp.FitChildren)
local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local EmptyStatePage = require(Modules.NotLApp.EmptyStatePage)
local getSafeAreaSize = require(Modules.NotLApp.getSafeAreaSize)

local SetSelectedItem = require(Modules.AvatarExperience.Common.Actions.SetSelectedItem)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local ItemDescription = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemDescription)
local ItemStatistics = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemStatistics)
local ItemInfoList = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemInfoList)
local RecommendedItemsGrid = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.RecommendedItemsGrid)
local BundleItemsGrid = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.BundleItemsGrid)

local FetchItemData = require(Modules.AvatarExperience.Catalog.Thunks.FetchItemData)

local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)

local TITLE_PADDING = 12
local INNER_PADDING = 24
local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["420"]

local function cardIsSelected(state, props)
	local selectedItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

	if props.itemId == selectedItem.itemId then
		return true
	end

	return false
end

local function getTopPageFromProps(routeHistory)
	local route = routeHistory[#routeHistory]
	return route[#route]
end

local function valuesAsCommaSeparatedString(myTable)
	local result = ""
	for _,v in pairs(myTable) do
		result = result .. (result ~= "" and ", " or "")
		result = result .. tostring(v)
	end
	return result
end

local ItemDetailsContainer = Roact.PureComponent:extend("ItemDetailsContainer")

ItemDetailsContainer.defaultProps = {
	listPadding = 24,
}

function ItemDetailsContainer:init()
	self.backgroundRef = Roact.createRef()
	self.ref = Roact.createRef()

	self.state = {
		width = 0,
	}

	self.fetchItemDetailsPageData = function()
		local itemId = tostring(self.props.itemId)
		local itemType = self.props.itemType

		return self.props.fetchItemData(itemId, itemType)
	end

	self.onCanvasPositionChanged = function(rbx)
		if self.backgroundRef.current ~= nil then
			local offset = -rbx.CanvasPosition.Y
			self.backgroundRef.current.Position = UDim2.new(0, 0, 0, offset)
		end
	end

	self.onItemHeaderMoved = function(itemHeader)
		if not self.props.actionBarHeaderRef then
			return
		end

		local actionBarHeader = self.props.actionBarHeaderRef.current
		if not actionBarHeader then
			return
		end

		local actionBarHeaderPosition = actionBarHeader.AbsolutePosition.Y + actionBarHeader.AbsoluteSize.Y / 2
		local itemHeaderPosition = itemHeader.AbsolutePosition.Y + itemHeader.AbsoluteSize.Y / 2
		local itemHeaderVisible = actionBarHeaderPosition > itemHeaderPosition

		actionBarHeader.Visible = not itemHeaderVisible

		for _, child in pairs(itemHeader:GetChildren()) do
			if child:IsA("GuiObject") then
				child.Visible = itemHeaderVisible
			end
		end
	end
end

function ItemDetailsContainer:didMount()
	-- Remove self.isMounted when FFlagLuaCatalogRefactorSpawns is on
	self.isMounted = true
	self.fetchItemDetailsPageData()

	local itemType = self.props.itemType
	local itemInfo = self.props.itemInfo
	local itemSubType = CatalogUtils.GetItemSubType(itemType, itemInfo)
	self.props.selectItem(self.props.itemId, itemType, itemSubType)
end

function ItemDetailsContainer:didUpdate(prevProps)
	local itemId = self.props.itemId
	local itemType = self.props.itemType
	local itemInfo = self.props.itemInfo
	local itemSubType = CatalogUtils.GetItemSubType(itemType, itemInfo)
	local curPage = getTopPageFromProps(self.props.routeHistory)
	local detail = self.props.detail
	local curPageItemId = curPage.extraProps and curPage.extraProps.itemId
	local curTryOn = self.props.selectedItem

	--[[
	if curPage.name == AppPage.ItemDetails and curPage.detail == detail
		and curPageItemId ~= curTryOn.itemId and itemSubType then
		self.props.selectItem(itemId, itemType, itemSubType)
	end
	--]]
end

function ItemDetailsContainer:willUnmount()
	-- Remove self.isMounted when FFlagLuaCatalogRefactorSpawns is on
	self.isMounted = false

	self.props.unselectItem()
end

function ItemDetailsContainer:renderDetails()
	local itemId = tostring(self.props.itemId)
	local itemType = self.props.itemType
	local listPadding = self.props.listPadding
	local itemSubType = self.props.itemSubType
	local itemInfo = self.props.itemInfo

	local width = self.state.width
	local thumbType = CatalogUtils.GetRbxThumbType(itemType)
	local thumbnail = CatalogUtils.MakeRbxThumbUrl(thumbType, itemId, THUMBNAIL_SIZE, THUMBNAIL_SIZE)
	local isResellable = CatalogUtils.IsResellable(itemInfo)

	local backgroundHeight = (self.state.width * 9 / 16)

	local genreCsv = ""
	if itemInfo.genres then
		genreCsv = valuesAsCommaSeparatedString(itemInfo.genres)
	end

	local renderFuntion = function(localized)
		return withStyle(function(stylePalette)
			local theme = stylePalette.Theme
			local font = stylePalette.Font
			local headerTextSize = font.BaseSize * font.Header1.RelativeSize
			local imagePositionY = headerTextSize + TITLE_PADDING + INNER_PADDING

			return Roact.createElement(FitChildren.FitFrame, {
				BackgroundColor3 = theme.BackgroundDefault.Color,
				BackgroundTransparency = theme.BackgroundDefault.Transparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				ItemBackground = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(1, INNER_PADDING * 2, 1, 0),
					ZIndex = 0,
					BackgroundColor3 = theme.BackgroundMuted.Color,
					BackgroundTransparency = theme.BackgroundMuted.Transparency,
					BorderSizePixel = 0,
				}, {
					UIGradient = Roact.createElement("UIGradient", {
						Rotation = -90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.4, 0),
							NumberSequenceKeypoint.new(1, 1)
						}),
					})
				}),
				InnerFrame = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					ZIndex = 1,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					ListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0,listPadding),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					PagePadding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, INNER_PADDING),
						PaddingBottom = UDim.new(0, INNER_PADDING),
						PaddingLeft = UDim.new(0, INNER_PADDING),
						PaddingRight = UDim.new(0, INNER_PADDING),
					}),
					ItemThumbnail = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.new(1, 0, 0, THUMBNAIL_SIZE),
						fitAxis = FitChildren.FitAxis.Height,
					}, {
						ListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, TITLE_PADDING),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						NameHeader = Roact.createElement(FitChildren.FitFrame, {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							LayoutOrder = 0,

							fitAxis = FitChildren.FitAxis.Height,
							[Roact.Change.AbsolutePosition] = self.onItemHeaderMoved,
						}, {
							NameLabel = Roact.createElement(FitTextLabel, {
								BackgroundTransparency = 1,
								Font = font.Header1.Font,
								Size = UDim2.new(1, 0, 0, 0),
								Text = itemInfo.name,
								TextSize = headerTextSize,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = theme.TextEmphasis.Color,
								TextWrapped = true,
							}),

							RefUpdater = Roact.createElement("Frame", {
								Size = UDim2.new(0, 0, 0, 0),
								Transparency = 1,
								[Roact.Ref] = function(rbx)
									if rbx and rbx.Parent then
										self.onItemHeaderMoved(rbx.Parent)
									end
								end
							}),
						}),
						Image = Roact.createElement(LoadableImage, {
							BackgroundTransparency = 1,
							Image = thumbnail,
							LayoutOrder = 1,
							Size = UDim2.new(0, backgroundHeight, 0, backgroundHeight),
							useShimmerAnimationWhileLoading = true,
						})
					}),
					BundleIncludedItems = itemType == CatalogConstants.ItemType.Bundle and Roact.createElement(BundleItemsGrid, {
						itemId = itemId,
						itemType = itemType,
						LayoutOrder = 2,
					}),
					ItemDescription = Roact.createElement(ItemDescription, {
						compactNumberOfLines = 3,
						descriptionText = itemInfo.description,
						LayoutOrder = 3,
						width = not true and (width - INNER_PADDING * 2) or nil,
					}),
					ItemStatistics = Roact.createElement(ItemStatistics, {
						favoritesCount = itemInfo.favoriteCount,
						LayoutOrder = 4,
						purchasesCount = itemInfo.purchaseCount,
						listPadding = 10,
						width = (width - INNER_PADDING * 2),
					}),
					ItemInfoList = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						fitAxis = FitChildren.FitAxis.Height,
						LayoutOrder = 5,
						Size = UDim2.new(1, 0, 0, 0),
					}, {
						ListLayout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						ItemInfoList = Roact.createElement(ItemInfoList, {
							creatorId = itemInfo and itemInfo.creator and itemInfo.creator.id,
							creatorText = itemInfo and itemInfo.creator and itemInfo.creator.name,
							LayoutOrder = 1,
							genreText = genreCsv,
							showAllDividers = isResellable,
							itemType = itemType,
							itemSubType = itemSubType,
						}),
					}),
					RecommendedLabel = Roact.createElement(FitTextLabel, {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						fitAxis = FitChildren.FitAxis.Both,
						Font = font.Header1.Font,
						LayoutOrder = 8,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Text = localized.recommendedLabel,
						TextSize = headerTextSize,
						TextColor3 = theme.TextEmphasis.Color,
					}),
					RecommendedGridView = Roact.createElement(RecommendedItemsGrid, {
						itemId = itemId,
						itemSubType = itemSubType,
						itemType = itemType,
						LayoutOrder = 9,
					}),
				}),
			})
		end)
	end

	return withLocalization({
		recommendedLabel = "Feature.Catalog.Label.Recommendations",
		resellLabel = "Feature.Catalog.Heading.Sellers",
	})(function(localized)
		return renderFuntion(localized)
	end)
end

function ItemDetailsContainer:renderOnFailed()
	local onRetry = self.fetchItemDetailsPageData
	local globalGuiInset = self.props.globalGuiInset
	local screenSize = self.props.screenSize

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)
	local actionBarHeight = CatalogConstants.ActionBar.ActionBarHeight + CatalogConstants.ActionBar.ActionBarGradientHeight

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, safeAreaSize.Y.Scale, safeAreaSize.Y.Offset - actionBarHeight),
	}, {
		EmptyStatePage = Roact.createElement(EmptyStatePage, {
			onRetry = onRetry,
		})
	})
end

function ItemDetailsContainer:render()
	local onRetry = self.fetchItemDetailsPageData
	local fetchingState = self.props.fetchingState

	--print("Fetching state:", self.props.fetchingState)

	local renderFuntion = function(stylePalette)
		local theme = stylePalette.Theme

		return Roact.createElement(FitChildren.FitFrame, {
			BackgroundColor3 = theme.BackgroundDefault.Color,
			BackgroundTransparency = theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			fitAxis = FitChildren.FitAxis.Height,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 0),

			[Roact.Ref] = self.ref,
			[Roact.Change.AbsoluteSize] = function(rbx)
				if self.state.width ~= rbx.AbsoluteSize.X then
					self:setState({
						width = rbx.AbsoluteSize.X,
					})
				end
			end
		}, {
			LoadingState = Roact.createElement(LoadingStateWrapper, {
				debugName = "Item Details Container",
				dataStatus = fetchingState,
				isStateLockedAfterLoaded = false,
				onRetry = onRetry,
				renderOnLoading = function() return self:renderDetails() end,
				renderOnLoaded = function() return self:renderDetails() end,
				renderOnFailed = function() return self:renderOnFailed() end,
				stateMappingStyle = LoadingStateWrapper.StateMappingStyle.DirectMapping,
			}),
		})
	end
	return withStyle(renderFuntion)
end

ItemDetailsContainer = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local itemInfo = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
		--print("props.itemId:", props.itemId)
		return {
			globalGuiInset = state.GlobalGuiInset,
			screenSize = state.ScreenSize,
			routeHistory = state.Navigation.history,
			selectedItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem,
			fetchingState = PerformFetch.GetStatus(state, CatalogUtils.GetItemDetailsKey(props.itemId, props.itemType)),
			itemInfo = itemInfo,
			itemSubType = CatalogUtils.GetItemSubType(props.itemType, itemInfo),
			isSelected = cardIsSelected(state, props),
		}
	end,
	function(dispatch)
		return {
			fetchItemData = function(itemId, itemType)
				return dispatch(FetchItemData(itemId, itemType))
			end,

			selectItem = function(itemId, itemType, itemSubType)
				print("Selecting item!", itemId, itemType, itemSubType)
				dispatch(SetSelectedItem(itemId, itemType, itemSubType))
			end,

			unselectItem = function()
				--dispatch(SetItemDetailsProps(nil, nil))
				dispatch(ClearSelectedItem())
			end,
		}
	end
)(ItemDetailsContainer)

return ItemDetailsContainer
