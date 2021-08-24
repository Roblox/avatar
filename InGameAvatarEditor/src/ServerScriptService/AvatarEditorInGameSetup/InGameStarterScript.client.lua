local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarEditorService = game:GetService("AvatarEditorService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

script.Parent.ShowAndLeave.Enabled = true
local showButton = script.Parent.ShowAndLeave.EditAvatarButton
local leaveButton = script.Parent.ShowAndLeave.LeaveButton

local areDescriptionsDifferent = require(script.Parent.areDescriptionsDifferent)

local AvatarEditorManager
local firstTime = true

local function initStuff()
	spawn(function()
		print("Calling Prompt allow inventory read access!")
		AvatarEditorService:PromptAllowInventoryReadAccess()
	end)

	print("Waiting on Allow inventory read access event")
	local result = AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Wait()

	print("Got result of PromptAllowInventoryReadAccessCompleted", result)

	if result == Enum.AvatarPromptResult.Success then
		AvatarEditorManager = require(script.Parent.AvatarEditorManager)
		firstTime = false
		return true
	end

	return false
end

local function showAvatarEditor()
	showButton.Visible = false

	if firstTime then
		if not initStuff() then
			showButton.Visible = true
			return
		end
	end

	--lighting.WhiteSky.Parent = replicatedStorage
	AvatarEditorManager:showAvatarEditor()
	leaveButton.Visible = true
end

local function isDifferentToLocalHumanoid(humanoidDescription, avatarType)
	local currentHumanoidDescription
	local rigType
	if Players.LocalPlayer.Character then
		local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			currentHumanoidDescription = humanoid:GetAppliedDescription()
			rigType = humanoid.RigType
		end
	end

	if not currentHumanoidDescription then
		currentHumanoidDescription = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId)
		rigType = avatarType
	end

	if rigType ~= avatarType then
		return true
	end

	if areDescriptionsDifferent(currentHumanoidDescription, humanoidDescription) then
		return true
	end

	return false
end

local leaving = false

local function hideAvatarEditor()
	if leaving then
		return
	end
	leaving = true

	local wasOpen = AvatarEditorManager:closeItemDetails()

	if wasOpen then
		wait(2)
	end

	local characterRoot = game.Workspace.CharacterRoot
	local humanoidDescription
	local avatarType
	if characterRoot:FindFirstChild("CharacterR15") then
		avatarType = Enum.HumanoidRigType.R15
		humanoidDescription = characterRoot.CharacterR15.Humanoid:GetAppliedDescription()
	else
		avatarType = Enum.HumanoidRigType.R6
		humanoidDescription = characterRoot.CharacterR6.Humanoid:GetAppliedDescription()
	end

	if isDifferentToLocalHumanoid(humanoidDescription, avatarType) then
		AvatarEditorService:PromptSaveAvatar(humanoidDescription, avatarType)

		AvatarEditorService.PromptSaveAvatarCompleted:Wait()
	end

	AvatarEditorManager:hideAvatarEditor()

	game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

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
