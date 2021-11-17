local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarEvents = ReplicatedStorage:WaitForChild("AvatarEvents")
local avatarEditorClosed = AvatarEvents.AvatarEditorClosed

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
while not PlayerGui do
	LocalPlayer.ChildAdded:Wait()
	PlayerGui = LocalPlayer.PlayerGui
end

local AvatarEditorInGame = script.Parent

local AvatarEditorInGameScreenGui = AvatarEditorInGame:FindFirstChild("AvatarEditorInGame")

AvatarEditorInGameScreenGui.Parent = PlayerGui

local Modules = PlayerGui:WaitForChild("AvatarEditorInGame"):WaitForChild("Modules")

local UIBlox = require(Modules.Packages.UIBlox)

UIBlox.init()

local SetupAvatarEditor = require(Modules.Setup.SetupAvatarEditor)
local areDescriptionsDifferent = require(Modules.Util.areDescriptionsDifferent)
local humanoidDescriptionFromState = require(Modules.Util.humanoidDescriptionFromState)

local RunAvatarSceneManager = require(Modules.Setup.Actions.RunAvatarSceneManager)

local AvatarEditorInterface = {}
AvatarEditorInterface.__index = AvatarEditorInterface

function AvatarEditorInterface.new()
	local self = setmetatable({}, AvatarEditorInterface)

	self.store = nil
	self.hasInventoryReadPermission = false
	self.isInitalized = false
	self.isShowingAvatarEditor = false

	return self
end

--- Internal Methods:
function AvatarEditorInterface:_setupAvatarEditor()
	self.store = SetupAvatarEditor()
	self.isInitalized = true
end

-- Public methods:
function AvatarEditorInterface:promptAllowInventoryReadAccess()
	if self.hasInventoryReadPermission then
		warn("promptAllowInventoryReadAccess when we already have access")
		return
	end

	spawn(function()
		AvatarEditorService:PromptAllowInventoryReadAccess()
	end)
	local result = AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Wait()

	if result == Enum.AvatarPromptResult.Success then
		return true
	end
	return false
end

function AvatarEditorInterface:showAvatarEditor()
	if not self.hasInventoryReadPermission then
		if not self:promptAllowInventoryReadAccess() then
			return false
		end
	end

	if not self.isInitalized then
		self:_setupAvatarEditor()
	end

	self.isShowingAvatarEditor = true
	PlayerGui.AvatarEditorInGame.Enabled = true
	self.store:dispatch(RunAvatarSceneManager(true))
end

function AvatarEditorInterface:promptSaveAvatar(currentDescription, currentRigType)
	if currentDescription == nil then
		currentDescription, currentRigType = self:getCurrentDescription()
	end

	AvatarEditorService:PromptSaveAvatar(currentDescription, currentRigType)

	AvatarEditorService.PromptSaveAvatarCompleted:Wait()
end

-- Returns a HumanoidDescription based on what is equipped in the Avatar editor
function AvatarEditorInterface:getEditedDescription()
	if not self.isInitalized then
		warn("getEditedDescription called before initalization")
		return
	end

	local state = self.store:getState()
	local avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType
	local rigTypeEnum = avatarType and Enum.HumanoidRigType[avatarType] or Enum.HumanoidRigType.R15

	return humanoidDescriptionFromState(state, --[[includeTryOn =]] false), rigTypeEnum
end

-- Returns the current HumanoidDescription of the LocalPlayer
-- Defaults to the description of the players character in workspace
-- This function can yeild if the player has no character
function AvatarEditorInterface:getCurrentDescription()
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid:GetAppliedDescription() then
			return humanoid:GetAppliedDescription(), humanoid.RigType
		end
	end

	return Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId), Enum.HumanoidRigType.R15
end

function AvatarEditorInterface:areDescriptionsDifferent(descA, descB)
	return areDescriptionsDifferent(descA, descB)
end

function AvatarEditorInterface:hideAvatarEditor(saveOnClose)
	if not self.isInitalized then
		warn("hideAvatarEditor called before initalization")
		return
	end

	if saveOnClose then
		local currentDescription, currentRigType = self:getCurrentDescription()
		local editedDescription, editedRigType = self:getEditedDescription()

		local rigTypeDifferent = currentRigType ~= editedRigType
		local descriptionDifferent = self:areDescriptionsDifferent(currentDescription, editedDescription)

		if rigTypeDifferent or descriptionDifferent then
			self:promptSaveAvatar(currentDescription, currentRigType)
		end
	end

	self.isShowingAvatarEditor = false
	PlayerGui.AvatarEditorInGame.Enabled = false
	self.store:dispatch(RunAvatarSceneManager(false))

	avatarEditorClosed:FireServer()
end

function AvatarEditorInterface:showingAvatarEditor()
	return self.isShowingAvatarEditor
end

return AvatarEditorInterface.new()
