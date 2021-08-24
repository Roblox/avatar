return function()
	local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
	local Roact = require(Modules.Packages.Roact)
    local mountStyledFrame = require(Modules.AvatarExperience.Catalog.Components.AlertView.mountStyledFrame)

	local FitFrameVertical = require(script.Parent.FitFrameVertical)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(FitFrameVertical))

			cleanup()
		end)
	end)

	describe("props Children", function()
		it("should render all children", function()
			local tree = Roact.createElement(FitFrameVertical, nil, {
				child1 = Roact.createElement("Frame"),
				child2 = Roact.createElement("Frame"),
			})
			local folder, cleanup = mountStyledFrame(tree)

			local child1Instance = folder:FindFirstChild("child1", true)
			local child2Instance = folder:FindFirstChild("child2", true)

			expect(child1Instance).to.be.ok()
			expect(child2Instance).to.be.ok()

			cleanup()
		end)

		it("should resize ancestor guiObject when updated with new children", function()
			local function getHeight(folder)
				local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
				return guiObject.AbsoluteSize.Y
			end

			local function create100x100Frame()
				return Roact.createElement("Frame", {
					Size = UDim2.new(0, 100, 0, 100),
				})
			end

			local tree0Children = Roact.createElement(FitFrameVertical, nil, {})
			local tree1Children = Roact.createElement(FitFrameVertical, nil, {
				child1 = create100x100Frame(),
			})
			local tree3Children = Roact.createElement(FitFrameVertical, nil, {
				child1 = create100x100Frame(),
				child2 = create100x100Frame(),
				child3 = create100x100Frame(),
			})

			local folder = Instance.new("Frame")
			local instance = Roact.mount(tree0Children, folder)
			local instance0Height = getHeight(folder)
			Roact.reconcile(instance, tree1Children)
			local instance1Height = getHeight(folder)
			Roact.reconcile(instance, tree3Children)
			local instance3Height = getHeight(folder)

			expect(type(instance0Height)).to.equal("number")
			expect(type(instance1Height)).to.equal("number")
			expect(type(instance3Height)).to.equal("number")

			expect(instance0Height).to.never.equal(instance1Height)
			expect(instance0Height).to.never.equal(instance3Height)
			expect(instance1Height).to.never.equal(instance3Height)

			Roact.unmount(instance)
			folder:Destroy()
		end)
	end)

	describe("props width", function()
		it("should set ancestor guiObject width", function()
			local mockWidth = UDim.new(0.5, 145)
			local tree = Roact.createElement(FitFrameVertical, {
				width = mockWidth,
			})

			local folder, cleanup = mountStyledFrame(tree)
			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)

			expect(guiObject.Size.X).to.equal(mockWidth)

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(FitFrameVertical, {
				LayoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("prop contentPadding", function()
		it("should set the padding of the layout", function()
			local mockContentPadding = UDim.new(0, 20)
			local tree = Roact.createElement(FitFrameVertical, {
				contentPadding = mockContentPadding,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local layoutInstance = folder:FindFirstChild("layout", true)
			expect(layoutInstance).to.be.ok()
			expect(layoutInstance.Padding).to.equal(mockContentPadding)

			cleanup()
		end)
	end)

	describe("props FillDirection", function()
		it("should set the FillDirection of layout", function()
			local mockFillDirection = Enum.FillDirection.Horizontal
			local tree = Roact.createElement(FitFrameVertical, {
				FillDirection = mockFillDirection,
			})

			local folder, cleanup = mountStyledFrame(tree)
			local layoutInstance = folder:FindFirstChild("layout", true)

			expect(layoutInstance.FillDirection).to.equal(mockFillDirection)

			cleanup()
		end)
	end)

	describe("props HorizontalAlignment", function()
		it("should set the HorizontalAlignment of layout", function()
			local mockHorizontalAlignment = Enum.HorizontalAlignment.Center
			local tree = Roact.createElement(FitFrameVertical, {
				HorizontalAlignment = mockHorizontalAlignment,
			})

			local folder, cleanup = mountStyledFrame(tree)
			local layoutInstance = folder:FindFirstChild("layout", true)

			expect(layoutInstance.HorizontalAlignment).to.equal(mockHorizontalAlignment)

			cleanup()
		end)
	end)

	describe("props VerticalAlignment", function()
		it("should set the VerticalAlignment of layout", function()
			local mockVerticalAlignment = Enum.VerticalAlignment.Center
			local tree = Roact.createElement(FitFrameVertical, {
				VerticalAlignment = mockVerticalAlignment,
			})

			local folder, cleanup = mountStyledFrame(tree)
			local layoutInstance = folder:FindFirstChild("layout", true)

			expect(layoutInstance.VerticalAlignment).to.equal(mockVerticalAlignment)

			cleanup()
		end)
	end)
end