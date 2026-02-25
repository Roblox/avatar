return function()
	local BaseTile = script.Parent
	local TileRoot = BaseTile.Parent
	local App = TileRoot.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local PlayerTile = require(script.Parent.PlayerTile)

	describe("The PlayerTile component", function()
		it("should create and destroy without errors", function()
			local testImage = "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814"
			local testName = "some test name"
			local testSubtitle = "some test subtitle"
			local onActivated = function() end
			local element = mockStyleComponent({
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				}, {
					PlayerTile = Roact.createElement(PlayerTile, {
						title = testName,
						subtitle = testSubtitle,
						onActivated = onActivated,
						thumbnail = testImage,
						relevancyInfo = {}
					})
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should accept and assign a ref", function()
			local ref = Roact.createRef()
			local element = mockStyleComponent({
				PlayerTile = Roact.createElement(PlayerTile, {
					[Roact.Ref] = ref,
				})
			})

			local instance = Roact.mount(element)
			expect(ref.current).to.be.ok()
			expect(ref.current:IsA("Instance")).to.be.ok()
			Roact.unmount(instance)
		end)

		it("should accept and assign a tileSize", function()
			local ref = Roact.createRef()
			local element = mockStyleComponent({
				PlayerTile = Roact.createElement(PlayerTile, {
					tileSize = UDim2.new(0, 200, 0, 200),
					[Roact.Ref] = ref,
				})
			})

			local instance = Roact.mount(element)
			expect(ref.current).to.be.ok()
			expect(ref.current.Size).to.equal(UDim2.new(0, 200, 0, 200))
			Roact.unmount(instance)
		end)

		it("should accept props.buttons", function()
			local element = mockStyleComponent({
				PlayerTile = Roact.createElement(PlayerTile, {
					buttons = {
						{
							icon = "icon1",
						},
						{
							icon = "icon2",
						},
					}
				})
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			local function findImageObjectWIthImage(image)
				for _, object in ipairs(folder:GetDescendants()) do
					if object:IsA("ImageLabel") then
						if object.Image == image then
							return object
						end
					end
				end

				return nil
			end

			expect(findImageObjectWIthImage("icon1")).to.be.ok()
			expect(findImageObjectWIthImage("icon2")).to.be.ok()

			Roact.unmount(instance)
		end)

		it("should only show gradient if buttons exist", function()
			local element = mockStyleComponent({
				PlayerTile = Roact.createElement(PlayerTile, {
					buttons = {
						{
							icon = "icon1",
						},
					}
				})
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			local gradient = nil
			for _, object in ipairs(folder:GetDescendants()) do
				if object:IsA("UIGradient") then
					gradient = object
				end
			end

			expect(gradient).to.be.ok()

			Roact.unmount(instance)

		end)

		it("should not show gradient if no buttons exist", function()
			local element = mockStyleComponent({
				PlayerTile = Roact.createElement(PlayerTile)
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			local gradient = nil
			for _, object in ipairs(folder:GetDescendants()) do
				if object:IsA("UIGradient") then
					gradient = object
				end
			end

			expect(gradient).never.to.be.ok()

			Roact.unmount(instance)

		end)
	end)
end
