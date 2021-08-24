return function()
	local BaseTile = script.Parent
	local TileRoot = BaseTile.Parent
	local App = TileRoot.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local SaveTile = require(script.Parent.SaveTile)

	describe("The SaveTile component", function()
		it("should create and destroy without errors", function()
			local testImage = "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814"
			local onActivated = function() end
			local element = mockStyleComponent({
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				}, {
					SaveTile = Roact.createElement(SaveTile, {
						onActivated = onActivated,
						thumbnail = testImage,
					})
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should create and destroy without errors with only required props", function()
			local element = mockStyleComponent({
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				}, {
					SaveTile = Roact.createElement(SaveTile)
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should accept and assign a ref", function()
			local ref = Roact.createRef()
			local element = mockStyleComponent({
				SaveTile = Roact.createElement(SaveTile, {
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