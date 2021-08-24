local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local CharacterManager = require(script.Parent.CharacterManager)
local GetAvatarData = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetAvatarData)
local GetAvatarRules = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetAvatarRules)

local FFlagLuaAppEnableAERedesign = function() return true end

local CharacterLoader = {}
CharacterLoader.__index = CharacterLoader

local function getEquippedAssets(state)
	if FFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.EquippedAssets
	else
		return state.AEAppReducer.AECharacter.AEEquippedAssets
	end
end

function CharacterLoader:getAvatarData()
	self.store:dispatch(GetAvatarData()):andThen(function()
		self.characterManager:initializeModel(self.store:getState())
	end)
end

function CharacterLoader.new(store)
	local self = {}
	setmetatable(self, CharacterLoader)

	self.store = store
	self.characterManager = CharacterManager.new(store)
	self:getAvatarData()
	self.store:dispatch(GetAvatarRules())

	return self
end

function CharacterLoader:start()
	self.shouldStart = true
	local characterModelVersion = self.store:getState().AvatarExperience.AvatarScene.Character.CharacterModelVersion
	local equippedAssets = getEquippedAssets(self.store:getState())

	local obtainedAvatarRules
	if FFlagLuaAppEnableAERedesign() then
		obtainedAvatarRules = self.store:getState().AvatarExperience.AvatarEditor.AvatarSettings.ObtainedAvatarRules
	else
		obtainedAvatarRules = true
	end

	self.storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)

	if not obtainedAvatarRules then
		self.store:dispatch(GetAvatarRules())
	end

	if characterModelVersion > 0 then
		self.characterManager:start()
		self.shouldStart = false
	elseif not equippedAssets then
		-- Retry if initialization has failed.
		self:getAvatarData()
		return
	end
end

function CharacterLoader:update(newState, oldState)
	local characterModelVersion = newState.AvatarExperience.AvatarScene.Character.CharacterModelVersion
	local prevCharacterModelVersion = oldState.AvatarExperience.AvatarScene.Character.CharacterModelVersion

	if characterModelVersion ~= prevCharacterModelVersion and characterModelVersion > 0 and self.shouldStart then
		self.characterManager:start()
		self.shouldStart = false
		self.storeChangedConnection:disconnect()
		self.storeChangedConnection = nil
	end
end

function CharacterLoader:stop()
	self.shouldStart = false
	local characterModelVersion = self.store:getState().AvatarExperience.AvatarScene.Character.CharacterModelVersion

	if characterModelVersion > 0 then
		self.characterManager:stop()
	end

	if self.storeChangedConnection then
		self.storeChangedConnection:disconnect()
		self.storeChangedConnection = nil
	end
end

function CharacterLoader:onDestroy()
	self.characterManager:onDestroy()
end

return CharacterLoader
