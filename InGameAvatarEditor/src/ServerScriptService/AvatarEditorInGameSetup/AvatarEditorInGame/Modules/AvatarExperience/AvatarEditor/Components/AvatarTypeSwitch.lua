local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetAvatarType)
local FitChildren = require(Modules.NotLApp.FitChildren)
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local Text = require(Modules.Common.Text)

local OverlayType = require(Modules.NotLApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)

local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)

local Images = UIBlox.App.ImageSet.Images

local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem
local withStyle = UIBlox.Style.withStyle

-- Toggle refers to the static background UI element
-- Switch refers to the animated inner UI element
local TOGGLE_IMAGE = Images["component_assets/circle_29"]
local SWITCH_IMAGE = Images["component_assets/circle_25"]

local OUTER_PADDING = 3
local INNER_PADDING = 5

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local AvatarTypeSwitch = Roact.PureComponent:extend("AvatarTypeSwitch")

local function resizeTextLabel(rbx)
	local width = UDim.new(0, Text.GetTextWidth(rbx.Text, rbx.Font, rbx.TextSize))
	local height = UDim.new(0, rbx.TextSize)
	rbx.Size = UDim2.new(width, height)
end

function AvatarTypeSwitch:resizeTextLabels()
	local r6Rbx = self.r6Ref.current
	local r15Rbx = self.r15Ref.current
	if not r6Rbx or not r15Rbx then
		return
	end

	resizeTextLabel(r6Rbx)
	resizeTextLabel(r15Rbx)

	-- Find max width of the text labels and adjust the shorter to match the longer
	local r6Width = r6Rbx.AbsoluteSize.x
	local r15Width = r15Rbx.AbsoluteSize.x

	local maxWidth = math.max(r6Width, r15Width)

	r6Rbx.Size = UDim2.new(0, maxWidth, 0, r6Rbx.Size.Y.Offset)
	r15Rbx.Size = UDim2.new(0, maxWidth, 0, r15Rbx.Size.Y.Offset)
end

function AvatarTypeSwitch:onAvatarTypeClicked()
	local setAvatarType = self.props.setAvatarType
	local newAvatarType = self.props.avatarType == AvatarExperienceConstants.AvatarType.R6
		and AvatarExperienceConstants.AvatarType.R15 or AvatarExperienceConstants.AvatarType.R6

	if LayeredClothingEnabled then
		local equippedAssets = self.props.equippedAssets
		if newAvatarType == AvatarExperienceConstants.AvatarType.R6 and AvatarEditorUtils.hasLayeredAssetsEquipped(equippedAssets) then
			self.props.openLayeredClothingR6Switch()
			return
		end
	end

	setAvatarType(newAvatarType)
end

function AvatarTypeSwitch:init()
	self.r6Ref = Roact.createRef()
	self.r15Ref = Roact.createRef()
end

function AvatarTypeSwitch:render()
	local layoutOrder = self.props.LayoutOrder

	local renderSwitch = function(localized)
		return withStyle(function(stylePalette)
			local theme = stylePalette.Theme
			local font = stylePalette.Font
			local togglePosition
			if self.props.avatarType == AvatarExperienceConstants.AvatarType.R15 then
				togglePosition = 0.5
			else
				togglePosition = 0
			end

			return Roact.createElement(FitChildren.FitImageLabel, {
				Image = TOGGLE_IMAGE,
				ImageColor3 = theme.BackgroundContrast.Color,
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(14, 13, 15, 15),
				fitAxis = FitChildren.FitAxis.Both,
				LayoutOrder = layoutOrder,
			}, {
				AnimatedFrame = Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
					regularProps = {
						Size = UDim2.new(0.5, 0, 1, 0),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					},
					animatedValues = {
						positionX = togglePosition,
					},
					mapValuesToProps = function(values)
						return {
							Position = UDim2.new(values.positionX, 0, 0, 0)
						}
					end,
					springOptions = ANIMATION_SPRING_SETTINGS,
				}, {
					SwitchImage = Roact.createElement(ImageSetLabel, {
						Size = UDim2.new(1, 0, 1, 0),
						Image = SWITCH_IMAGE,
						ImageColor3 = theme.UIDefault.Color,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(12, 11, 13, 13),
					}),
				}),
				SwitchButton = Roact.createElement("ImageButton", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),

					[Roact.Event.Activated] = function(_rbx)
						self:onAvatarTypeClicked()
					end,
				}),
				LabelsContainer = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					ZIndex = 2,
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, OUTER_PADDING),
						PaddingRight = UDim.new(0, OUTER_PADDING),
						PaddingTop = UDim.new(0, OUTER_PADDING),
						PaddingBottom = UDim.new(0, OUTER_PADDING),
					}),
					UIListLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, INNER_PADDING * 2),
					}),
					R6Label = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 0.5),
						Font = font.Body.Font,
						Text = localized.r6Text,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = font.CaptionHeader.RelativeSize * font.BaseSize,
						TextColor3 = self.props.avatarType == AvatarExperienceConstants.AvatarType.R6 and theme.TextEmphasis.Color
							or theme.TextDefault.Color,
						LayoutOrder = 1,
						[Roact.Ref] = self.r6Ref,
					}),
					R15Label = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0.5),
						Font = font.Body.Font,
						Text = localized.r15Text,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = font.CaptionHeader.RelativeSize * font.BaseSize,
						TextColor3 = self.props.avatarType == AvatarExperienceConstants.AvatarType.R15 and theme.TextEmphasis.Color
							or theme.TextDefault.Color,
						LayoutOrder = 2,
						[Roact.Ref] = self.r15Ref,
					})
				}),
			})
		end)
	end

	return withLocalization({
		r6Text = "Feature.Avatar.Label.R6",
		r15Text = "Feature.Avatar.Label.R15",
	})(function(localized)
		return renderSwitch(localized)
	end)
end

function AvatarTypeSwitch:didMount()
	self:resizeTextLabels()
end

return RoactRodux.UNSTABLE_connect2(function(state, _props)
	return {
			equippedAssets = state.AvatarExperience.AvatarEditor.Character.EquippedAssets,
			avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType,
		}
	end,

	function(dispatch)
		return {
			setAvatarType = function(newAvatarType)
				dispatch(SetAvatarType(newAvatarType))
			end,

			openLayeredClothingR6Switch = function()
				dispatch(SetCentralOverlay(OverlayType.LayeredClothingR6SwitchPrompt))
			end
		}
	end
)(AvatarTypeSwitch)
