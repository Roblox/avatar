return function()
	local Pill = script.Parent
	local App = Pill.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)

	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)

	local SmallPill = require(Pill.SmallPill)

	it("should create and destroy Small Pill with text without errors", function()
		local element = mockStyleComponent({
			pill = Roact.createElement(SmallPill, {
				text = "Small Pill",
				onActivated = function()end,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
	it("should create and destroy Small Pill with all properties without errors", function()
		local element = mockStyleComponent({
			pill = Roact.createElement(SmallPill, {
				text = "Large Pill",
				isSelected = true,
				isLoading = true,
				isDisabled = true,
				onActivated = function()end,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
	it("should accept and assign a ref", function()
		local ref = Roact.createRef()
		local element = mockStyleComponent({
			smallPill = Roact.createElement(SmallPill, {
				onActivated = function () end,
				[Roact.Ref] = ref
			})
		})

		local instance = Roact.mount(element)
		expect(ref.current).to.be.ok()
		expect(ref.current:IsA("Instance")).to.be.ok()
		Roact.unmount(instance)
	end)
end