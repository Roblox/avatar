--[[ Roblox Services ]]--
local PlayersService = game:GetService("Players")

local LocalPlayer = PlayersService.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--[[ Constants ]]--
script.Parent.ShowAndLeave.Enabled = true

local showButton = script.Parent.ShowAndLeave.EditAvatarButton
local leaveButton = script.Parent.ShowAndLeave.LeaveButton

local AvatarEditorInterface = require(script.Parent.AvatarEditorInterface)

local touchGuiWasEnabled = false

local function showAvatarEditor()
	showButton.Visible = false

	local touchGui = PlayerGui:FindFirstChild("TouchGui")
	if touchGui then
		touchGuiWasEnabled = touchGui.Enabled
		touchGui.Enabled = false
	end

	AvatarEditorInterface:showAvatarEditor()
	leaveButton.Visible = true
end

local leaving = false

local function hideAvatarEditor()
	if leaving then
		return
	end
	leaving = true

	AvatarEditorInterface:hideAvatarEditor(--[[saveOnClose =]] true)

	local touchGui = PlayerGui:FindFirstChild("TouchGui")
	if touchGui then
		touchGui.Enabled = touchGuiWasEnabled
	end

	game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			game.Workspace.CurrentCamera.CameraSubject = humanoid
		end
	end

	leaveButton.Visible = false
	showButton.Visible = true
	leaving = false
end

showButton.Activated:connect(function()
	showAvatarEditor()
end)

leaveButton.Activated:connect(function()
	hideAvatarEditor()
end)