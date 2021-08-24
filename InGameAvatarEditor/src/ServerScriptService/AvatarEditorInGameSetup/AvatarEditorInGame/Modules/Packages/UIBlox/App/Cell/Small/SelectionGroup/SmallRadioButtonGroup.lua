local SelectionGroup = script.Parent
local Small = SelectionGroup.Parent
local Cell = Small.Parent
local App = Cell.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local RoactGamepad = require(Packages.RoactGamepad)
local t = require(Packages.t)

local UIBloxConfig = require(UIBlox.UIBloxConfig)
local withSelectionCursorProvider = require(UIBlox.App.SelectionImage.withSelectionCursorProvider)
local CursorKind = require(UIBlox.App.SelectionImage.CursorKind)

local SmallRadioButtonCell = require(UIBlox.App.Cell.Small.SelectionGroup.SmallRadioButtonCell)

local ID_PROP_NAME = UIBloxConfig.renameKeyProp and "id" or "key"

local SmallRadioButtonGroup = Roact.PureComponent:extend("SmallRadioButtonGroup")

local buttonInterface = t.strictInterface({
	text = t.string,
	[ID_PROP_NAME] = t.string,
	isDisabled = t.optional(t.boolean),
})

SmallRadioButtonGroup.validateProps = t.strictInterface({
	-- List of text, identifier pairs that will be used for each radio button.
	items = t.optional(t.array(t.tuple(buttonInterface))),

	-- Which identifier is currently selected.
	selectedValue = t.optional(t.string),

	-- Callback for when a cell is activated.
	onActivated = t.callback,

	-- Layout order for this component.
	layoutOrder = t.optional(t.number),

	-- If this cell should use the default control state
	useDefaultControlState = t.optional(t.boolean),

	-- optional parameters for RoactGamepad
	NextSelectionLeft = t.optional(t.table),
	NextSelectionRight = t.optional(t.table),
	NextSelectionUp = t.optional(t.table),
	NextSelectionDown = t.optional(t.table),
	frameRef = t.optional(t.table),
})

SmallRadioButtonGroup.defaultProps = {
	selectedValue = nil,
}

function SmallRadioButtonGroup:init()
	self.gamepadRefs = RoactGamepad.createRefCache()
end

function SmallRadioButtonGroup:render()
	assert(self.validateProps(self.props))

	local smallRadioButtonCellGroup = {}
	smallRadioButtonCellGroup.layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),
	})
	for index, button in ipairs(self.props.items) do
		if UIBloxConfig.enableExperimentalGamepadSupport then
			smallRadioButtonCellGroup["smallRadioButtonCell"..button[ID_PROP_NAME]] =
				withSelectionCursorProvider(function(getSelectionCursor)
				return Roact.createElement(RoactGamepad.Focusable[SmallRadioButtonCell], {
					[ID_PROP_NAME] = button[ID_PROP_NAME],
					text = button.text,
					onActivated = self.props.onActivated,
					isSelected = self.props.selectedValue == button[ID_PROP_NAME],
					isDisabled = button.isDisabled,
					layoutOrder = index,
					useDefaultControlState = self.props.useDefaultControlState,

					[Roact.Ref] = self.gamepadRefs[index],
					NextSelectionUp = index > 1 and self.gamepadRefs[index - 1] or nil,
					NextSelectionDown = index < #self.props.items and self.gamepadRefs[index + 1] or nil,
					SelectionImageObject = getSelectionCursor(CursorKind.SelectionCell),
				})
			end)
		else
			smallRadioButtonCellGroup["smallRadioButtonCell"..button[ID_PROP_NAME]] = Roact.createElement(SmallRadioButtonCell, {
				[ID_PROP_NAME] = button[ID_PROP_NAME],
				text = button.text,
				onActivated = self.props.onActivated,
				isSelected = self.props.selectedValue == button[ID_PROP_NAME],
				isDisabled = button.isDisabled,
				layoutOrder = index,
			})
		end
	end

	local gamepadEnabled = (UIBloxConfig.enableExperimentalGamepadSupport and self.props.items and #self.props.items > 0)

	return Roact.createElement(gamepadEnabled and RoactGamepad.Focusable.Frame or "Frame", {
		defaultChild = gamepadEnabled and self.gamepadRefs[1] or nil,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder = self.props.layoutOrder,
		NextSelectionLeft = self.props.NextSelectionLeft,
		NextSelectionRight = self.props.NextSelectionRight,
		NextSelectionDown = self.props.NextSelectionDown,
		NextSelectionUp = self.props.NextSelectionUp,
		[Roact.Ref] = self.props.frameRef,
	}, smallRadioButtonCellGroup)
end

return Roact.forwardRef(function (props, ref)
	return Roact.createElement(SmallRadioButtonGroup, Cryo.Dictionary.join(
		props,
		{frameRef = ref}
	))
end)