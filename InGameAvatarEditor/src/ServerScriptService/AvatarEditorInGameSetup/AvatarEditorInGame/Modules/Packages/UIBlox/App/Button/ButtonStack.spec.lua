local ButtonRoot = script.Parent
local AppRoot = ButtonRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)

local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)

local ButtonStack = require(script.Parent.ButtonStack)

local DEFAULT_REQUIRED_PROPS = {
	buttons = {
		{
			props = {
				text = "test",
				onActivated = function() end,
			},
		}
	},
}

return function()
	describe("lifecycle", function()
		it("should mount and unmount button stacks without issue", function()
			local tree = mockStyleComponent(
				Roact.createElement(ButtonStack, DEFAULT_REQUIRED_PROPS)
			)
			local handle = Roact.mount(tree)
			Roact.unmount(handle)
		end)

		it("should accept and assign a ref", function()
			local ref = Roact.createRef()
			local element = mockStyleComponent({
				ButtonStack = Roact.createElement(ButtonStack, Cryo.Dictionary.join(
					DEFAULT_REQUIRED_PROPS,
					{[Roact.Ref] = ref}
				))
			})

			local instance = Roact.mount(element)
			expect(ref.current).to.be.ok()
			expect(ref.current:IsA("Instance")).to.be.ok()
			Roact.unmount(instance)
		end)
	end)
end