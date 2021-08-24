return function()
	local SelectionGroup = script.Parent
	local Small = SelectionGroup.Parent
	local Cell = Small.Parent
	local App = Cell.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)

	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local UIBloxConfig = require(UIBlox.UIBloxConfig)

	local SmallRadioButtonGroup = require(script.Parent.SmallRadioButtonGroup)

	local ID_PROP_NAME = UIBloxConfig.renameKeyProp and "id" or "key"

	local ITEMS = {
		{ text = "Selection 1", [ID_PROP_NAME] = "1" },
		{ text = "Selection 3", [ID_PROP_NAME] = "3" },
		{ text = "Selection 2", [ID_PROP_NAME] = "2" },
		{ text = "Disabled Cell", [ID_PROP_NAME] = "4", isDisabled = true }
	}

	it("should create and destroy SmallRadioButtonGroup without errors", function()
		local element = mockStyleComponent({
			smallRadioButtonGroup = Roact.createElement(SmallRadioButtonGroup, {
				onActivated = function() end,
				items = ITEMS,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy SmallRadioButtonGroup without errors with all optional props used", function()
		local element = mockStyleComponent({
			smallRadioButtonGroup = Roact.createElement(SmallRadioButtonGroup, {
				onActivated = function() end,
				items = ITEMS,
				selectedValue = "1",
				layoutOrder = 1,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should accept and assign a ref", function()
		local ref = Roact.createRef()
		local element = mockStyleComponent({
			SmallRadioButtonGroup = Roact.createElement(SmallRadioButtonGroup, {
				onActivated = function() end,
				items = ITEMS,
				[Roact.Ref] = ref
			})
		})

		local instance = Roact.mount(element)
		expect(ref.current).to.be.ok()
		expect(ref.current:IsA("Instance")).to.be.ok()
		Roact.unmount(instance)
	end)
end