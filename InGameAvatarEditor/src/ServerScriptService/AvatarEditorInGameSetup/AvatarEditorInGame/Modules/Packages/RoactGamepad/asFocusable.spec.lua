return function()
	local Players = game:GetService("Players")

	local Packages = script.Parent.Parent
	local Roact = require(Packages.Roact)

	local asFocusable = require(script.Parent.asFocusable)
	local createRefCache = require(script.Parent.createRefCache)
	local FocusContext = require(script.Parent.FocusContext)
	local FocusNode = require(script.Parent.FocusNode)
	local Input = require(script.Parent.Input)
	local FocusController = require(script.Parent.FocusController)
	local InternalApi = require(script.Parent.FocusControllerInternalApi)
	local MockEngine = require(script.Parent.Test.MockEngine)
	local createSpy = require(script.Parent.Test.createSpy)

	local function createRootNode(ref)
		local node = FocusNode.new({
			focusController = FocusController.createPublicApiWrapper(),
			[Roact.Ref] = ref,
		})

		node:attachToTree(nil, function() end)

		return node
	end

	local function createTestContainer()
		local rootRef, _ = Roact.createBinding(Instance.new("Frame"))
		local focusNode = createRootNode(rootRef)
		local mockEngine, engineInterface = MockEngine.new()
		focusNode.focusController[InternalApi]:initialize(engineInterface)

		return {
			rootRef = rootRef,
			rootFocusNode = focusNode,
			focusController = focusNode.focusController[InternalApi],

			mockEngine = mockEngine,
			engineInterface = engineInterface,
			getNode = function(ref)
				return focusNode.focusController[InternalApi].allNodes[ref]
			end,
			FocusProvider = function(props)
				return Roact.createElement(FocusContext.Provider, {
					value = {
						focusNode = focusNode,
					}
				}, props[Roact.Children])
			end
		}
	end

	describe("Focusable component basics", function()
		it("adds a new node to the focus tree when it mounts", function()
			local testContainer = createTestContainer()

			local FocusableFrame = asFocusable("Frame")

			local injectedRef = Roact.createRef()
			local tree = Roact.mount(Roact.createElement(testContainer.FocusProvider, {}, {
				FocusChild = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = injectedRef,
				}),
			}))

			local focusController = testContainer.focusController

			expect(injectedRef:getValue()).to.be.ok()
			expect(focusController.allNodes[injectedRef]).to.be.ok()

			local children = focusController:getChildren(testContainer.rootFocusNode)
			expect(children[injectedRef]).to.be.ok()

			Roact.unmount(tree)
		end)

		it("removes nodes from the focus tree when the component unmounts", function()
			local testContainer = createTestContainer()

			local FocusableFrame = asFocusable("Frame")

			local injectedRef = Roact.createRef()
			local tree = Roact.mount(Roact.createElement(testContainer.FocusProvider, {}, {
				FocusChild = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = injectedRef,
				}),
			}))

			-- Update the tree with the child focusable frame absent, which will
			-- unmount it from the tree
			Roact.update(tree, Roact.createElement(testContainer.FocusProvider))

			local focusController = testContainer.focusController

			expect(injectedRef:getValue()).to.equal(nil)
			expect(focusController.allNodes[injectedRef]).to.equal(nil)

			local children = focusController:getChildren(testContainer.rootFocusNode)
			expect(children[injectedRef]).to.equal(nil)

			Roact.unmount(tree)
		end)

		it("triggers callbacks when focus changes", function()
			local testContainer = createTestContainer()
			local FocusableFrame = asFocusable("Frame")

			local focusGainedSpy = createSpy()
			local focusLostSpy = createSpy()
			local focusChangedSpy = createSpy()

			local childRefA = Roact.createRef()
			local childRefB = Roact.createRef()
			local tree = Roact.mount(Roact.createElement(testContainer.FocusProvider, {}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = childRefA,

					onFocusGained = focusGainedSpy.value,
					onFocusLost = focusLostSpy.value,
					onFocusChanged = focusChangedSpy.value,
				}),
				FocusChildB = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = childRefB,
				})
			}), testContainer.rootRef:getValue())

			testContainer.focusController:moveFocusTo(childRefA)

			expect(focusGainedSpy.callCount).to.equal(1)
			expect(focusChangedSpy.callCount).to.equal(1)
			focusChangedSpy:assertCalledWith(true)

			testContainer.focusController:moveFocusTo(childRefB)

			expect(focusLostSpy.callCount).to.equal(1)
			expect(focusChangedSpy.callCount).to.equal(2)
			focusChangedSpy:assertCalledWith(false)

			Roact.unmount(tree)
		end)

		it("triggers callbacks when focus is released", function()
			local testContainer = createTestContainer()
			local FocusableFrame = asFocusable("Frame")

			local focusLostSpy = createSpy()
			local focusChangedSpy = createSpy()

			local childRefA = Roact.createRef()
			local tree = Roact.mount(Roact.createElement(testContainer.FocusProvider, {}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = childRefA,

					onFocusLost = focusLostSpy.value,
					onFocusChanged = focusChangedSpy.value,
				}),
			}), testContainer.rootRef:getValue())

			testContainer.focusController:moveFocusTo(childRefA)
			expect(focusChangedSpy.callCount).to.equal(1)
			focusChangedSpy:assertCalledWith(true)

			testContainer.focusController:releaseFocus()

			expect(focusLostSpy.callCount).to.equal(1)
			expect(focusChangedSpy.callCount).to.equal(2)
			focusChangedSpy:assertCalledWith(false)

			Roact.unmount(tree)
		end)
	end)

	describe("Root vs non-root Focusable", function()
		it("should ignore focusable logic if no parent or controller is provided", function()
			local FocusableFrame = asFocusable("Frame")
			local focusGainedSpy = createSpy()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				onFocusGained = focusGainedSpy.value,
			}))

			expect(focusGainedSpy.callCount).to.equal(0)

			Roact.unmount(tree)
		end)

		it("should initialize and teardown focusController when it's the root", function()
			local FocusableFrame = asFocusable("Frame")

			-- This test is testing the automatic initialization of the internal
			-- focusController based on the instance tree it's attached to. To
			-- do this, we depend on the using a PlayerGui instance to avoid
			-- simulate the real-world use case instead of the mock engine
			expect(Players.LocalPlayer.PlayerGui).to.be.ok()

			local focusController = FocusController.createPublicApiWrapper()
			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}), Players.LocalPlayer.PlayerGui)

			expect(focusController[InternalApi].engineInterface).never.to.equal(nil)

			Roact.unmount(tree)

			expect(focusController[InternalApi].engineInterface).to.equal(nil)
		end)

		it("should inherit parent neighbors through multiple layers", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local refs = createRefCache()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = refs.root,
			}, {
				TopSelectionTarget = Roact.createElement(FocusableFrame, {
					NextSelectionDown = refs.bottomFocusable,
					[Roact.Ref] = refs.topFocusable,
				}),
				BottomSelectionTarget = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.bottomFocusable,
					NextSelectionUp = refs.topFocusable,
				}, {
					IntermediateChild = Roact.createElement(FocusableFrame, {}, {
						-- This focusable child should be able to inherit
						-- neighbors from its grandparent
						LeafChild = Roact.createElement(FocusableFrame, {
							[Roact.Ref] = refs.bottomLeaf,
						})
					}),
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			-- Initialize gamepad focus to the top element
			local topNode = getNode(refs.topFocusable)
			topNode:focus()
			expect(focusControllerInternal:isNodeFocused(topNode)).to.equal(true)

			-- Move focus down; this should work without neighbor propagation
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadDown,
			})

			local bottomLeafNode = getNode(refs.bottomLeaf)
			expect(focusControllerInternal:isNodeFocused(bottomLeafNode)).to.equal(true)

			-- Move focus up; this only works if grandparents' neighbors get
			-- passed down correctly
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadUp,
			})
			expect(focusControllerInternal:isNodeFocused(topNode)).to.equal(true)

			Roact.unmount(tree)
		end)
	end)

	-- These tests rely on the fact that a FocusController passed to a Focusable
	-- component will _not_ be automatically initialized if it's not mounted
	-- under a PlayerGui. We leverage this technicality to initialize it
	-- ourselves with the mock engine interface.
	describe("Refresh focus logic", function()
		it("should redirect focus to the parent when a focused child is detached", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local refs = createRefCache()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = refs.root,
			}, {
				FocusChild = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.child,
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local _, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			local childNode = getNode(refs.child)
			childNode:focus()
			expect(focusControllerInternal:isNodeFocused(childNode)).to.equal(true)

			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = refs.root,
			}))

			local rootNode = getNode(refs.root)
			expect(focusControllerInternal:isNodeFocused(rootNode)).to.equal(true)

			Roact.unmount(tree)
		end)

		it("should trigger parent focus logic when a focused child is detached", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local refs = createRefCache()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.childA,
				}),
				FocusChildB = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.childB,
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local _, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			local childNodeA = getNode(refs.childA)
			childNodeA:focus()
			expect(focusControllerInternal:isNodeFocused(childNodeA)).to.equal(true)

			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				FocusChildB = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.childB,
				}),
			}))

			local childNodeB = getNode(refs.childB)
			expect(focusControllerInternal:isNodeFocused(childNodeB)).to.equal(true)

			Roact.unmount(tree)
		end)

		it("should trigger parent focus logic when a node has children added to it", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local refs = createRefCache()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = refs.root,
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local _, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			focusController.captureFocus()
			local rootNode = getNode(refs.root)
			expect(focusControllerInternal:isNodeFocused(rootNode)).to.equal(true)

			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = refs.root,
			}, {
				FocusChild = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.child,
				}),
			}))

			local childNode = getNode(refs.child)
			expect(focusControllerInternal:isNodeFocused(childNode)).to.equal(true)

			Roact.unmount(tree)
		end)

		it("should not refocus when adding children to a parent that already has at least one child", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local childRefA = Roact.createRef()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = childRefA,
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local _, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			local childNodeA = getNode(childRefA)
			childNodeA:focus()
			expect(focusControllerInternal:isNodeFocused(childNodeA)).to.equal(true)

			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = childRefA,
				}),
				FocusChildB = Roact.createElement(FocusableFrame),
			}))

			-- Focus should not have moved as a result of the above change
			expect(focusControllerInternal:isNodeFocused(childNodeA)).to.equal(true)

			Roact.unmount(tree)
		end)

		it("should clean up input event subscriptions when the Focusable they're bound to is detached", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()

			local beginCallbackSpy, moveStepCallbackSpy = createSpy(), createSpy()
			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				FocusChildA = Roact.createElement(FocusableFrame, {
					inputBindings = {
						Input.PublicInterface.onBegin(Enum.KeyCode.ButtonX, beginCallbackSpy.value),
						Input.PublicInterface.onMoveStep(moveStepCallbackSpy.value),
					}
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			focusController.captureFocus()

			expect(beginCallbackSpy.callCount).to.equal(0)
			expect(moveStepCallbackSpy.callCount).to.equal(0)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			mockEngine:renderStep()
			expect(beginCallbackSpy.callCount).to.equal(1)
			expect(moveStepCallbackSpy.callCount).to.equal(1)

			-- Remove the child from the tree, which will also nil its parents
			-- and trigger any auto-refocusing logic
			local tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				-- Child was removed
			}), nil)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			mockEngine:renderStep()
			expect(beginCallbackSpy.callCount).to.equal(1)
			expect(moveStepCallbackSpy.callCount).to.equal(1)

			Roact.unmount(tree)
		end)

		it("should clean up input event subscriptions when the whole tree is cleaned up", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()

			local beginCallbackSpy, moveStepCallbackSpy = createSpy(), createSpy()
			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				inputBindings = {
					Input.PublicInterface.onBegin(Enum.KeyCode.ButtonX, beginCallbackSpy.value),
					Input.PublicInterface.onMoveStep(moveStepCallbackSpy.value),
				}
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			focusController.captureFocus()
			expect(beginCallbackSpy.callCount).to.equal(0)
			expect(moveStepCallbackSpy.callCount).to.equal(0)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			mockEngine:renderStep()
			expect(beginCallbackSpy.callCount).to.equal(1)
			expect(moveStepCallbackSpy.callCount).to.equal(1)

			-- Remove the child from the tree, which will also nil its parents
			-- and trigger any auto-refocusing logic
			Roact.unmount(tree)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			mockEngine:renderStep()
			expect(beginCallbackSpy.callCount).to.equal(1)
			expect(moveStepCallbackSpy.callCount).to.equal(1)
		end)
	end)

	describe("Component behavior", function()
		it("should not replace any provided event handlers", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()

			local ancestryChangedSpy = createSpy()
			local descendantAddedSpy = createSpy()
			local descendantRemovedSpy = createSpy()
			local rootRef = Roact.createRef()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				[Roact.Ref] = rootRef,

				[Roact.Event.AncestryChanged] = ancestryChangedSpy.value,
				[Roact.Event.DescendantAdded] = descendantAddedSpy.value,
				[Roact.Event.DescendantRemoving] = descendantRemovedSpy.value,
			}), nil)

			expect(ancestryChangedSpy.callCount).to.equal(0)
			expect(descendantAddedSpy.callCount).to.equal(0)
			expect(descendantRemovedSpy.callCount).to.equal(0)

			local newParentFrame = Instance.new("Frame")
			rootRef:getValue().Parent = newParentFrame
			expect(ancestryChangedSpy.callCount).to.equal(1)

			local newChildFrame = Instance.new("Frame")
			newChildFrame.Parent = rootRef:getValue()
			expect(descendantAddedSpy.callCount).to.equal(1)

			newChildFrame.Parent = nil
			expect(descendantRemovedSpy.callCount).to.equal(1)

			Roact.unmount(tree)
		end)

		it("should update navigation logic correctly when props update", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()

			local xBindingSpy = createSpy()
			local yBindingSpy = createSpy()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
				inputBindings = {
					onXButton = Input.PublicInterface.onBegin(Enum.KeyCode.ButtonX, xBindingSpy.value),
				}
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			focusController.captureFocus()
			expect(xBindingSpy.callCount).to.equal(0)
			expect(yBindingSpy.callCount).to.equal(0)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			expect(xBindingSpy.callCount).to.equal(1)
			expect(yBindingSpy.callCount).to.equal(0)

			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
				inputBindings = {
					onYButton = Input.PublicInterface.onBegin(Enum.KeyCode.ButtonY, yBindingSpy.value),
				}
			}))

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonY,
			})
			expect(xBindingSpy.callCount).to.equal(1)
			expect(yBindingSpy.callCount).to.equal(1)

			-- Pressing X again does not trigger the old callback
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.ButtonX,
			})
			expect(xBindingSpy.callCount).to.equal(1)

			Roact.unmount(tree)
		end)

		it("should propagate updates to inherited parent neighbor relationships", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local parentRefA = Roact.createRef()
			local parentRefB = Roact.createRef()
			local childRefA = Roact.createRef()
			local childRefB = Roact.createRef()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				ParentA = Roact.createElement(FocusableFrame, {
					NextSelectionDown = parentRefB,
					[Roact.Ref] = parentRefA,
				}, {
					ChildA = Roact.createElement(FocusableFrame, {
						[Roact.Ref] = childRefA,
					})
				}),
				ParentB = Roact.createElement(FocusableFrame, {
					-- No neighbors set
					[Roact.Ref] = parentRefB,
				}, {
					ChildB = Roact.createElement(FocusableFrame, {
						[Roact.Ref] = childRefB,
					})
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			local childNodeA = getNode(childRefA)
			local childNodeB = getNode(childRefB)

			childNodeA:focus()
			expect(focusControllerInternal:isNodeFocused(childNodeA)).to.equal(true)

			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadDown,
			})
			expect(focusControllerInternal:isNodeFocused(childNodeB)).to.equal(true)

			-- Try moving back up; no neighbors are set, and none are inherited
			-- from the parents, so this shouldn't cause the selection to move
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadUp,
			})
			expect(focusControllerInternal:isNodeFocused(childNodeB)).to.equal(true)

			-- Update the tree to introduce an upward neighbor
			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				ParentA = Roact.createElement(FocusableFrame, {
					NextSelectionDown = parentRefB,
					[Roact.Ref] = parentRefA,
				}, {
					ChildA = Roact.createElement(FocusableFrame, {
						[Roact.Ref] = childRefA,
					})
				}),
				ParentB = Roact.createElement(FocusableFrame, {
					NextSelectionUp = parentRefA,
					[Roact.Ref] = parentRefB,
				}, {
					ChildB = Roact.createElement(FocusableFrame, {
						[Roact.Ref] = childRefB,
					})
				}),
			}))

			-- Make sure we're still on B like before
			expect(focusControllerInternal:isNodeFocused(childNodeB)).to.equal(true)

			-- This time, moving back up should work as expected
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadUp,
			})
			expect(focusControllerInternal:isNodeFocused(childNodeA)).to.equal(true)

			Roact.unmount(tree)
		end)

		it("should propagate updates to inherited grandparent neighbor relationships", function()
			local FocusableFrame = asFocusable("Frame")
			local focusController = FocusController.createPublicApiWrapper()
			local function getNode(ref)
				return focusController[InternalApi].allNodes[ref]
			end

			local refs = createRefCache()

			local tree = Roact.mount(Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				TopSelectionTarget = Roact.createElement(FocusableFrame, {
					NextSelectionDown = refs.bottomFocusable,
					[Roact.Ref] = refs.topFocusable,
				}),
				BottomSelectionTarget = Roact.createElement(FocusableFrame, {
					[Roact.Ref] = refs.bottomFocusable,
				}, {
					IntermediateChild = Roact.createElement(FocusableFrame, {}, {
						LeafChild = Roact.createElement(FocusableFrame, {
							[Roact.Ref] = refs.bottomLeaf,
						})
					}),
				}),
			}), nil)

			local focusControllerInternal = focusController[InternalApi]
			local mockEngine, engineInterface = MockEngine.new()
			focusControllerInternal:initialize(engineInterface)

			local bottomLeafNode = getNode(refs.bottomLeaf)
			bottomLeafNode:focus()
			expect(focusControllerInternal:isNodeFocused(bottomLeafNode)).to.equal(true)

			-- This upward input will not work on this tree, since there's no
			-- upward neighbor defined just yet
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadUp,
			})
			expect(focusControllerInternal:isNodeFocused(bottomLeafNode)).to.equal(true)

			-- Update the tree to introduce an upward neighbor
			tree = Roact.update(tree, Roact.createElement(FocusableFrame, {
				focusController = focusController,
			}, {
				TopSelectionTarget = Roact.createElement(FocusableFrame, {
					NextSelectionDown = refs.bottomFocusable,
					[Roact.Ref] = refs.topFocusable,
				}),
				BottomSelectionTarget = Roact.createElement(FocusableFrame, {
					NextSelectionUp = refs.topFocusable,
					[Roact.Ref] = refs.bottomFocusable,
				}, {
					IntermediateChild = Roact.createElement(FocusableFrame, {}, {
						-- This focusable child should be able to inherit
						-- neighbors from its grandparent
						LeafChild = Roact.createElement(FocusableFrame, {
							[Roact.Ref] = refs.bottomLeaf,
						})
					}),
				}),
			}))

			-- Make sure we're still on B like before
			expect(focusControllerInternal:isNodeFocused(bottomLeafNode)).to.equal(true)

			-- This time, moving up should work as expected
			mockEngine:simulateInput({
				UserInputType = Enum.UserInputType.Gamepad1,
				UserInputState = Enum.UserInputState.Begin,
				KeyCode = Enum.KeyCode.DPadUp,
			})
			local topNode = getNode(refs.topFocusable)
			expect(focusControllerInternal:isNodeFocused(topNode)).to.equal(true)

			Roact.unmount(tree)
		end)
	end)
end