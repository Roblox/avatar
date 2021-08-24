local ModalRoot = script.Parent
local DialogRoot = ModalRoot.Parent
local AppRoot = DialogRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)

local ModalTitle = require(script.Parent.ModalTitle)

return function()
	describe("lifecycle", function()
		it("should mount and unmount ModalTitle without issue", function()
			local element = mockStyleComponent({
				ModalTitleContainer = Roact.createElement(ModalTitle, {
					title = "Title",
					position = UDim2.new(0, 0, 0, 0),
					anchor = Vector2.new(0, 0),
					onCloseClicked = function() end,
					titleBackgroundImageProps = {
						image = "rbxassetid://2610133241",
						imageHeight = 200,
					},
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should throw on invalid props", function()
			local element = mockStyleComponent({
				ModalTitleContainer = Roact.createElement(ModalTitle, {
					title = "Title",
					position = UDim2.new(0, 0, 0, 0),
					anchor = Vector2.new(0, 0),
					onCloseClicked = function() end,
					titleBackgroundImageProps = {
						image = "rbxassetid://2610133241",
					},
				})
			})

			expect(function()
				Roact.mount(element)
			end).to.throw()
		end)
	end)
end