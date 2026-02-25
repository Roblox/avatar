local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local withLocalization = require(Modules.Packages.Localization.withLocalization)
local withStyle = UIBlox.Style.withStyle

local Constants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local ClearAnimationPreview = require(Modules.AvatarExperience.Common.Actions.ClearAnimationPreview)
local SetAnimationPreview = require(Modules.AvatarExperience.Common.Actions.SetAnimationPreview)
local FetchItemData = require(Modules.AvatarExperience.Catalog.Thunks.FetchItemData)

local GetFFlagCatalogAnimationIdlePreview = function() return true end

local idle = {
    AssetType = Constants.AssetTypes.IdleAnim,
    Label = "Feature.Avatar.Label.Idle",
}

local walk = {
    AssetType = Constants.AssetTypes.WalkAnim,
    Label = "Feature.Avatar.Label.Walk",
}

local run = {
    AssetType = Constants.AssetTypes.RunAnim,
    Label = "Feature.Avatar.Label.Run",
}

local jump = {
    AssetType = Constants.AssetTypes.JumpAnim,
    Label = "Feature.Avatar.Label.Jump",
}

local fall = {
    AssetType = Constants.AssetTypes.FallAnim,
    Label = "Feature.Avatar.Label.Fall",
}

local climb = {
    AssetType = Constants.AssetTypes.ClimbAnim,
    Label = "Feature.Avatar.Label.Climb",
}

local swim = {
    AssetType = Constants.AssetTypes.SwimAnim,
    Label = "Feature.Avatar.Label.Swim",
}

local PREVIEWS = { idle, walk, run, jump, fall, climb, swim }

local PREVIEW_TIME = 2

local TEXT_HEIGHT = 20
local TEXT_PADDING = 4
local TAB_PADDING = 4
local TAB_HEIGHT = 6

local AnimationTabs = Roact.PureComponent:extend("AnimationTabs")

function AnimationTabs:init()
    self.isMounted = false
    self.isRunningLoop = false
    self.validPreviews = {}

	self.state = {
        previewIndex = 0,
	}
end

function AnimationTabs:updateValidPreviews()
    local assetsInfo = self.props.assetsInfo
    if assetsInfo then
        local validPreviews = {}
        for _, previewInfo in pairs(PREVIEWS) do
            if assetsInfo[previewInfo.AssetType] then
                validPreviews[#validPreviews + 1] = previewInfo
            end
        end

        self.validPreviews = validPreviews
    else
        self.validPreviews = {}
    end
end

function AnimationTabs:startPreviewLoop()
    if self.isRunningLoop then
        return
    end

    self.isRunningLoop = true

    spawn(function()
        if self.isMounted and self.state.previewIndex == 0 then
            self:setState({
                previewIndex = 1,
            })
        end

        while true do
            wait(PREVIEW_TIME)

            if not self.isMounted then
                self.isRunningLoop = false
                break
            end

            local validPreviews = self.validPreviews

            local currentPreviewIndex = self.state.previewIndex
            local newPreviewIndex = currentPreviewIndex + 1
            if newPreviewIndex > #validPreviews then
                newPreviewIndex = 1
            end

            self:setState({
                previewIndex = newPreviewIndex,
            })
        end
    end)
end

function AnimationTabs:renderWithStyle(stylePalette)
	local assetsInfo = self.props.assetsInfo

    if not assetsInfo then
        return
    end

    local previewIndex = self.state.previewIndex
    local validPreviews = self.validPreviews

    local previewInfo = validPreviews[previewIndex]
    if not previewInfo then
        return
    end

    local fontInfo = stylePalette.Font
    local theme = stylePalette.Theme

    local font = fontInfo.SubHeader1.Font
    local fontSize = fontInfo.BaseSize * fontInfo.SubHeader1.RelativeSize

    local tabSize = 1 / #validPreviews

    local tabsChildren = {}
    for i = 1, #validPreviews do
        local isSelected = previewIndex == i

        tabsChildren[i] = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(tabSize, 0, 1, 0),
            Position = UDim2.new(tabSize * i, 0, 0, 0),
        }, {
            Tab = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BorderSizePixel = 0,
                BackgroundColor3 = isSelected and theme.UIEmphasis.Color or theme.UIMuted.Color,
                Transparency = isSelected and theme.UIEmphasis.Transparency or theme.UIMuted.Transparency,
                Size = UDim2.new(1, -TAB_PADDING, 0, TAB_HEIGHT),
                Position = UDim2.new(0.5, 0, 0.5, 0),
            })
        })
    end

    return withLocalization({
        labelText = previewInfo.Label,
    })(function(localized)
        return Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
        }, {
            ListLayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
            }),

            Tabs = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, TEXT_HEIGHT),
                LayoutOrder = 1,
            }, tabsChildren),

            Label = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -TEXT_PADDING, 0, TEXT_HEIGHT),

                Text = localized.labelText,
                Font = font,
                TextSize = fontSize,
                TextColor3 = theme.TextEmphasis.Color,

                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,

                LayoutOrder = 2,
            })
        })
    end)
end

function AnimationTabs:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

function AnimationTabs:didUpdate(oldProps, oldState)
    local oldAssetsInfo = oldProps.assetsInfo
    local newAssetsInfo = self.props.assetsInfo

    if newAssetsInfo ~= oldAssetsInfo then
        self:updateValidPreviews()
    end

    if not oldAssetsInfo and newAssetsInfo then
        self:startPreviewLoop()
    end

    local oldPreviewIndex = oldState.previewIndex
    local newPreviewIndex = self.state.previewIndex

    if oldPreviewIndex ~= newPreviewIndex then
        local validPreviews = self.validPreviews

        local previewInfo = validPreviews[newPreviewIndex]
        local itemInfo = previewInfo and newAssetsInfo[previewInfo.AssetType] or nil
        if itemInfo then
            self.props.setAnimationPreview(itemInfo.id)
        end
    end
end

function AnimationTabs:didMount()
    self.isMounted = true

    if self.props.assetsInfo then
        self:updateValidPreviews()
        self:startPreviewLoop()
	else
		local assetIds = self.props.assetIds

		for _, assetId in ipairs(assetIds) do
			self.props.fetchItemDetails(assetId, CatalogConstants.ItemType.Asset)
		end
    end
end

function AnimationTabs:willUnmount()
    self.props.clearAnimationPreview()
    self.isMounted = false
end

local function getAssetIds(state, props)
    local bundleDetails = props.bundleDetails

    local assetIds = {}
    if bundleDetails and bundleDetails.items then
        for _, itemInfo in ipairs(bundleDetails.items) do
            if itemInfo.type == CatalogConstants.ItemType.Asset then
                assetIds[#assetIds + 1] = itemInfo.id
            end
        end
    end

    return assetIds
end

local function getAssetsInfo(state, props)
    local assetIds = getAssetIds(state, props)
    local assets = state.AvatarExperience.Common.Assets

    local assetsInfo = {}

    local hasAssetsInfo = false

    for _, assetId in ipairs(assetIds) do
        local info = assets[assetId]
        if not info then
            return
        end

        if not info.assetType then
            return
        end

        assetsInfo[info.assetType] = info
        hasAssetsInfo = true
    end

    if GetFFlagCatalogAnimationIdlePreview() then
        return hasAssetsInfo and assetsInfo or nil
    else
        return assetsInfo
    end
end

local function mapStateToProps(state, props)
	return {
        assetIds = getAssetIds(state, props),
        assetsInfo = getAssetsInfo(state, props),
	}
end

local function mapDispatchToProps(dispatch)
    return {
        fetchItemDetails = function(itemId, itemType)
			return dispatch(FetchItemData(itemId, itemType))
        end,

        clearAnimationPreview = function()
            return dispatch(ClearAnimationPreview())
        end,

        setAnimationPreview = function(assetId)
            return dispatch(SetAnimationPreview(assetId))
        end,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(AnimationTabs)
