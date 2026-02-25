return function()
	local Container = script.Parent
	local App = Container.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local Cryo = require(Packages.Cryo)
	local RetrievalStatus = require(UIBlox.App.Loading.Enum.RetrievalStatus)
	local LoadingStateContainer = require(script.Parent.LoadingStateContainer)
	local mockStyleComponent = require(Packages.UIBlox.Utility.mockStyleComponent)

	describe("lifecycle", function()
		local frame = Instance.new("Frame")
		local renderFrame = function()
			return Roact.createElement("Frame")
		end

		local defaultLoadingStateContainerProps = {
			dataStatus = RetrievalStatus.NotStarted,
			onRetry = function() end,
			renderOnEmpty = renderFrame,
			renderOnLoaded = renderFrame,
			renderOnFailed = renderFrame,
			renderOnLoading = renderFrame,
		}

		it("should mount and unmount with only required props", function()
			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, {
					renderOnLoaded = renderFrame,
					renderOnFailed = renderFrame,
					dataStatus = RetrievalStatus.NotStarted,
				})
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")
			Roact.unmount(instance)
		end)

		it("should mount and unmount with all props", function()
			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, defaultLoadingStateContainerProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")
			Roact.unmount(instance)
		end)

		it("should render empty page with RetrievalStatus.NotStarted", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.NotStarted,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedEmpty).to.equal(true)
			expect(renderedLoading).to.equal(false)
			expect(renderedFailed).to.equal(false)
			expect(renderedLoaded).to.equal(false)

			Roact.unmount(instance)
		end)

		it("should render loading page with RetrievalStatus.Fetching", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.Fetching,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedEmpty).to.equal(false)
			expect(renderedLoading).to.equal(true)
			expect(renderedFailed).to.equal(false)
			expect(renderedLoaded).to.equal(false)

			Roact.unmount(instance)
		end)

		it("should render failed page with RetrievalStatus.Done", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.Done,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedEmpty).to.equal(false)
			expect(renderedLoading).to.equal(false)
			expect(renderedFailed).to.equal(false)
			expect(renderedLoaded).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should render loaded page with RetrievalStatus.Failed", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.Failed,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedEmpty).to.equal(false)
			expect(renderedLoading).to.equal(false)
			expect(renderedFailed).to.equal(true)
			expect(renderedLoaded).to.equal(false)

			Roact.unmount(instance)
		end)

		it("should be able to cycle through all the states", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.NotStarted,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedEmpty).to.equal(true)

			-- Fetching
			combinedProps = Cryo.Dictionary.join(combinedProps, {
				dataStatus = RetrievalStatus.Fetching,
			})

			element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})

			Roact.update(instance, element)

			expect(renderedLoading).to.equal(true)

			-- Fetching
			combinedProps = Cryo.Dictionary.join(combinedProps, {
				dataStatus = RetrievalStatus.Fetching,
			})

			element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})

			Roact.update(instance, element)

			expect(renderedLoading).to.equal(true)

			-- Failed
			combinedProps = Cryo.Dictionary.join(combinedProps, {
				dataStatus = RetrievalStatus.Failed,
			})

			element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})

			Roact.update(instance, element)

			expect(renderedFailed).to.equal(true)

			-- Done
			combinedProps = Cryo.Dictionary.join(combinedProps, {
				dataStatus = RetrievalStatus.Done,
			})

			element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})

			Roact.update(instance, element)

			expect(renderedLoaded).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should be able to go from Done to NotStarted", function()
			local renderedEmpty = false
			local renderedLoading = false
			local renderedFailed = false
			local renderedLoaded = false
			local combinedProps = Cryo.Dictionary.join(defaultLoadingStateContainerProps, {
				dataStatus = RetrievalStatus.Done,
				renderOnEmpty = function() renderedEmpty = true end,
				renderOnLoading = function() renderedLoading = true end,
				renderOnFailed = function() renderedFailed = true end,
				renderOnLoaded = function() renderedLoaded = true end,
			})

			local element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})
			local instance = Roact.mount(element, frame, "LoadingStateContainer")

			expect(renderedLoaded).to.equal(true)

			-- NotStarted
			combinedProps = Cryo.Dictionary.join(combinedProps, {
				dataStatus = RetrievalStatus.NotStarted,
			})

			element = mockStyleComponent({
				loadingStateContainer = Roact.createElement(LoadingStateContainer, combinedProps)
			})

			Roact.update(instance, element)

			expect(renderedEmpty).to.equal(true)
			expect(renderedLoading).to.equal(false)
			expect(renderedFailed).to.equal(false)

			Roact.unmount(instance)
		end)
	end)
end
