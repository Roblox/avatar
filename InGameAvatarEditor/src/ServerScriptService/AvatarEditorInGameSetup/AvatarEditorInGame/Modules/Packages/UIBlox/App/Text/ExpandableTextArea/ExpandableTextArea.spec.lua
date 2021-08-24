return function()
	local ExpandableTextAreaFolder = script.Parent
	local Text = ExpandableTextAreaFolder.Parent
	local App = Text.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local ExpandableTextArea = require(ExpandableTextAreaFolder.ExpandableTextArea)

	local descriptionText = [[
		This golden crown was awarded as a prize in the June 2007 Domino Rally Building Contest.
		Perhaps its most unique characteristic is its ability to inspire viewers with awe
		while at the same time making the wearer look goofy.
	]]

	describe("ExpandableTextArea", function()
		it("should create and destroy without errors", function()
			local element = mockStyleComponent({
				Image = Roact.createElement(ExpandableTextArea, {
					Text = descriptionText,
				})
			})

			local instance = Roact.mount(element, nil, "ExpandableTextArea")
			Roact.unmount(instance)
		end)

		it("should accept and assign a ref", function()
			local ref = Roact.createRef()
			local element = mockStyleComponent({
				expandableTextArea = Roact.createElement(ExpandableTextArea, {
					[Roact.Ref] = ref,
				})
			})

			local instance = Roact.mount(element)
			expect(ref.current).to.be.ok()
			expect(ref.current:IsA("Instance")).to.be.ok()
			Roact.unmount(instance)
		end)
	end)
end
