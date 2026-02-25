return function()
	local Button = script.Parent
	local App = Button.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local Images = require(App.ImageSet.Images)

	local icon = Images["icons/common/robux_small"]
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)

	local ActionBar = require(Button.ActionBar)
	local StyleConstants = require(UIBlox.App.Style.Constants)

	it("should create and destroy ActionBar with one button without errors", function()
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {
				button = {
					props = {
						onActivated = function() end,
						text = "Button",
					},
				}
			})
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy ActionBar with one button and one icon button without errors", function()
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {
		button = {
		  props = {
			onActivated = function() end,
			text = "Button",
			icon = icon,
		  },
		},
		icons = {
		  {
			props = {
			  anchorPoint = Vector2.new(0.5, 0.5),
			  position = UDim2.fromScale(0.5, 0.5),
			  icon = icon,
			  userInteractionEnabled = true,
			  onActivated = function()
				print("Text Button Clicked!")
			  end,
			}
		  }
		}
	  })
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy ActionBar with one button and two icon button without errors", function()
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {
		button = {
		  props = {
			onActivated = function() end,
			text = "Button",
			icon = icon,
		  },
		},
		icons = {
		  {
			props = {
			  anchorPoint = Vector2.new(0.5, 0.5),
			  position = UDim2.fromScale(0.5, 0.5),
			  icon = icon,
			  userInteractionEnabled = true,
			  onActivated = function()
				print("Text Button Clicked!")
			  end,
			}
		  },
		  {
			props = {
			  anchorPoint = Vector2.new(0.5, 0.5),
			  position = UDim2.fromScale(0.5, 0.5),
			  icon = icon,
			  userInteractionEnabled = true,
			  onActivated = function()
				print("Text Button Clicked!")
			  end,
			}
		  }
		}
	  })
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy a ActionBar with children without errors", function()
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {}, {
				ChildFrame = Roact.createElement("Frame", {})
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should accept and assign a ref", function()
		local ref = Roact.createRef()
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {
				[Roact.Ref] = ref,
			}, {
				ChildFrame = Roact.createElement("Frame", {})
			})
		})

		local instance = Roact.mount(element)
		expect(ref.current).to.be.ok()
		expect(ref.current:IsA("Instance")).to.be.ok()
		Roact.unmount(instance)
	end)

	it ("should call back onAbsoluteSizeChanged when mounted", function()
		local changedSize = nil
		local onAbsoluteSizeChanged = function(size)
			changedSize = size
		end

		local container = Instance.new("Folder")
		local element = mockStyleComponent({
			ActionBar = Roact.createElement(ActionBar, {
				onAbsoluteSizeChanged = onAbsoluteSizeChanged,
			}, {
				ChildFrame = Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				})
			})
		})

		local instance = Roact.mount(element, container)
		expect(changedSize.Y).to.equal(100 + StyleConstants.Layout.ActionBar.PositionOffset)

		Roact.unmount(instance)

	end)
end
