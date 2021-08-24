return function()
	local BaseTile = script.Parent
	local TileRoot = BaseTile.Parent
	local App = TileRoot.Parent
	local UIBlox = App.Parent
	local Packages = UIBlox.Parent

	local Roact = require(Packages.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local PlayerTileButton = require(script.Parent.PlayerTileButton)
	local Images = require(UIBlox.App.ImageSet.Images)
	-- uses DarkTheme since mockStyleComponent mounts in dark theme
	local DarkTheme = require(UIBlox.App.Style.Themes.DarkTheme)

	describe("PlayerTileButton Component", function()
		local buttonIcon = Images["icons/status/player/friend"]

		it("should take on secondary styling if isSecondary is set to true", function()
			local element = mockStyleComponent({
				PlayerTileButton = Roact.createElement(PlayerTileButton, {
					isSecondary = true,
					icon = buttonIcon,
				})
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			local button = folder:FindFirstChildWhichIsA("ImageButton", true)
			local styleObject = DarkTheme.SecondaryDefault
			expect(button.ImageColor3).to.equal(styleObject.Color)
			expect(button.ImageTransparency).to.be.near(styleObject.Transparency)

			Roact.unmount(instance)
		end)

		it("should take on primary styling if isSecondary is not set", function()
			local element = mockStyleComponent({
				PlayerTileButton = Roact.createElement(PlayerTileButton, {
					icon = buttonIcon,
				})
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)
			local button = folder:FindFirstChildWhichIsA("ImageButton", true)
			local styleObject = DarkTheme.SystemPrimaryDefault
			expect(button.ImageColor3).to.equal(styleObject.Color)
			expect(button.ImageTransparency).to.be.near(styleObject.Transparency)

			Roact.unmount(instance)
		end)
	end)
end
