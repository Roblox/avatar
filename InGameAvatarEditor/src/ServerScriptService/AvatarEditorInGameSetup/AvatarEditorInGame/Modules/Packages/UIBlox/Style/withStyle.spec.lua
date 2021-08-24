return function()
	local StyleRoot = script.Parent
	local UIBloxRoot = StyleRoot.Parent
	local Roact = require(UIBloxRoot.Parent.Roact)
	local StyleProvider = require(StyleRoot.StyleProvider)
	local withStyle = require(StyleRoot.withStyle)
	local testStyle = require(StyleRoot.Validator.TestStyle)

	it("should create and destroy without errors", function()
		local someTestElement = Roact.Component:extend("someTestElement")
		-- luacheck: ignore unused argument self
		function someTestElement:render()
			return withStyle(function(style)
				expect(style).to.be.a("table")
				return Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				})
			end)
		end

		local element = Roact.createElement(StyleProvider, {
			style = testStyle,
		}, {
			someTestElement = Roact.createElement(someTestElement),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should run again when style changes", function()
		local timesRendered = 0
		local Styled = Roact.PureComponent:extend("someTestElement")

		function Styled:render()
			return withStyle(function(style)
				timesRendered = timesRendered + 1
				expect(style).to.be.a("table")
				return nil
			end)
		end

		local tree = Roact.mount(Roact.createElement(StyleProvider, {
			style = testStyle,
		}, {
			child = Roact.createElement(Styled)
		}))
		expect(timesRendered).to.equal(1)

		tree = Roact.update(tree, Roact.createElement(StyleProvider, {
			-- Object with a new identity
			style = {
				Theme = testStyle.Theme,
				Font = testStyle.Font,
			},
		}, {
			child = Roact.createElement(Styled)
		}))
		expect(timesRendered).to.equal(2)

		Roact.unmount(tree)
	end)
end