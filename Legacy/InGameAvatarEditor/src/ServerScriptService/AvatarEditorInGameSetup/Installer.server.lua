local StarterGui = game:GetService("StarterGui")
local ServerScriptService = game:GetService("ServerScriptService")

local AvatarEditorSetup = script.Parent

local function installServerScripts()
	local ServerScript = AvatarEditorSetup.AvatarEditorServer
	ServerScript.Parent = ServerScriptService
	ServerScript.Disabled = false
end

local ClientScripts = {
	"AvatarEditorInterface",
	"InGameStarterScript"
}

local function installClientScripts()
	local AvatarEditorClientSetup = Instance.new("ScreenGui")
	AvatarEditorClientSetup.ResetOnSpawn = false
	AvatarEditorClientSetup.Name = "AvatarEditorClientSetup"

	local AvatarEditorInGame = AvatarEditorSetup.AvatarEditorInGame
	AvatarEditorInGame.Parent = AvatarEditorClientSetup

	local ShowAndLeave = AvatarEditorSetup.ShowAndLeave
	ShowAndLeave.Parent = AvatarEditorClientSetup

	for _, scriptName in ipairs(ClientScripts) do
		local clientScript = AvatarEditorSetup:FindFirstChild(scriptName)
		clientScript.Parent = AvatarEditorClientSetup
	end

	AvatarEditorClientSetup.Parent = StarterGui
end

installServerScripts()
installClientScripts()
