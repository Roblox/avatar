local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local GradientFrame = require(Modules.AvatarExperience.Common.Components.NavBar.GradientFrame)
local ItemSlot = require(Modules.AvatarExperience.AvatarEditor.Components.ItemSlot)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local FitChildren = require(Modules.NotLApp.FitChildren)
local withStyle = UIBlox.Style.withStyle

local SLOTS_HEIGHT = 72
local SLOT_PADDING = 12
local SLOT_SIZE = 48

local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["150"]

local EquipSlots = Roact.PureComponent:extend("EquipSlots")

function EquipSlots:init()
	self.gradientFrameRef = Roact.createRef()

	self.checkShowGradient = function(rbx)
		local gradientFrame = self.gradientFrameRef.current
		if not gradientFrame then
			return
		end

		local showGradient, showLeft, showRight = AvatarExperienceUtils.shouldShowGradientForScrollingFrame(rbx)
		gradientFrame.Visible = showGradient

		local left = gradientFrame:FindFirstChild("Left")
		local right = gradientFrame:FindFirstChild("Right")

		if left and right then
			left.Visible = showLeft
			right.Visible = showRight
		end
	end
end

function EquipSlots:render()
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local selectedSlot = self.props.selectedSlot
		local lockNavigationCallback = self.props.lockNavigationCallback
		local unlockNavigationCallback = self.props.unlockNavigationCallback
		local slotsCount = self.props.slotsCount
		local slotsInfo = self.props.slotsInfo

		local slotChildren = {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
		}

		for i = 1, slotsCount do
			local equippedAssetId = slotsInfo[i] and slotsInfo[i].assetId
			local isSelected = selectedSlot == i

			local thumbnailUrl
			if equippedAssetId then
				thumbnailUrl = CatalogUtils.MakeRbxThumbUrl(CatalogConstants.ThumbnailType.Asset, equippedAssetId,
					THUMBNAIL_SIZE, THUMBNAIL_SIZE)
			end

			local slotWidth = SLOT_SIZE + SLOT_PADDING
			if i == slotsCount then
				slotWidth = slotWidth + SLOT_PADDING
			end

			slotChildren[i] = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, slotWidth, 0, SLOT_SIZE),
				LayoutOrder = i,
			}, {
				Slot = Roact.createElement(ItemSlot, {
					slotNumber = i,
					isSelected = isSelected,
					thumbnailUrl = thumbnailUrl,

					onActivate = function()
						self.props.onActivated(i)
					end,
				}),

				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, SLOT_PADDING),
					PaddingRight = i == slotsCount and UDim.new(0, SLOT_PADDING) or UDim.new(0, 0),
				}),
			})
		end

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, SLOTS_HEIGHT),
		}, {
			GradientFrame = Roact.createElement(GradientFrame, {
				navHeight = SLOTS_HEIGHT,
				ref = self.gradientFrameRef,
				ZIndex = 2,
			}),

			ScrollingList = Roact.createElement(FitChildren.FitScrollingFrame, {
				Active = true,
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = theme.BackgroundDefault.Color,
				BackgroundTransparency = theme.BackgroundDefault.Transparency,
				LayoutOrder = self.props.LayoutOrder,
				ScrollingDirection = Enum.ScrollingDirection.X,
				ScrollBarThickness = 0,

				fitFields = {
					CanvasSize = FitChildren.FitAxis.Width,
				},

				[Roact.Change.AbsoluteSize] = self.checkShowGradient,
				[Roact.Change.CanvasSize] = self.checkShowGradient,
				[Roact.Change.CanvasPosition] = self.checkShowGradient,

				[Roact.Event.InputBegan] = function(rbx, input)
					if input.UserInputState == Enum.UserInputState.Begin then
						self.activeInput = input
						lockNavigationCallback()
					end
				end,

				[Roact.Event.InputEnded] = function(rbx, input)
					if input == self.activeInput and input.UserInputState == Enum.UserInputState.End then
						self.activeInput = nil
						unlockNavigationCallback()
					end
				end,
			}, slotChildren),
		})
	end)
end

function EquipSlots:willUnmount()
	if self.activeInput then
		self.activeInput = nil
		self.props.unlockNavigationCallback()
	end
end

local function mapStateToProps(state, props)
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory
	local page = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)

	local slotsInfo
	if page.PageType == AvatarExperienceConstants.PageType.Emotes then
		slotsInfo = state.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo
	end

	return {
		selectedSlot = state.AvatarExperience.AvatarEditor.EquippedEmotes.selectedSlot,
		page = page,
		slotsInfo = slotsInfo,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(EquipSlots)