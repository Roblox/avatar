return function()
	local BaseTile = script.Parent
	local TileRoot = BaseTile.Parent
	local App = TileRoot.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local RelevancyInfo = require(script.Parent.RelevancyInfo)
	local Images = require(UIBlox.App.ImageSet.Images)

	describe("Relevancy Info Component", function()
		it("should function with just text", function()
			local element = mockStyleComponent({
				RelevancyInfo = Roact.createElement(RelevancyInfo, {
					text = "bleh",
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should function with just text and icon", function()
			local element = mockStyleComponent({
				RelevancyInfo = Roact.createElement(RelevancyInfo, {
					text = "bleh",
					icon = Images["component_assets/vignette_246"],
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
