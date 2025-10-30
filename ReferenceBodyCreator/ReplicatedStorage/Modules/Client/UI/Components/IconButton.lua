--[[
	Generic button with an icon. Used for various buttons, including the local
	menu and the panel header buttons.
]]

local IconButton = {}

export type IconButtonInfo = {
	iconId: string,
	callback: () -> (),
}

function IconButton.createComponentFrame(iconAssetId, onActivated)
	local iconButton = Instance.new("TextButton")
	iconButton.Name = "IconButton"
	iconButton.Text = ""

	if onActivated then
		iconButton.Activated:Connect(onActivated)
	end

	-- Most styling is done via StyleSheets on either the parent component or an applied tag -- see UI/Style.lua

	local icon = Instance.new("ImageLabel")
	icon.Image = iconAssetId
	icon.BackgroundTransparency = 1
	icon.Parent = iconButton

	return iconButton
end

return IconButton
