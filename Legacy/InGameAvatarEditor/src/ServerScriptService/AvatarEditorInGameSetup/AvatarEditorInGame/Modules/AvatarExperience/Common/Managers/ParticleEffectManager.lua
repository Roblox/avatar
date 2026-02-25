local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Assets = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Assets

local FFlagLuaAppEnableAERedesign = function() return true end
local IsLuaCatalogPageEnabled = true

local HIGH_QUALITY_PART_SWAP_EMITTER_RATE = 10
local HIGH_QUALITY_PART_SWAP_MEDIUM_EMISSION_RATE = 20
local HIGH_QUALITY_PART_SWAP_SMALL_EMISSION_RATE = 20

local ParticleEffectManager = {}
ParticleEffectManager.__index = ParticleEffectManager

local function getEquippedAssets(state)
	if FFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.EquippedAssets
	else
		return state.AEAppReducer.AECharacter.AEEquippedAssets
	end
end

local function getAvatarType(state)
	if FFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.AvatarType
	else
		return state.AEAppReducer.AECharacter.AEAvatarType
	end
end

local function getBodyColors(state)
	if FFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.BodyColors
	else
		return state.AEAppReducer.AECharacter.AEBodyColors
	end
end

function ParticleEffectManager.new(store)
	local self = {}
	setmetatable(self, ParticleEffectManager)

	self.connections = {}
	self.store = store

	self.avatarSwapPFX = Assets:FindFirstChild("AvatarSwap-PFX")
	self.emittionCount = 0
	return self
end

function ParticleEffectManager:start()
	self.avatarSwapPFX.Parent = Workspace

	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	table.insert(self.connections, storeChangedConnection)

	--[[
		-- TODO AVBURST-1686 Look into having a consistent App rendering quality level.
		App starts at Level01 quality level. When a user joins a game the quality level
		changes to whatever the game has. If the quality level increases, the particle
		emitter rate needs to change.
	]]
	self.avatarSwapPFX.MainEmitter.Rate = HIGH_QUALITY_PART_SWAP_EMITTER_RATE
	self.avatarSwapPFX.MediumEmitter.MediumEmissions.Rate = HIGH_QUALITY_PART_SWAP_MEDIUM_EMISSION_RATE
	self.avatarSwapPFX.SmallerEmitter.SmallerEmissions.Rate = HIGH_QUALITY_PART_SWAP_SMALL_EMISSION_RATE
end

function ParticleEffectManager:stop()
	self.avatarSwapPFX.Parent = ReplicatedStorage

	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}
end

function ParticleEffectManager:update(newState, oldState)
	local curEquipped = getEquippedAssets(newState)
	local oldEquipped = getEquippedAssets(oldState)
	local equippedChanged = curEquipped ~= oldEquipped

	local curAvatarType = getAvatarType(newState)
	local oldAvatarType = getAvatarType(oldState)
	local avatarTypeChanged = curAvatarType ~= oldAvatarType

	local curBodyColors = getBodyColors(newState)
	local oldBodyColors = getBodyColors(oldState)
	local bodyColorsChanged = curBodyColors ~= oldBodyColors

	local curTryOn
	local oldTryOn
	local tryOnChanged = false

	if IsLuaCatalogPageEnabled then
		curTryOn = newState.AvatarExperience.AvatarScene.TryOn.SelectedItem
		oldTryOn = oldState.AvatarExperience.AvatarScene.TryOn.SelectedItem
		tryOnChanged = curTryOn ~= oldTryOn
	end

	if equippedChanged or avatarTypeChanged or bodyColorsChanged or tryOnChanged then
		self:runParticleEmitter()
	end
end

function ParticleEffectManager:runParticleEmitter()
	coroutine.wrap(function()
		self.avatarSwapPFX.MainEmitter.Enabled = true
		self.avatarSwapPFX.MediumEmitter.MediumEmissions.Enabled = true
		self.avatarSwapPFX.SmallerEmitter.SmallerEmissions.Enabled = true

		self.emittionCount = self.emittionCount + 1
		local thisemittionCount = self.emittionCount

		wait(.3)

		if self.emittionCount == thisemittionCount then
			self.avatarSwapPFX.MainEmitter.Enabled = false
			self.avatarSwapPFX.MediumEmitter.MediumEmissions.Enabled = false
			self.avatarSwapPFX.SmallerEmitter.SmallerEmissions.Enabled = false
		end
	end)()
end

function ParticleEffectManager:onDestroy()
end

return ParticleEffectManager
