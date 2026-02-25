local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Logging = require(Modules.Packages.Logging)

local SetCurrentCharacter = require(Modules.AvatarExperience.Common.Actions.SetCurrentCharacter)
local IncrementCharacterModelVersion =
	require(Modules.AvatarExperience.AvatarEditor.Actions.IncrementCharacterModelVersion)
local IncrementTryOnCharacterModelVersion =
	require(Modules.AvatarExperience.Catalog.Actions.IncrementTryOnCharacterModelVersion)
local GetOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetOutfit)
local FetchBundleInfo = require(Modules.AvatarExperience.Catalog.Thunks.FetchBundleInfo)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AnimationManager = require(Modules.AvatarExperience.Common.Managers.AnimationManager)
local BodyColorManager = require(Modules.AvatarExperience.Common.Managers.BodyColorManager)

local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local humanoidDescriptionFromState = require(Modules.Util.humanoidDescriptionFromState)

local UseTempHacks = require(Modules.Config.UseTempHacks)

local IsLuaCatalogPageEnabled = true


local CharacterManager = {}
CharacterManager.__index = CharacterManager

local HumanoidDescriptionIdToName = AvatarExperienceConstants.HumanoidDescriptionIdToName
local HumanoidDescriptionScaleToName = AvatarExperienceConstants.HumanoidDescriptionScaleToName
local HumanoidDescriptionBodyColorIdToName = AvatarExperienceConstants.HumanoidDescriptionBodyColorIdToName

local function isTool(entity)
	return entity:IsA('Tool')
end

local function isScript(entity)
	return entity:IsA('Script')
end

local function isScreenGui(entity)
	return entity:IsA('ScreenGui')
end

local function copyHumanoidDescriptionBodyColors(from, to)
	for _, propertyName in pairs(HumanoidDescriptionBodyColorIdToName) do
		to[propertyName] = from[propertyName]
	end
end

local function combineHumanoidDescriptions(base, override)
	local result = base:Clone()
	for _, propertyName in pairs(HumanoidDescriptionIdToName) do
		if not (override[propertyName] == "" or override[propertyName] == 0) then
			result[propertyName] = override[propertyName]
		end
	end
	return result
end

local function createHumanoidDescriptionFromOutfit(outfitDetails)
	local humanoidDescription = Instance.new("HumanoidDescription")

	local outfitAssets = outfitDetails.assets
	if outfitAssets then
		for assetType, assets in pairs(outfitAssets) do
			local propertyName = HumanoidDescriptionIdToName[assetType]
			if propertyName and assetType ~= AvatarExperienceConstants.AssetTypes.Gear then
				humanoidDescription[propertyName] = table.concat(assets, ",")
			end
		end
	end

	local bodyColors = outfitDetails.bodyColors
	if bodyColors then
		for id, bodyColor in pairs(bodyColors) do
			local propertyName = HumanoidDescriptionBodyColorIdToName[id]
			if propertyName then
				humanoidDescription[propertyName] = BrickColor.new(bodyColor).Color
			end
		end
	end

	local scales = outfitDetails.scales
	if scales then
		for scale, percentage in pairs(scales) do
			local propertyName = HumanoidDescriptionScaleToName[scale]
			humanoidDescription[propertyName] = percentage
		end
	end

	return humanoidDescription
end

local function getToolAssetIdFromOutfitDetails(outfitDetails)
	local assets = outfitDetails.assets
	if not assets then
		return
	end

	local tools = assets[AvatarExperienceConstants.AssetTypes.Gear]
	if not tools then
		return
	end

	return tools[1]
end

local function disableScripts(tool)
	for _, child in pairs(tool:GetChildren()) do
		if isScript(child) then
			child.Disabled = true
			disableScripts(child)
		elseif isScreenGui(child) then
			child.Enabled = false
			disableScripts(child)
		end
	end
end

local function isBundleInfoFetching(state, bundleId)
	local fetchStatus = PerformFetch.GetStatus(state, CatalogConstants.FetchBundleInfoKey.. tostring(bundleId))
	return fetchStatus == RetrievalStatus.Fetching
end

local function isOutfitInfoFetching(state, outfitId)
	local fetchStatus = PerformFetch.GetStatus(state, AvatarExperienceConstants.OutfitInfoKey .. tostring(outfitId))
	return fetchStatus == RetrievalStatus.Fetching
end

local function getBundleInfoFromState(state, bundleId)
	local bundles = state.AvatarExperience.Common.Bundles

	local bundleInfo = bundles[bundleId]
	if not bundleInfo then
		return nil
	end

	if bundleInfo.receivedBundleDetails then
		return bundleInfo
	end
end

local function getUserOutfitIdForBundle(bundleDetails)
	for _, itemInfo in pairs(bundleDetails.items) do
		if itemInfo.type == CatalogConstants.ItemType.UserOutfit then
			return itemInfo.id
		end
	end

	-- Incomplete bundle details, the full bundle details will need to be fetched
	return nil
end

local function getOutfits(state)
	return state.AvatarExperience.AvatarEditor.Outfits
end

local function getToolIdForBundle(state, bundleId)
	local bundleInfo = getBundleInfoFromState(state, bundleId)
	if not bundleInfo then
		return
	end

	local userOutfitId = getUserOutfitIdForBundle(bundleInfo)
	if not userOutfitId then
		return
	end

	local outfits = getOutfits(state)
	local outfitInfo = outfits[userOutfitId]
	if not outfitInfo then
		return
	end

	return getToolAssetIdFromOutfitDetails(outfitInfo)
end

local function wasTryingOnTool(state, tryOn)
	if tryOn.itemSubType == AvatarExperienceConstants.AssetTypes.Gear then
		return true
	end

	if tryOn.itemType == CatalogConstants.ItemType.Bundle then
		local toolId = getToolIdForBundle(state, tryOn.itemId)
		if toolId then
			return true
		end
	end

	return false
end

local function getEquippedAssets(state)
	return state.AvatarExperience.AvatarEditor.Character.EquippedAssets
end

local function getAvatarType(state)
	return state.AvatarExperience.AvatarEditor.Character.AvatarType
end

local function getAvatarScales(state)
	return state.AvatarExperience.AvatarEditor.Character.AvatarScales
end

local function getBodyColors(state)
	return state.AvatarExperience.AvatarEditor.Character.BodyColors
end

function CharacterManager.new(store)
	local self = {}
	setmetatable(self, CharacterManager)

	self.startAvatarModelLoadTime = tick()
	self.connections = {}
	self.store = store

	-- Set up models for the Avatar Editor
	if UseTempHacks then
		local r15Model = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
		r15Model.Name = "CharacterR15"
		r15Model.PrimaryPart = r15Model.HumanoidRootPart
		r15Model:MoveTo(Vector3.new(0, 10000, 0))
		r15Model.HumanoidRootPart.Anchored = true

		self.r6 = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
		self.r6.Name = "CharacterR6"
		if self.r6:FindFirstChild("Animate") then
			local animations = self.r6.Animate:GetChildren()
			local folder = Instance.new("Folder")
			folder.Name = "Animations"
			folder.Parent = self.r6

			for _, animation in ipairs(animations) do
				animation.Parent = folder
			end
			self.r6.Animate:Destroy()
		end

		self.r15 = r15Model
	else
		self.r6 = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
		self.r15 = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	end
	self.r6.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	self.r15.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	self.r6.HumanoidRootPart.Anchored = true
	self.r15.HumanoidRootPart.Anchored = true

	-- Default Avatar position in the workspace.
	--self.r6.HumanoidRootPart.CFrame =
	--	CFrame.new(-3.29430342, 3.12223077, 0.134697497, -0.449271739, 0, -0.893395126, 0, 1, 0, 0.893395126, 0, -0.449271739)
	--	* CFrame.new(Vector3.new(0, 10000, 0))
	local primaryPartCFrame = CFrame.new(-3.29430342, 3.12223077 + 10001.5, 0.134697497, -0.449271739, 0, -0.893395126, 0, 1, 0, 0.893395126, 0, -0.449271739)
		--* CFrame.new(Vector3.new(0, 10000, 0))
	self.r6:SetPrimaryPartCFrame(primaryPartCFrame)

	self.currentCharacter = self.r15
	self.store:dispatch(SetCurrentCharacter(self.currentCharacter))
	self.characterRoot = Instance.new("Folder")
	self.characterRoot.Name = "CharacterRoot"
	self.characterRoot.Parent = game.Workspace
	self.characterCFrame = self.r6.HumanoidRootPart.CFrame
	self.r15:SetPrimaryPartCFrame(self.characterCFrame)

	self.equippedToolModel = nil
	self.needsToEquipBundleTryOn = false
	self.destroyed = false

	self.animationManager = AnimationManager.new(store, self)
	self.bodyColorManager = BodyColorManager.new(store, self)
	self.humanoidDescription = Instance.new("HumanoidDescription")

	return self
end

-- Initialize the model before accessing the avatar editor.
function CharacterManager:initializeModel(state)
	local avatarType = getAvatarType(state)
	local equippedAssets = getEquippedAssets(state)

	if avatarType == Constants.AvatarType.R6 then
		self:switchAvatarType(avatarType)
	end

	self.currentCharacter.Parent = self.characterRoot
	self.humanoidDescription = humanoidDescriptionFromState(self.store:getState(), --[[includeTryOn =]] true)
	self.bodyColorManager:manageDefaultClothing(equippedAssets, false)
	self:applyHumanoidDescription(true)

	local tool = equippedAssets and equippedAssets[AvatarExperienceConstants.AssetTypes.Gear]
	if tool and tool[1] then
		self:loadAndEquipTool(tool[1], AvatarExperienceConstants.AssetTypes.Gear)
	end
end

function CharacterManager:start()
	self.currentCharacter.Parent = self.characterRoot

	if UseTempHacks then
		self:initializeModel(self.store:getState())
	end

	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	table.insert(self.connections, storeChangedConnection)

	self.animationManager:start()
	self.bodyColorManager:start()
end

function CharacterManager:applyHumanoidDescription(incrementCharacterModelVersion,
	incrementTryOnCharacterModelVersion, humanoidDescriptionOverride)
	coroutine.wrap(function()
		local humanoidDescription
		if humanoidDescriptionOverride then
			if AvatarExperienceUtils.isFullyQualifiedCostume(humanoidDescriptionOverride) then
				humanoidDescription = humanoidDescriptionOverride
			else
				humanoidDescription = combineHumanoidDescriptions(self.humanoidDescription, humanoidDescriptionOverride)
			end
			copyHumanoidDescriptionBodyColors(self.humanoidDescription, humanoidDescription)
		else
			humanoidDescription = self.humanoidDescription
		end

		if self.destroyed then
			return
		end

		--[[ humanoidDescription is shared by all coroutines. When the API returns, potentially much later (because some models had to be
		fetched), there's a chance the user has requested a new humanoidDescription. In that case, the shared humanoidDescription will be
		different than what it was before the API call.
		In that case, we reapply the new humanoidDescription, in case another coroutine's API call returned before this one.
		Caveat: if multiple modifications have been requested by the user, as many coroutines will exist and all of them will reapply the
		same, shared humanoidDescription (that contains the latest changes) again. But they will return immediately because of the caching
		mechanism in the C++ layer. --]]
		self.currentCharacter.Humanoid:ApplyDescription(humanoidDescription)

		if self.currentCharacter == self.r15 then
			self:adjustHeightToStandOnPlatform(self.currentCharacter)
		end

		if incrementCharacterModelVersion then
			self.store:dispatch(IncrementCharacterModelVersion())
		elseif incrementTryOnCharacterModelVersion then
			self.store:dispatch(IncrementTryOnCharacterModelVersion())
		end
	end)()
end

function CharacterManager:checkShouldTryOnBundle(newState, oldState)
	local curTryOn = newState.AvatarExperience.AvatarScene.TryOn.SelectedItem
	local oldTryOn = oldState.AvatarExperience.AvatarScene.TryOn.SelectedItem

	local bundleId = curTryOn.itemId
	local bundleInfo = getBundleInfoFromState(newState, bundleId)

	if curTryOn.itemId ~= oldTryOn.itemId then
		if curTryOn.itemId then
			self.needsToEquipBundleTryOn = true
		else
			self.needsToEquipBundleTryOn = false
		end
	end

	if not self.needsToEquipBundleTryOn then
		return
	end

	if not bundleInfo then
		if not isBundleInfoFetching(newState, bundleId) then
			self.store:dispatch(FetchBundleInfo({ bundleId }))
		end
		return
	end

	local userOutfitId = getUserOutfitIdForBundle(bundleInfo)
	local outfitInfo = getOutfits(newState)[userOutfitId]
	if not outfitInfo then
		if not isOutfitInfoFetching(newState, userOutfitId) then
			self.store:dispatch(GetOutfit(userOutfitId))
		end
		return
	end

	if self.needsToEquipBundleTryOn then
		self.needsToEquipBundleTryOn = false
		self:equipOutfit(outfitInfo)
	end
end

function CharacterManager:update(newState, oldState)
	local curEquipped = getEquippedAssets(newState)
	local oldEquipped = getEquippedAssets(oldState)

	local curTryOn, oldTryOn
	if IsLuaCatalogPageEnabled then
		curTryOn = newState.AvatarExperience.AvatarScene.TryOn.SelectedItem
		oldTryOn = oldState.AvatarExperience.AvatarScene.TryOn.SelectedItem
	end

	local updateScales = getAvatarScales(newState) ~= getAvatarScales(oldState)
	local updateBodyColors = getBodyColors(newState) ~= getBodyColors(oldState)

	local updateAssets = curEquipped ~= oldEquipped
	local updateTryOn = curTryOn ~= oldTryOn

	local updateEmotes = newState.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo
		~= oldState.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo

	local applyHumanoidDescription = false
	if updateAssets or updateTryOn or updateScales or updateBodyColors or updateEmotes then
		self.humanoidDescription = humanoidDescriptionFromState(self.store:getState(), --[[includeTryOn =]] true)
		applyHumanoidDescription = true
	end

	self.bodyColorManager:manageDefaultClothing(curEquipped, updateBodyColors)

	if IsLuaCatalogPageEnabled then
		if curTryOn.itemType == CatalogConstants.ItemType.Bundle then
			self:checkShouldTryOnBundle(newState, oldState)
		end
	end

	if applyHumanoidDescription then
		local incrementCharacterModelVersion = updateAssets or updateScales or updateBodyColors
		self:applyHumanoidDescription(incrementCharacterModelVersion, updateTryOn)
	end

	if updateAssets or updateTryOn then
		-- Handle gear specific code manually because HumanoidDescription does not support it.
		local equippedGearTryOn = false
		local equippedGear = curEquipped and curEquipped[AvatarExperienceConstants.AssetTypes.Gear]
			and curEquipped[AvatarExperienceConstants.AssetTypes.Gear][1] or nil
		local oldEquippedGear = oldEquipped and oldEquipped[AvatarExperienceConstants.AssetTypes.Gear]
			and oldEquipped[AvatarExperienceConstants.AssetTypes.Gear][1] or nil

		if IsLuaCatalogPageEnabled and updateTryOn then
			if curTryOn.itemType == CatalogConstants.ItemType.Asset and
				curTryOn.itemSubType == AvatarExperienceConstants.AssetTypes.Gear then
				equippedGearTryOn = true
				if equippedGear then
					self:unequipTool()
					self.store:dispatch(IncrementTryOnCharacterModelVersion())
				end
				self:loadAndEquipTool(curTryOn.itemId, curTryOn.itemSubType, --[[ isTryOn = ]] true)
			end

			if wasTryingOnTool(oldState, oldTryOn) then
				if not equippedGearTryOn then
					self:unequipTool()
					self.store:dispatch(IncrementTryOnCharacterModelVersion())
					if equippedGear then
						self:loadAndEquipTool(equippedGear, AvatarExperienceConstants.AssetTypes.Gear)
					end
				end
			end
		end

		if equippedGear ~= oldEquippedGear then
			if oldEquippedGear then
				self:unequipTool()
				self.store:dispatch(IncrementCharacterModelVersion())
			end

			if equippedGear and not equippedGearTryOn then
				self:loadAndEquipTool(equippedGear, AvatarExperienceConstants.AssetTypes.Gear)
			end
		end
	end

	local newAvatarType = getAvatarType(newState)
	local oldAvatarType = getAvatarType(oldState)

	if newAvatarType ~= oldAvatarType then
		self:switchAvatarType(newAvatarType)
	end
end

function CharacterManager:equipOutfit(outfitDetails)
	local humanoidDescription = createHumanoidDescriptionFromOutfit(outfitDetails)

	self:applyHumanoidDescription(false, true, humanoidDescription)

	local toolAssetId = getToolAssetIdFromOutfitDetails(outfitDetails)
	if toolAssetId then
		self:loadAndEquipTool(toolAssetId, AvatarExperienceConstants.AssetTypes.Gear, true)
	end
end

function CharacterManager:loadAndEquipTool(assetId, assetTypeId, isTryOn)
	if UseTempHacks then
		return
	end

	spawn(function()
		local assetModel = nil
		local _, err = pcall(function()
			assetModel = InsertService:LoadAsset(assetId)
		end)
		if self.destroyed then
			return
		end

		if err or (not assetModel) then
			warn("Error loading tool in CharacterManager: " ..err)
			return
		end

		local state = self.store:getState()
		local equippedAssets = getEquippedAssets(state)

		-- Check to see the item is still equipped
		local toolStillEquipped

		if isTryOn then
			local tryOnItemInfo = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

			if tryOnItemInfo.itemType == CatalogConstants.ItemType.Bundle then
				toolStillEquipped = assetId == getToolIdForBundle(state, tryOnItemInfo.itemId)
			else
				toolStillEquipped = assetId == tryOnItemInfo.itemId
			end
		else
			toolStillEquipped = AvatarEditorUtils.isAssetEquipped(assetId, assetTypeId, equippedAssets)
		end

		if not toolStillEquipped then
			warn("Asset unequipped without getting a chance to get equipped.")
			assetModel:Destroy()
			return
		end

		local _, toolModel = next(assetModel:GetChildren())
		if toolModel and isTool(toolModel) then
			disableScripts(toolModel)
			self:equipTool(toolModel)
		end

		if not isTryOn then
			self.store:dispatch(IncrementCharacterModelVersion())
		else
			self.store:dispatch(IncrementTryOnCharacterModelVersion())
		end
	end)
end

function CharacterManager:equipTool(toolModel)
	self.equippedToolModel = toolModel
	self.currentCharacter.Humanoid:EquipTool(toolModel)
	self.animationManager:setToolAnimation(true)
end

function CharacterManager:unequipTool()
	local tool = self.equippedToolModel
	if tool then
		self.equippedToolModel = nil
		self.animationManager:setToolAnimation(false)
		self.currentCharacter.Humanoid:UnequipTools()
		tool.Parent = nil
		tool:Destroy()
	end
end

function CharacterManager:manageDefaultClothing(shirtAssetId, pantsAssetId)
	local state = self.store:getState()
	local tryOnItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

	if shirtAssetId and not (tryOnItem.itemType == CatalogConstants.ItemType.Asset
		and tryOnItem.itemSubType == AvatarExperienceConstants.AssetTypes.Shirt) then
		self.humanoidDescription[HumanoidDescriptionIdToName[AvatarExperienceConstants.AssetTypes.Shirt]] = shirtAssetId
	end

	if pantsAssetId and not (tryOnItem.itemType == CatalogConstants.ItemType.Asset
		and tryOnItem.itemSubType == AvatarExperienceConstants.AssetTypes.Pants) then
		self.humanoidDescription[HumanoidDescriptionIdToName[AvatarExperienceConstants.AssetTypes.Pants]] = pantsAssetId
	end
end

function CharacterManager:switchAvatarType(newType)
	local currentCharacter, oldCharacter
	if newType == Constants.AvatarType.R6 then
		currentCharacter = self.r6
		oldCharacter = self.r15
	else
		currentCharacter = self.r15
		oldCharacter = self.r6
	end
	currentCharacter.Parent = self.characterRoot
	oldCharacter.Parent = ReplicatedStorage

	self.currentCharacter = currentCharacter
	self.store:dispatch(SetCurrentCharacter(self.currentCharacter))

	oldCharacter.Humanoid:UnequipTools()

	-- New model needs to have the same rotation as the old model.
	local _, _, _, R00, R01, R02, R10, R11, R12, R20, R21, R22 = oldCharacter.HumanoidRootPart.CFrame:components()
	local currentCFrameP = self.currentCharacter.HumanoidRootPart.CFrame.p
	self.currentCharacter.HumanoidRootPart.CFrame = CFrame.new(currentCFrameP.X, currentCFrameP.Y, currentCFrameP.Z,
		R00, R01, R02, R10, R11, R12, R20, R21, R22)

	self:applyHumanoidDescription(true)

	if self.equippedToolModel then
		self:equipTool(self.equippedToolModel)
	end
end

function CharacterManager:adjustHeightToStandOnPlatform(character)
	local hrp = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local heightBonus = hrp.Size.y * 0.5 + humanoid.HipHeight + 10000
	local _,_,_, r0,r1,r2, r3,r4,r5, r6,r7,r8 = hrp.CFrame:components()

	hrp.CFrame = CFrame.new(self.characterCFrame.x, heightBonus, self.characterCFrame.z,
		r0,r1,r2, r3,r4,r5, r6,r7,r8)
end

function CharacterManager:stop()
	self.r6.Parent = ReplicatedStorage
	self.r15.Parent = ReplicatedStorage

	local equippedAssets = getEquippedAssets(self.store:getState())
	local tool = equippedAssets and equippedAssets[AvatarExperienceConstants.AssetTypes.Gear]
	if tool and tool[1] then
		self:loadAndEquipTool(tool[1], AvatarExperienceConstants.AssetTypes.Gear)
	end

	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}

	self.animationManager:stop()
	self.bodyColorManager:stop()
end

function CharacterManager:onDestroy()
	self.r6:Destroy()
	self.r15:Destroy()
	self.humanoidDescription:Destroy()
	self.characterRoot:Destroy()
	self.destroyed = true

	self.animationManager:onDestroy()
	self.bodyColorManager:onDestroy()
end

return CharacterManager
