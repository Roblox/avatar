local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ContentProvider = game:GetService("ContentProvider")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Logging = require(Modules.Packages.Logging)

local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local PlayingSwimAnimation = require(Modules.AvatarExperience.Common.Actions.PlayingSwimAnimation)

local AvatarEvents = ReplicatedStorage:WaitForChild("AvatarEvents")
local LoadAnimationServer = AvatarEvents.LoadAnimationServer

local UseTempHacks = require(Modules.Config.UseTempHacks)

local FFlagAvatarEditorEmotesSupport = true
local FFlagCatalogPageEnabled = true
local FFlagLuaAppEnableAERedesign = function() return true end

local AnimationManager = {}
AnimationManager.__index = AnimationManager

local DefaultAnimations = {
	R15 = {
		TOOL = 507768375,
	},
	R6 = {
		CLIMB = 180436334,
		FALL = 180436148,
		IDLE = 180435571,
		IDLE_LOOK_AROUND = 180435792,
		JUMP = 125750702,
		RUN = 180426354,
		SIT = 178130996,
		TOOL_NONE = 182393478,
		WALK = 180426354,
		TOOL = 182393478,
	}
}

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

local function getEmotesInfo(state)
	if FFlagLuaAppEnableAERedesign() then
		local slotInfo = state.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo
		local selectedSlot = state.AvatarExperience.AvatarEditor.EquippedEmotes.selectedSlot

		return slotInfo, selectedSlot
	else
		local OLD_EMOTES_PAGE_INDEX = 5

		local slotInfo = state.AEAppReducer.AEEquippedEmotes.slotInfo
		local selectedSlot = state.AEAppReducer.AECategory.AETabsInfo[OLD_EMOTES_PAGE_INDEX]

		return slotInfo, selectedSlot
	end
end

local function isSwimAnimation(animationTrack)
	if animationTrack.Parent.Name == "swim" then
		return true
	else
		return false
	end
end

local function assetTypeIdIsAnimation(assetTypeId)
	local assetCategory = AvatarExperienceConstants.AssetTypeIdToCategory[assetTypeId]
	return assetCategory == AvatarExperienceConstants.AssetCategories.Animation
end

local function createStringValue(parent, name)
	local stringValue = Instance.new("StringValue", parent)
	stringValue.Name = name
	return stringValue
end

local function createAnimation(parent, animationName, assetId)
	local animation = Instance.new("Animation", parent)
	animation.AnimationId = "http://www.roblox.com/asset/?id=" ..assetId
	animation.Name = animationName
end

local function createR6AnimationFolder()
	local folder = Instance.new("Folder")
	createAnimation(createStringValue(folder, "climb"), "ClimbAnim", DefaultAnimations.R6.CLIMB)
	createAnimation(createStringValue(folder, "fall"), "FallAnim", DefaultAnimations.R6.FALL)
	createAnimation(createStringValue(folder, "idle"), "Animation1", DefaultAnimations.R6.IDLE)
	createAnimation(folder.idle, "Animation2", DefaultAnimations.R6.IDLE_LOOK_AROUND)
	createAnimation(createStringValue(folder, "jump"), "JumpAnim", DefaultAnimations.R6.JUMP)
	createAnimation(createStringValue(folder, "run"), "RunAnim", DefaultAnimations.R6.RUN)
	createAnimation(createStringValue(folder, "sit"), "SitAnim", DefaultAnimations.R6.SIT)
	createAnimation(createStringValue(folder, "toolnone"), "ToolNoneAnim", DefaultAnimations.R6.TOOL_NONE)
	createAnimation(createStringValue(folder, "walk"), "WalkAnim", DefaultAnimations.R6.WALK)
	createAnimation(folder, "Tool", DefaultAnimations.R6.TOOL)
	return folder
end

function AnimationManager.new(store, characterManager)
	local self = {}
	setmetatable(self, AnimationManager)

	self.store = store

	self.animationConnections = {}
	self.animationData = {}

	self.currentAnimationPreview = nil
	self.toolHoldAnimationTrack = nil

	self.currentId = 1
	self.loopId = 0

	self.indexOffset = false
	self.initialized = false

	self.lookAroundStopConnection = nil
	self.lookAroundLoopConnection = nil

	--[[
	local r6Animations = createR6AnimationFolder()
	local r15Animations = StarterPlayer.HumanoidDefaultAssets.HumanoidDefaultAnimations
	createAnimation(r15Animations, "Tool", DefaultAnimations.R15.TOOL)
	r6Animations.Name = "Animations"
	r15Animations.Name = "Animations"
	r6Animations.Parent = characterManager.r6
	r15Animations.Parent = characterManager.r15
	--]]

	return self
end

function AnimationManager:getPage(state)
	state = state or self.store:getState()
	return AvatarExperienceUtils.getPageFromState(state)
end

function AnimationManager:start()
	self.initialized = true
	self.indexOffset = false

	self.storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)

	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	if not currentCharacter then
		Logging.warn("Tried to start AnimationManager without a character!")
		return
	end

	spawn(function()
		local toolEquipped = self:isToolEquipped()

		if toolEquipped then
			self:setToolAnimation(true)
		end

		local page = self:getPage()

		-- Manager may have stopped while initilizing.
		if not page then
			return
		end

		if page.PageType == AvatarExperienceConstants.PageType.Animation then
			self:playAnimation(self:getEquippedOrDefaultAnim(page.AssetTypeId), true)
		elseif page.PageType == AvatarExperienceConstants.PageType.Emotes then
			self:playAnimation(self:getEquippedEmoteOrDefaultAnim(), true)
		else
			self:playAnimation(self:getEquippedOrDefaultAnim(AvatarExperienceConstants.AssetTypes.IdleAnim), true)
		end
	end)
end

function AnimationManager:stopLastAnimation()
	if self.lookAroundTrack then
		self.lookAroundTrack:Stop()
	end

	if self.animationData[self.currentId] and self.animationData[self.currentId].currentTrack then
		if self.animationData[self.currentId].currentTrack.IsPlaying then
			self.animationData[self.currentId].currentTrack:Stop()
		end
		self.animationData[self.currentId].currentTrack:Destroy()
	end
	self.animationData[self.currentId] = nil
end

function AnimationManager:getRandomTrack(options, totalWeight)
	local chosenValue = math.random() * totalWeight
	for animation, weight in next, options do
		if chosenValue <= weight then
			return animation
		else
			chosenValue = chosenValue - weight
		end
	end
end

--[[
	Given animation assets, load and play an animation into the humanoid
	forceHeaviestAnim: If true this will never play the look around animation first.
	override: Force a specific animation to play, such as alternating between multiple ones.
]]
function AnimationManager:playAnimation(animationAssets, forceHeaviestAnim, override)
	if not animationAssets then
		return
	end

	if #animationAssets == 0 then
		return
	end

	self:stopLastAnimation()
	self:stopAllAnimationConnections() -- Disconnect previous animation connection

	self.currentId = self.currentId + 1
	self.animationData[self.currentId] = {}

	local id = self.currentId -- This id will manage animations in this thread.
	local fadeInTime = 0.1
	self.animationData[id].currentAnimIndex = 1

	if self.indexOffset then
		local offsetAdded = 0

		while offsetAdded < #animationAssets do
			self.animationData[id].currentAnimIndex = self.animationData[id].currentAnimIndex % #animationAssets + 1
			offsetAdded = offsetAdded + 1

			-- Find an offset that has valid animations that we can play
			local currentAnims = animationAssets[self.animationData[id].currentAnimIndex]:GetChildren()
			local options = self:getWeightedAnimations(currentAnims)

			if next(options) then
				break
			end
		end
	end

	-- Get the animation to play (light/heavy animation)
	local possibleAnims = animationAssets[self.animationData[id].currentAnimIndex]:GetChildren()
	local options, totalWeight = self:getWeightedAnimations(possibleAnims)
	local firstAnim, firstWeight = next(options)

	if not firstAnim then
		return nil
	end

	local animation

	if forceHeaviestAnim then
		local heaviestAnimation, heaviestWeight = firstAnim, firstWeight
		for animation, weight in pairs(options) do
			if weight > heaviestWeight then
				heaviestAnimation, heaviestWeight = animation, weight
			end
		end

		animation = heaviestAnimation
	else
		animation = self:getRandomTrack(options, totalWeight)
	end

	if override ~= nil then
		animation = override
	end

	local animationTrack = self:humanoidLoadAnimation(animation)
	animationTrack.Looped = true
	animationTrack:Play(fadeInTime)

	self.animationData[id].currentTrack = animationTrack

	local oldPlayingSwimAnimation = self.store:getState().AvatarExperience.AvatarScene.Character.PlayingSwimAnimation
	local currentPlayingSwimAnimation = isSwimAnimation(animation)
	if oldPlayingSwimAnimation ~= currentPlayingSwimAnimation then
		self.store:dispatch(PlayingSwimAnimation(currentPlayingSwimAnimation))
	end

	self.animationConnections[#self.animationConnections + 1] = animationTrack.DidLoop:Connect(function()
		self.loopId = self.loopId + 1
		local possibleAnims = animationAssets[self.animationData[id].currentAnimIndex]:GetChildren()
		local options, totalWeight = self:getWeightedAnimations(possibleAnims)
		local newAnim = self:getRandomTrack(options, totalWeight)
		local changedOffset = false

		-- If there are multiple animations, switch between them.
		if self.loopId % 4 == 0 then
			if self.indexOffset then
				self.indexOffset = false
			else
				self.indexOffset = true
			end

			changedOffset = true
		end

		-- Check if animation should be switched to a different weight one.
		if changedOffset or newAnim ~= animationTrack then
			self:playAnimation(animationAssets, false, newAnim)
		end
	end)
end

-- Plays the "Look Around" animation, which is the lightest idle animation.
function AnimationManager:playLookAround(animationAssets, id)
	local equippedAssets = getEquippedAssets(self.store:getState())
	local assetId = equippedAssets[AvatarExperienceConstants.AssetTypes.IdleAnim]

	local assets = {}
	if assetId and assetId[1] then
		assets = self:loadAnimationObjects(assetId[1])
		if not assets then
			-- No look around, nothing to do
			return
		end
	else
		local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
		table.insert(assets, currentCharacter.Animate.idle)
	end

	-- Look around animation is the lightest idle animation.
	local options, _ = self:getWeightedAnimations(assets[1]:GetChildren())
	local lightestAnimation, lightestWeight
	for animation, weight in next, options do
		if lightestAnimation == nil or weight < lightestWeight then
			lightestAnimation, lightestWeight = animation, weight
		end
	end

	if self.lookAroundTrack then
		self.lookAroundTrack:Stop()
	end

	ContentProvider:PreloadAsync(animationAssets) -- Load the look around animation so it will play on first run.
	if lightestAnimation then
		self.lookAroundTrack = self:humanoidLoadAnimation(lightestAnimation)
		self:stopAllAnimationTracks()
		self.lookAroundTrack:Play(0)

		self.lookAroundStopConnection = self.lookAroundTrack.Stopped:Connect(function()
			self.lookAroundStopConnection:Disconnect()
			self.lookAroundTrack:Destroy()
		end)

		self.lookAroundLoopConnection = self.lookAroundTrack.DidLoop:Connect(function()
			self:playAnimation(animationAssets, true)
			self.lookAroundLoopConnection:Disconnect()
			self.lookAroundTrack:Destroy()
		end)
	end
end

-- Given possible animations, get the weight of each as well as the total weight.
function AnimationManager:getWeightedAnimations(possible)
	local options, totalWeight = {}, 0

	for _, animation in next, possible do
		local weight = animation:FindFirstChild("Weight") and animation.Weight.Value or 1

		-- Don't include single keyframe thumbnail pose
		if weight > 0 then
			options[animation] = weight
			totalWeight = totalWeight + weight
		end
	end

	return options, totalWeight
end

-- Load an animation into the humanoid.
function AnimationManager:humanoidLoadAnimation(animation)
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	local humanoid = currentCharacter.Humanoid
	return humanoid:LoadAnimation(animation)
end

-- Return the default animation from the character model.
function AnimationManager:getDefaultAnimationAssets(assetTypeId, currentCharacter)
	local avatarType = getAvatarType(self.store:getState())
	local anims = {}

	if assetTypeId == AvatarExperienceConstants.AssetTypes.ClimbAnim then
		table.insert(anims, currentCharacter.Animate.climb)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.FallAnim then
		table.insert(anims, currentCharacter.Animate.fall)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.IdleAnim then
		table.insert(anims, currentCharacter.Animate.idle)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.JumpAnim then
		table.insert(anims, currentCharacter.Animate.jump)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.RunAnim then
		table.insert(anims, currentCharacter.Animate.run)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.WalkAnim then
		table.insert(anims, currentCharacter.Animate.walk)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.Emote then
		table.insert(anims, currentCharacter.Animate.idle)
	elseif assetTypeId == AvatarExperienceConstants.AssetTypes.SwimAnim then
		if avatarType == AvatarEditorConstants.AvatarType.R15 then
			table.insert(anims, currentCharacter.Animate.swim)
			table.insert(anims, currentCharacter.Animate.swimidle)
		else
			local swimAnim = currentCharacter.Animate.run:Clone()
			swimAnim.Name = 'swim'

			table.insert(anims, swimAnim)
		end
	end

	return anims
end

function AnimationManager:getEquippedOrDefaultAnim(animIdType, currentCategoryIndex)
	local avatarType = getAvatarType(self.store:getState())
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	local equippedAssets = getEquippedAssets(self.store:getState())

	local anim = equippedAssets[animIdType]

	if anim and anim[1] and avatarType == AvatarEditorConstants.AvatarType.R15 then
		return self:loadAnimationObjects(anim[1])
	else
		return self:getDefaultAnimationAssets(animIdType, currentCharacter)
	end
end

function AnimationManager:getEquippedEmoteOrDefaultAnim()
	local slotInfo, selectedSlot = getEmotesInfo(self.store:getState())

	local emoteInfo = slotInfo[selectedSlot]
	if emoteInfo then
		return self:loadAnimationObjects(emoteInfo.assetId)
	end

	return self:getEquippedOrDefaultAnim(AvatarExperienceConstants.AssetTypes.IdleAnim)
end

-- Given an animation id, get the AnimationTrack.
function AnimationManager:loadAnimationObjects(assetId)
	if not assetId then
		return nil
	end

	local animationModel = nil
	local _, err = pcall(function()
		if UseTempHacks then
			animationModel = LoadAnimationServer:InvokeServer(assetId):Clone()
		else
			animationModel = InsertService:LoadAsset(assetId)
		end
	end)

	if err or (not animationModel) then
		warn(err)
		return
	end

	if not animationModel then
		return nil
	end

	local r15Anim = animationModel:FindFirstChild("R15Anim")
	if r15Anim then
		return r15Anim:GetChildren() -- Animation objects
	end

	local emoteAnims = {}
	for _, child in ipairs(animationModel:GetChildren()) do
		if child:IsA("Animation") then
			local stringValue = Instance.new("StringValue")
			stringValue.Name = child.Name
			child.Parent = stringValue

			emoteAnims[#emoteAnims + 1] = stringValue
		end
	end

	if #emoteAnims > 0 then
		return emoteAnims
	end

	return nil
end

function AnimationManager:stopAllAnimationTracks()
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	local humanoid = currentCharacter.Humanoid

	for _, animation in next, humanoid:GetPlayingAnimationTracks() do
		if animation ~= self.toolHoldAnimationTrack then
			animation:Stop()
		end
	end
end

function AnimationManager:isToolEquipped(state)
	state = state or self.store:getState()

	local curEquipped = getEquippedAssets(state)
	local gearEquipped = curEquipped[AvatarExperienceConstants.AssetTypes.Gear]

	if gearEquipped then
		if gearEquipped[1] then
			return true
		end
	end

	return false
end

function AnimationManager:setToolAnimation(toolEquipped)
	if not self.initialized then
		return
	end

	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter

	if self.toolHoldAnimationTrack then
		self.toolHoldAnimationTrack:Stop()
		self.toolHoldAnimationTrack = nil
	end

	if toolEquipped then
		local animationsFolder = currentCharacter.Animations
		if not animationsFolder then
			return
		end

		local toolHoldAnimationObject = animationsFolder.Tool
		if not toolHoldAnimationObject then
			return
		end

		self.toolHoldAnimationTrack = self:humanoidLoadAnimation(toolHoldAnimationObject)
		self.toolHoldAnimationTrack:Play(0)
	end
end

function AnimationManager:getAnimationFromPage(page)
	if page.PageType == AvatarExperienceConstants.PageType.Emotes then
		return self:getEquippedEmoteOrDefaultAnim()
	elseif page.PageType == AvatarExperienceConstants.PageType.Animation then
		return self:getEquippedOrDefaultAnim(page.AssetTypeId)
	else
		return self:getEquippedOrDefaultAnim(AvatarExperienceConstants.AssetTypes.IdleAnim)
	end
end

-- returns items that are in first table and missing from the second one.
local function findMissingIds(firstTable, secondTable)
	local missingIds = {}
	if (firstTable == nil) or (not next(firstTable)) then
		return missingIds
	end
	for _, assetId in ipairs(firstTable) do
		local found = false
		if secondTable and next(secondTable) then
			for _, id in ipairs(secondTable) do
				if id == assetId then
					found = true
					break
				end
			end
		end
		if not found then
			table.insert(missingIds, assetId)
		end
	end
	return missingIds
end

-- equippedIds, unequippedIds, newState, oldState
function AnimationManager:update(newState, oldState)
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	if not currentCharacter then
		return
	end

	local curEquipped = getEquippedAssets(newState)
	local oldEquipped = getEquippedAssets(oldState)
	local avatarType = getAvatarType(newState)

	local curTryOn, oldTryOn
	local curAnimationPreview, oldAnimationPreview

	if FFlagCatalogPageEnabled then
		curTryOn = newState.AvatarExperience.AvatarScene.TryOn.SelectedItem
		oldTryOn = oldState.AvatarExperience.AvatarScene.TryOn.SelectedItem

		curAnimationPreview = newState.AvatarExperience.AvatarScene.TryOn.AnimationPreview
		oldAnimationPreview = oldState.AvatarExperience.AvatarScene.TryOn.AnimationPreview
	end

	local currentPage = self:getPage(newState)
	local oldPage = self:getPage(oldState)

	local changedTab = currentPage ~= oldPage

	local isAnimationPage = currentPage.PageType == AvatarExperienceConstants.PageType.Animation
	local isEmotesPage = currentPage.PageType == AvatarExperienceConstants.PageType.Emotes

	local usingR15 = avatarType == AvatarEditorConstants.AvatarType.R15
	local canPlayAnimation = (isAnimationPage or isEmotesPage) and usingR15

	local characterRoot = game.Workspace.CharacterRoot
	local inspectR15 = 	characterRoot:FindFirstChild("CharacterR15") ~= nil

	local didEquipItem, didUnequipAnimation, isAnimation, rebuiltCharacter = false, false, false, false
	local idleAnim = nil
	local equipped = nil

	if avatarType ~= getAvatarType(oldState) then
		rebuiltCharacter = true

		local toolEquipped = self:isToolEquipped(newState)
		self:setToolAnimation(toolEquipped)
	end

	local equippedIdsWithAssetType = {}
	local unequippedIdsWithAssetType = {}

	-- Check if any equipped/unequipped assets trigger an animation to be played.
	for assetTypeId, curEquippedIds in pairs(curEquipped) do
		local prevEquippedIds = oldEquipped and oldEquipped[assetTypeId] or {}
		equippedIdsWithAssetType[assetTypeId] = findMissingIds(curEquippedIds, prevEquippedIds)
		unequippedIdsWithAssetType[assetTypeId] = findMissingIds(prevEquippedIds, curEquippedIds)

		for _, assetId in ipairs(equippedIdsWithAssetType[assetTypeId]) do
			if assetTypeIdIsAnimation(assetTypeId) then
				isAnimation = true
				equipped = assetId
				-- If an outfit had a new idle animation, keep the id to play it.
				if assetTypeId == AvatarExperienceConstants.AssetTypes.IdleAnim then
					idleAnim = assetId
				end
			else
				didEquipItem = true
			end
		end

		if #unequippedIdsWithAssetType[assetTypeId] > 0 and assetTypeIdIsAnimation(assetTypeId) then
			didUnequipAnimation = true
		end
	end

	local changedSelectedEmoteSlot = false
	-- Check Emotes separately which are located in their own reducer.
	if FFlagAvatarEditorEmotesSupport then
		local curEmotes, curSelectedSlot = getEmotesInfo(newState)
		local oldEmotes, oldSelectedSlot = getEmotesInfo(oldState)
		changedSelectedEmoteSlot = curSelectedSlot ~= oldSelectedSlot

		if curEmotes ~= oldEmotes then
			for slot, emoteInfo in pairs(curEmotes) do
				local oldEmoteInfo = oldEmotes[slot]
				if not oldEmoteInfo or oldEmoteInfo.assetId ~= emoteInfo.assetId then
					isAnimation = true
					equipped = emoteInfo.assetId
				end
			end

			for slot, _ in pairs(oldEmotes) do
				if not curEmotes[slot] then
					didUnequipAnimation = true
				end
			end
		end
	end

	if curTryOn ~= oldTryOn then
		local isAssetCur = curTryOn.itemType == CatalogConstants.ItemType.Asset
		local isAssetOld = oldTryOn.itemType == CatalogConstants.ItemType.Asset
		local isAnimationCur = isAssetCur and assetTypeIdIsAnimation(curTryOn.itemSubType)
		local isAnimationOld = isAssetOld and assetTypeIdIsAnimation(oldTryOn.itemSubType)

		if not isAnimationCur and isAnimationOld then
			didUnequipAnimation = true
		elseif isAnimationCur then
			canPlayAnimation = true
			didEquipItem = true
			equipped = curTryOn.itemId
			isAnimation = true
		end
	end

	if curAnimationPreview ~= oldAnimationPreview then
		if not curAnimationPreview then
			didUnequipAnimation = true
		else
			canPlayAnimation = true
			didEquipItem = true
			equipped = curAnimationPreview
			isAnimation = true
		end
	end

	coroutine.wrap(function()
		if isAnimation and canPlayAnimation then
			self.indexOffset = false
			self:playAnimation(self:loadAnimationObjects(equipped), true)
		elseif didEquipItem or rebuiltCharacter then
			-- If an animation is currently equipped, then preview it
			local assets = self:getAnimationFromPage(currentPage)
			self.indexOffset = false

			if currentPage.PageType == AvatarExperienceConstants.PageType.Animation then
				self:playAnimation(assets, true)
			else
				self:playLookAround(assets, self.currentId)
			end
		elseif changedTab or changedSelectedEmoteSlot or didUnequipAnimation then
			self.indexOffset = false

			local animAssets = self:getAnimationFromPage(currentPage)
			self:playAnimation(animAssets, true)
		elseif idleAnim then
			self:playAnimation(self:loadAnimationObjects(idleAnim), true)
		end
	end)()
end

function AnimationManager:stopAllAnimationConnections()
	for _, connection in ipairs(self.animationConnections) do
		connection:Disconnect()
	end
	self.animationConnections = {}
end

function AnimationManager:stop()
	self:stopAllAnimationConnections()

	if self.storeChangedConnection then
		self.storeChangedConnection:disconnect()
		self.storeChangedConnection = nil
	end
end

function AnimationManager:onDestroy()
end

return AnimationManager
