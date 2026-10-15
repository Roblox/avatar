--[[
	Generic button with an icon. Used for various buttons, including the local
	menu and the panel header buttons.
]]

local IconButton = {}

export type IconButtonInfo = {
	iconId: string,
	callback: () -> (),
	getIsMuted: (() -> boolean)?, -- callback that is used to add the muted style when this returns true
}

function IconButton.createComponentFrame(iconImage: string | Content, onActivated: (() -> ())?)
	local iconButton = Instance.new("TextButton")
	iconButton.Name = "IconButton"
	iconButton.Text = ""

	if onActivated then
		iconButton.Activated:Connect(onActivated)
	else
		iconButton.Active = false
	end

	-- Most styling is done via StyleSheets on either the parent component or an applied tag -- see UI/Style.lua

	local icon = Instance.new("ImageLabel")
	if typeof(iconImage) == "string" then
		icon.Image = iconImage
	else
		icon.ImageContent = iconImage
	end
	icon.BackgroundTransparency = 1
	icon.Parent = iconButton

	return iconButton, icon
end

return IconButton
