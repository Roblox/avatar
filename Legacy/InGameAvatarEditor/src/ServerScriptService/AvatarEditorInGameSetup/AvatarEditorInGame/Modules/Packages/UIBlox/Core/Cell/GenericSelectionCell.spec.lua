return function()
	local Cell = script.Parent
	local Core = Cell.Parent
	local UIBlox = Core.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local Images = require(Packages.UIBlox.App.ImageSet.Images)

	local GenericSelectionCell = require(Cell.GenericSelectionCell)

	local DEFAULT_IMAGE = Images["component_assets/circle_24_stroke_1"]

	it("should create and destroy GenericSelectionCell without errors", function()
		local element = mockStyleComponent({
			genericCell = Roact.createElement(GenericSelectionCell, {
				text = "text",
				defaultImage = DEFAULT_IMAGE,
				selectedImage = DEFAULT_IMAGE,
				defaultImageSize = 16,
				selectedImageSize = 16,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should accept and assign a ref", function()
		local ref = Roact.createRef()
		local element = mockStyleComponent({
			genericCell = Roact.createElement(GenericSelectionCell, {
				text = "text",
				defaultImage = DEFAULT_IMAGE,
				selectedImage = DEFAULT_IMAGE,
				defaultImageSize = 16,
				selectedImageSize = 16,
				[Roact.Ref] = ref,
			})
		})

		local instance = Roact.mount(element)
		expect(ref.current).to.be.ok()
		expect(ref.current:IsA("Instance")).to.be.ok()
		Roact.unmount(instance)
	end)
end
