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

	local SmallRadioButtonCell = require(script.Parent.SmallRadioButtonCell)

	local ID_PROP_NAME = UIBloxConfig.renameKeyProp and "id" or "key"

	it("should create and destroy SmallRadioButtonCell without errors", function()
		local element = mockStyleComponent({
			smallRadioButtonCell = Roact.createElement(SmallRadioButtonCell, {
				[ID_PROP_NAME] = "1",
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should accept and assign a ref", function()
		local ref = Roact.createRef()
		local element = mockStyleComponent({
			smallRadioButtonCell = Roact.createElement(SmallRadioButtonCell, {
				[ID_PROP_NAME] = "1",
				[Roact.Ref] = ref
			})
		})

		local instance = Roact.mount(element)
		expect(ref.current).to.be.ok()
		expect(ref.current:IsA("Instance")).to.be.ok()
		Roact.unmount(instance)
	end)
end