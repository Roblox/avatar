local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local Otter = require(Modules.Packages.Otter)
local RoactRodux = require(Modules.Packages.RoactRodux)
local t = require(Modules.Packages.t)

local withLocalization = require(Modules.Packages.Localization.withLocalization)

local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local ButtonType = UIBlox.App.Button.Enum.ButtonType
local PartialPageModal = UIBlox.App.Dialog.Modal.PartialPageModal

local SPRING_OPTIONS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local CatalogPrompt = Roact.PureComponent:extend("CatalogPrompt")

function CatalogPrompt:init()
	self.state = {
		panelAnchorY = 0,
		apply = false
	}
end

CatalogPrompt.validateProps = t.strictInterface({
	isPortrait = t.boolean,
	screenSize = t.Vector2,
	title = t.string,
	onApply = t.callback,
	closePrompt = t.callback,
	[Roact.Children] = t.table,
})

function CatalogPrompt:onClose(applyChanges)
	if self.props.isPortrait and self.motor then
		self.motor:setGoal(Otter.spring(0, SPRING_OPTIONS))
		self.motor:onComplete(function()
			self.props.closePrompt()
			if applyChanges then
				self.props.onApply()
			end
		end)
	else
		self.props.closePrompt()
		if applyChanges then
			self.props.onApply()
		end
	end
end

function CatalogPrompt:didMount()
	if self.props.isPortrait then
		self.motor = Otter.createSingleMotor(self.state.panelAnchorY)
		self.motor:onStep(function(newPanelAnchorY)
			self:setState({
				panelAnchorY = newPanelAnchorY,
			})
		end)

		self.motor:setGoal(Otter.spring(1, SPRING_OPTIONS))
	end
end

function CatalogPrompt:willUnmount()
	if self.props.isPortrait and self.motor then
		self.motor:destroy()
	end
end

function CatalogPrompt:render()
	return withStyle(function(styles)
		return withLocalization({
			apply = "CommonUI.Messages.Action.Apply",
		})(function(localized)
			local position, anchorPoint
			if self.props.isPortrait then
				position = UDim2.new(0.5, 0, 1, 0)
				anchorPoint = Vector2.new(0.5, self.state.panelAnchorY)
			else
				position = UDim2.new(0.5, 0, 0.5, 0)
				anchorPoint = Vector2.new(0.5, 0.5)
			end

			return Roact.createElement(PartialPageModal, {
				title = self.props.title,
				screenSize = self.props.screenSize,
				position = position,
				anchorPoint = anchorPoint,
				buttonStackProps = {
					buttons = {
						{
							buttonType = ButtonType.PrimarySystem,
							props = {
								isDisabled = false,
								onActivated = function() self:onClose(true) end,
								text = localized.apply,
							},
						},
					},
				},
				onCloseClicked = function() self:onClose() end,
			}, self.props[Roact.Children])
		end)
	end)
end

CatalogPrompt = RoactRodux.UNSTABLE_connect2(
	function(state)
		local deviceOrientation = state.DeviceOrientation
		local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

		return {
			isPortrait = isPortrait,
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			closePrompt = function()
				dispatch(CloseCentralOverlay())
			end,
		}
	end
)(CatalogPrompt)

return CatalogPrompt
