return function()
	local Indicator = script.Parent
	local App = Indicator.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent
	local Roact = require(Packages.Roact)
	local Badge = require(script.Parent.Badge)
	local BadgeStates = require(script.Parent.Enum.BadgeStates)
	local mockStyleComponent = require(Packages.UIBlox.Utility.mockStyleComponent)
	local UIBloxConfig = require(UIBlox.UIBloxConfig)

	describe("lifecycle", function()
		local frame = Instance.new("Frame")
		it("should mount and unmount with only the required props", function()
			local element = mockStyleComponent({
				radioButton = Roact.createElement(Badge, {
					value = 60,
				})
			})
			local instance = Roact.mount(element, frame, "Badge")
			Roact.unmount(instance)
		end)

		it("should mount and unmount with all the props", function()
			local element = mockStyleComponent({
				radioButton = Roact.createElement(Badge, {
					position = UDim2.fromScale(0.5, 0.5),
					anchorPoint = Vector2.new(0, 1),

					disabled = true,
					hasShadow = true,

					value = 60,
				})
			})
			local instance = Roact.mount(element, frame, "Badge")
			Roact.unmount(instance)
		end)

		it("should accept string values", function()
			local element = mockStyleComponent({
				radioButton = Roact.createElement(Badge, {
					position = UDim2.fromScale(0.5, 0.5),
					anchorPoint = Vector2.new(0, 1),

					value = "New",
				})
			})
			local instance = Roact.mount(element, frame, "Badge")
			Roact.unmount(instance)
		end)

		it("should display as 99+ for values above 99", function()
			local element = mockStyleComponent({
				radioButton = Roact.createElement(Badge, {
					position = UDim2.fromScale(0.5, 0.5),
					anchorPoint = Vector2.new(0, 1),

					value = 100,
				})
			})
			local instance = Roact.mount(element, frame, "Badge")

			local textLabel = frame:FindFirstChild("TextLabel", true)
			expect(textLabel.Text).to.equal("99+")

			Roact.unmount(instance)
		end)

		it("should have an empty smaller badge if BadgeStates.isEmpty is passed in as the value", function()
			local originalConfig = UIBloxConfig.allowSystemBarToAcceptString
			UIBloxConfig.allowSystemBarToAcceptString = true

			local element = mockStyleComponent({
				radioButton = Roact.createElement(Badge, {
					position = UDim2.fromScale(0.5, 0.5),
					anchorPoint = Vector2.new(0, 1),

					value = BadgeStates.isEmpty,
				})
			})
			local instance = Roact.mount(element, frame, "Badge")

			local textLabel = frame:FindFirstChild("TextLabel", true)
			expect(textLabel.Text).to.equal("")
			expect(textLabel.AbsoluteSize.Y).to.equal(8)
			expect(textLabel.AbsoluteSize.X).to.equal(8)

			Roact.unmount(instance)
			UIBloxConfig.allowSystemBarToAcceptString = originalConfig
		end)
	end)
end
