local AssetService = game:GetService("AssetService")
local AvatarCreationService = game:GetService("AvatarCreationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local AccessoryEditModel = require(Modules:WaitForChild("AccessoryEditModel"))
local Utils = require(Modules:WaitForChild("Utils"))
local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local EditableManager = require(Modules:WaitForChild("EditableManager"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local MakeupHeads = require(Config:WaitForChild("MakeupHeads"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MakeupProjectionUtils = require(MeshManipulation:WaitForChild("MakeupProjectionUtils"))

local ServerModules = ServerStorage:WaitForChild("Modules")
local ActionQueue = require(ServerModules:WaitForChild("ActionQueue"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")
local ShowMessageEvent = Remotes:WaitForChild("ShowMessageEvent")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")
local ResetCompleteEvent = Remotes:WaitForChild("ResetCompleteEvent")
local GetCreationPriceFunction = Remotes:WaitForChild("GetCreationPriceFunction")

local SetAccessoryEditModelEvent = Remotes:FindFirstChild("SetAccessoryEditModelEvent")
if not SetAccessoryEditModelEvent then
	SetAccessoryEditModelEvent = Instance.new("RemoteEvent")
	SetAccessoryEditModelEvent.Name = "SetAccessoryEditModelEvent"
	SetAccessoryEditModelEvent.Parent = Remotes
end

local ACCESSORY_TO_AVATAR_ASSET_TYPE = {
	[Enum.AccessoryType.TShirt] = Enum.AvatarAssetType.TShirtAccessory,
	[Enum.AccessoryType.Hat] = Enum.AvatarAssetType.Hat,
	[Enum.AccessoryType.Jacket] = Enum.AvatarAssetType.JacketAccessory,
	[Enum.AccessoryType.Pants] = Enum.AvatarAssetType.PantsAccessory,
	[Enum.AccessoryType.Shirt] = Enum.AvatarAssetType.ShirtAccessory,
	[Enum.AccessoryType.DressSkirt] = Enum.AvatarAssetType.DressSkirtAccessory,
	[Enum.AccessoryType.Sweater] = Enum.AvatarAssetType.SweaterAccessory,
	[Enum.AccessoryType.Shorts] = Enum.AvatarAssetType.ShortsAccessory,
	[Enum.AccessoryType.Back] = Enum.AvatarAssetType.BackAccessory,
	[Enum.AccessoryType.Face] = Enum.AvatarAssetType.FaceAccessory,
	[Enum.AccessoryType.Neck] = Enum.AvatarAssetType.NeckAccessory,
	[Enum.AccessoryType.Waist] = Enum.AvatarAssetType.WaistAccessory,
	[Enum.AccessoryType.Front] = Enum.AvatarAssetType.FrontAccessory,
	[Enum.AccessoryType.Hair] = Enum.AvatarAssetType.HairAccessory,
}

-- Maps a layer group's makeup asset type (Constants.MAKEUP_ASSET_TYPES) to the
-- corresponding Enum.AvatarAssetType for PromptCreateMakeupAsync.
local MAKEUP_ASSET_TYPE_TO_AVATAR_ASSET_TYPE = {
	[Constants.MAKEUP_ASSET_TYPES.Face] = Enum.AvatarAssetType.FaceMakeup,
	[Constants.MAKEUP_ASSET_TYPES.Eyes] = Enum.AvatarAssetType.EyeMakeup,
	[Constants.MAKEUP_ASSET_TYPES.Lips] = Enum.AvatarAssetType.LipMakeup,
}

-- PromptCreateMakeupAsync accepts between this many makeup asset entries.
local MAKEUP_MIN_ASSETS = 2
local MAKEUP_MAX_ASSETS = 6

local PlayerActionQueueMap = {}
local PlayerEditableManagerMap = {}
local PlayerAccessoryRecordMap = {}
local PlayerAccessoryBuildMap = {}

local ACCESSORY_CATEGORIES = {
	Constants.MAKEUP_ASSET_TYPES.Eyebrows,
	Constants.MAKEUP_ASSET_TYPES.Eyelashes,
}

local function GetTextureResolution(resolutionIndex): Vector2?
	if type(resolutionIndex) ~= "number" or resolutionIndex % 1 ~= 0 then
		return nil
	end
	return Constants.TEXTURE_RESOLUTION_STEPS[resolutionIndex]
end

local function GetServerModelStorage()
	local serverModelStorage = ServerStorage:FindFirstChild("ServerModelStorage")
	if not serverModelStorage then
		serverModelStorage = Instance.new("Folder")
		serverModelStorage.Name = "ServerModelStorage"
		serverModelStorage.Parent = ServerStorage
	end

	return serverModelStorage
end

local function DestroyAccessoryRecord(record)
	if not record then
		return
	end

	task.spawn(function()
		record.actionQueue:Destroy()
		if record.modelInfo then
			record.modelInfo:Destroy()
		end
	end)
end

local function ResetPlayerAccessoryModels(player)
	local accessoryRecords = PlayerAccessoryRecordMap[player]
	PlayerAccessoryRecordMap[player] = nil
	if not accessoryRecords then
		return
	end

	for _, record in accessoryRecords do
		DestroyAccessoryRecord(record)
	end
end

local function ResetPlayerModel(player)
	local actionQueue = PlayerActionQueueMap[player]
	PlayerActionQueueMap[player] = nil

	if actionQueue then
		local playerEditModel: ModelInfo.ModelInfoClass? = actionQueue:GetPlayerModelInfo()
		if playerEditModel then
			playerEditModel:Destroy()
		end
	end

	ResetPlayerAccessoryModels(player)

	local editableManager = PlayerEditableManagerMap[player]
	if editableManager then
		editableManager:Destroy()
		PlayerEditableManagerMap[player] = nil
	end

	ResetCompleteEvent:FireClient(player)
end

local function SetupPlayerEditModel(player, blankName, resolutionIndex)
	local blankData = Utils.GetBlankDataByName(blankName)
	if not blankData then
		error("BlankData not found for blankName " .. blankName)
	end
	local textureResolution = GetTextureResolution(resolutionIndex)
	if not textureResolution then
		return
	end
	blankData = table.clone(blankData)
	blankData.textureResolution = textureResolution

	if PlayerActionQueueMap[player] then
		warn("PlayerActionQueue already exists for player " .. player.Name)
		ResetPlayerModel(player)
	end
	local actionQueue = ActionQueue.new(player)
	PlayerActionQueueMap[player] = actionQueue
	if blankData.creationType == Constants.CREATION_TYPES.Makeup then
		PlayerAccessoryRecordMap[player] = {}
	end

	local model = blankData.sourceModel:Clone()
	if blankData.creationType == Constants.CREATION_TYPES.Makeup then
		MakeupProjectionUtils.SetupHead(model)
	end
	model.Parent = Utils.GetVisualizeServerEdits() and workspace or GetServerModelStorage()

	local editableManager = EditableManager.new()
	PlayerEditableManagerMap[player] = editableManager

	local success, playerEditModel = pcall(function()
		return ModelInfo.new(editableManager, model, blankData)
	end)
	if not success then
		editableManager:Destroy()
		PlayerEditableManagerMap[player] = nil
		error(playerEditModel, 0)
	end
	if playerEditModel:GetCreationType() == Constants.CREATION_TYPES.Body then
		AttachmentUtils.BuildRigFromAttachments(model)
		AccessoryUtils.ReapplyLayeredClothing(model)
	end

	actionQueue:SetTargetModelInfo(playerEditModel)

	if Utils.GetVisualizeServerEdits() then
		model:MoveTo(Vector3.new(0, 5, 0))

		task.spawn(function()
			while true do
				task.wait(1)
				playerEditModel:UpdateOutputColorMap()
			end
		end)
	end

	if PlayerActionQueueMap[player] ~= actionQueue then
		-- Player left before we could finish setting up
		playerEditModel:Destroy()
	end
end

InitializeServerModelEvent.OnServerEvent:Connect(SetupPlayerEditModel)

local function IsMakeupAccessoryCategory(category): boolean
	return type(category) == "string" and Constants.MAKEUP_ACCESSORY_ASSET_TYPES[category] == true
end

local function BuildPlayerAccessoryModel(player, category)
	local builds = PlayerAccessoryBuildMap[player]
	if not builds then
		builds = {}
		PlayerAccessoryBuildMap[player] = builds
	end
	if builds[category] then
		return
	end
	builds[category] = true

	local readyRecord
	while true do
		-- Only build the latest selection; newer requests replace its record and queued actions.
		-- Keep this guard across resets until the current allocation has finished.
		local accessoryRecords = PlayerAccessoryRecordMap[player]
		local record = accessoryRecords and accessoryRecords[category]
		if not record then
			break
		end

		local success, modelInfo = pcall(function()
			return AccessoryEditModel.Build(PlayerEditableManagerMap[player], record.template, CFrame.identity, {
				parent = GetServerModelStorage(),
				serverEditTarget = category,
				serverEditRevision = record.revision,
				textureResolution = record.textureResolution,
			})
		end)
		if PlayerAccessoryRecordMap[player] ~= accessoryRecords or accessoryRecords[category] ~= record then
			if success and modelInfo then
				modelInfo:Destroy()
			end
			continue
		end
		if not success or not modelInfo then
			record.error = "Could not prepare " .. category .. " on the server. Remove the item and try again."
			ShowMessageEvent:FireClient(player, record.error)
			warn("SetAccessoryEditModel: failed to build " .. record.name .. ": " .. tostring(modelInfo))
		else
			record.modelInfo = modelInfo
			readyRecord = record
		end
		break
	end

	builds[category] = nil
	if not next(builds) then
		PlayerAccessoryBuildMap[player] = nil
	end
	if readyRecord then
		readyRecord.actionQueue:SetTargetModelInfo(readyRecord.modelInfo)
	end
end

local function SetAccessoryEditModel(player, category, accessoryName, resolutionIndex, revision, order)
	local accessoryRecords = PlayerAccessoryRecordMap[player]
	if not accessoryRecords or not IsMakeupAccessoryCategory(category) then
		return
	end
	if type(revision) ~= "string" or #revision == 0 or #revision > 64 then
		return
	end

	local previousRecord = accessoryRecords[category]
	if accessoryName == nil then
		if previousRecord and previousRecord.revision == revision then
			accessoryRecords[category] = nil
			DestroyAccessoryRecord(previousRecord)
		end
		return
	end
	if
		type(accessoryName) ~= "string"
		or type(order) ~= "number"
		or order % 1 ~= 0
		or order < 1
		or order > #ACCESSORY_CATEGORIES
	then
		return
	end
	if previousRecord and previousRecord.revision == revision then
		if previousRecord.name == accessoryName then
			previousRecord.order = order
		end
		return
	end

	local templateFolder = ReplicatedStorage:FindFirstChild("Eyebrows_Eyelashes_Template")
	local categoryFolder = templateFolder and templateFolder:FindFirstChild(category)
	local template = categoryFolder and categoryFolder:FindFirstChild(accessoryName)
	if not template or not template:IsA("Accessory") then
		return
	end
	local handle = template:FindFirstChildWhichIsA("MeshPart", true)
	if not handle or not handle:FindFirstChildWhichIsA("WrapLayer") then
		return
	end
	local textureResolution = GetTextureResolution(resolutionIndex)
	if not textureResolution then
		return
	end

	local actionQueue = ActionQueue.new(player)
	local record = {
		category = category,
		name = accessoryName,
		revision = revision,
		order = order,
		template = template,
		textureResolution = textureResolution,
		actionQueue = actionQueue,
		modelInfo = nil,
	}
	accessoryRecords[category] = record
	DestroyAccessoryRecord(previousRecord)

	BuildPlayerAccessoryModel(player, category)
end

SetAccessoryEditModelEvent.OnServerEvent:Connect(SetAccessoryEditModel)

local function ReceivedActionFromClient(player, action)
	if type(action) ~= "table" or type(action.actionType) ~= "string" then
		return
	end
	local accessoryCategory = action.serverEditTarget
	local accessoryRevision = action.serverEditRevision
	local playerActionQueue
	local accessoryRecord
	if accessoryCategory ~= nil then
		if not IsMakeupAccessoryCategory(accessoryCategory) then
			warn("Invalid accessory action target from player " .. player.Name)
			return
		end
		local accessoryRecords = PlayerAccessoryRecordMap[player]
		accessoryRecord = accessoryRecords and accessoryRecords[accessoryCategory]
		if not accessoryRecord or accessoryRecord.revision ~= accessoryRevision or accessoryRecord.error then
			return
		end
		playerActionQueue = accessoryRecord.actionQueue
	else
		playerActionQueue = PlayerActionQueueMap[player]
	end

	if not playerActionQueue then
		error("PlayerActionQueue not found for player " .. player.Name)
	end

	if not Actions.IsKnownActionType(action.actionType) then
		warn("Unknown actionType received from player " .. player.Name .. " with actionType " .. action.actionType)
		return
	end

	if action.actionType == ActionUtils.ActionTypes.SetMakeupHead then
		if accessoryRecord then
			return
		end
		local metadata = action.actionMetaData
		if
			typeof(metadata) ~= "table"
			or typeof(metadata.headId) ~= "string"
			or not MakeupHeads.GetOption(metadata.headId)
		then
			return
		end
		action.actionMetaData = {
			headId = metadata.headId,
			sourceHead = MakeupHeads.GetSourceHead(metadata.headId, nil, player.Character),
		}
	end
	playerActionQueue:AddAction(action)
end
SendActionToServerEvent.OnServerEvent:Connect(ReceivedActionFromClient)

local function ReportCreationResult(player, promptCreationEnum, promptResult, resultMessage)
	if promptResult == promptCreationEnum["Success"] then
		ShowMessageEvent:FireClient(player, "Successfully uploaded item! ItemId: " .. resultMessage)
	else
		ShowMessageEvent:FireClient(
			player,
			"Failed to upload item. Result: " .. tostring(promptResult) .. " | Error: " .. resultMessage
		)

		if promptResult ~= promptCreationEnum["PermissionDenied"] and promptResult ~= promptCreationEnum["Timeout"] then
			task.spawn(function()
				-- We throw an error here so that we can see this reported in the error dashboard for the place
				-- Since the error is in a task.spawn, it won't stop this function from completing
				error("Failed to upload item. Result Code: " .. tostring(promptResult) .. " | Error: " .. resultMessage)
			end)
		end
	end
end

local function PublishAvatarAsset(token, player, assetToUpload, avatarAssetType)
	local complete, result, resultMessage = pcall(function()
		return AvatarCreationService:PromptCreateAvatarAssetAsync(token, player, assetToUpload, avatarAssetType)
	end)
	if complete then
		ReportCreationResult(player, Enum.PromptCreateAssetResult, result, resultMessage)
	else
		ShowMessageEvent:FireClient(player, "Failed to upload asset. Reason: " .. tostring(result))
	end
end

local function PublishAvatar(token, player, humanoidDescription)
	local complete, result, resultMessage = pcall(function()
		return AvatarCreationService:PromptCreateAvatarAsync(token, player, humanoidDescription)
	end)
	if complete then
		ReportCreationResult(player, Enum.PromptCreateAvatarResult, result, resultMessage)
	else
		ShowMessageEvent:FireClient(player, "Failed to upload avatar. Reason: " .. tostring(result))
	end
end

-- Builds a Decal for PromptCreateMakeupAsync from a group's composited image set.
local function BuildMakeupDecal(composite, projectionTransfer: WrapTextureTransfer)
	local textureContent = Content.fromObject(composite.color)

	-- Set up Decal with PBR maps if available
	local decalContent = { TextureContent = textureContent }
	if composite.metalness then
		decalContent.MetalnessMapContent = Content.fromObject(composite.metalness)
	end
	if composite.roughness then
		decalContent.RoughnessMapContent = Content.fromObject(composite.roughness)
	end
	if composite.normal then
		decalContent.NormalMapContent = Content.fromObject(composite.normal)
	end

	local decal
	local ok, decalOrErr = pcall(function()
		return AssetService:CreateDecalAsync(decalContent)
	end)
	if ok and decalOrErr then
		decal = decalOrErr
	else
		-- Fallback to a color-only Decal
		if not ok then
			warn("CreateDecalAsync failed, publishing color map only: " .. tostring(decalOrErr))
		end
		decal = Instance.new("Decal")
		decal.TextureContent = textureContent
	end

	local wrapTextureTransfer = Instance.new("WrapTextureTransfer")
	wrapTextureTransfer.UVMinBound = projectionTransfer.UVMinBound
	wrapTextureTransfer.UVMaxBound = projectionTransfer.UVMaxBound
	wrapTextureTransfer.ReferenceCageMeshContent = projectionTransfer.ReferenceCageMeshContent
	wrapTextureTransfer.Parent = decal

	return decal
end

local function ReportMakeupResult(player, promptResult, outfitIdOrError)
	if promptResult == Enum.PromptCreateOutfitResult.Success then
		ShowMessageEvent:FireClient(
			player,
			"Successfully published makeup look! OutfitId: " .. tostring(outfitIdOrError)
		)
	else
		ShowMessageEvent:FireClient(
			player,
			"Failed to publish makeup. Result: " .. tostring(promptResult) .. " | Error: " .. tostring(outfitIdOrError)
		)
	end
end

local function HasVisiblePixels(image: EditableImage): boolean
	local pixels = image:ReadPixelsBuffer(Vector2.zero, image.Size)
	for offset = 3, buffer.len(pixels) - 1, 4 do
		if buffer.readu8(pixels, offset) > 0 then
			return true
		end
	end
	return false
end

local function BuildMakeupAccessoryEntry(category, record, sortOrder)
	local avatarAssetType = Constants.MAKEUP_ASSET_TYPE_TO_AVATAR_ASSET_TYPE[category]
	local tokenId = Utils.getMakeupToken(game.GameId, avatarAssetType)
	if not tokenId or tokenId == "" then
		return nil, "No creation token is configured for " .. category .. " in this universe (see Constants.TOKENS)."
	end

	local modelInfo = record.modelInfo
	modelInfo:UpdateOutputColorMap()

	local modelToPublish = modelInfo:GetModel():Clone()
	AccessoryUtils.RevertToOriginalSizes(modelToPublish)
	AttachmentUtils.RevertToOriginalPositions(modelToPublish)

	local accessory = modelToPublish:FindFirstChildWhichIsA("Accessory")
	if not accessory then
		modelToPublish:Destroy()
		return nil, "The server edit model for " .. category .. " has no accessory."
	end

	for attributeName in accessory:GetAttributes() do
		accessory:SetAttribute(attributeName, nil)
	end
	for _, descendant in accessory:GetDescendants() do
		for attributeName in descendant:GetAttributes() do
			descendant:SetAttribute(attributeName, nil)
		end
		if descendant:IsA("WeldConstraint") or descendant:IsA("Weld") then
			descendant:Destroy()
		elseif descendant:IsA("MeshPart") then
			descendant.Anchored = false
			descendant.Name = "Handle"
			if descendant:FindFirstChildWhichIsA("SurfaceAppearance") then
				descendant.TextureContent = Content.none
			end
		end
	end
	accessory.Name = "AccessoryForUpload"
	accessory.Parent = nil
	modelToPublish:Destroy()

	return {
		TokenId = tokenId,
		Instance = accessory,
		AvatarAssetType = avatarAssetType,
		SortOrder = sortOrder,
	}
end

local function GetPublishableAccessoryRecords(player)
	local accessoryRecords = PlayerAccessoryRecordMap[player]
	local visibleRecords = {}
	for _, category in ACCESSORY_CATEGORIES do
		local record = accessoryRecords and accessoryRecords[category]
		if not record then
			continue
		end
		if record.error then
			return nil, record.error
		end
		if not record.modelInfo then
			return nil, category .. " is still initializing on the server. Please try again."
		end
		record.actionQueue:FlushQueue()
		if PlayerAccessoryRecordMap[player] ~= accessoryRecords or accessoryRecords[category] ~= record then
			return nil, "The accessory selection changed while publishing. Please try again."
		end
		local modelInfo = record.modelInfo
		local group = modelInfo:GetTextureInfo():GetGroup(modelInfo:GetMeshParts()[1], category .. " 1")
		if group and group.isVisible then
			table.insert(visibleRecords, record)
		end
	end
	table.sort(visibleRecords, function(first, second)
		return if first.order == second.order then first.category < second.category else first.order < second.order
	end)
	return visibleRecords
end

local function DestroyMakeupEntries(entries)
	for _, entry in entries do
		entry.Instance:Destroy()
	end
end

local function PublishMakeup(player, playerEditModel)
	local textureInfo = playerEditModel:GetTextureInfo()
	local headPart = playerEditModel:GetMeshPartByName("Head")
	if not headPart then
		ShowMessageEvent:FireClient(player, "Failed to publish makeup: head mesh part not found.")
		return
	end

	local projectionTransfer = headPart:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME, true)
	assert(projectionTransfer and projectionTransfer:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")

	local accessoryRecords, accessoryError = GetPublishableAccessoryRecords(player)
	if not accessoryRecords then
		ShowMessageEvent:FireClient(player, "Failed to publish makeup: " .. accessoryError)
		return
	end

	-- One entry per visible group; SortOrder follows visible group order.
	local entries = {}
	for _, group in textureInfo:GetAllGroups(headPart) do
		if not group.isVisible then
			continue
		end
		local composite = textureInfo.editableManager:GetEISet(group.compositeSetId)
		assert(composite, "Group composite is missing")
		if not HasVisiblePixels(composite.color) then
			continue
		end

		local avatarAssetType = MAKEUP_ASSET_TYPE_TO_AVATAR_ASSET_TYPE[group.makeupAssetType]
		if not avatarAssetType then
			warn(
				"Skipping group '"
					.. tostring(group.name)
					.. "' with unmapped makeup asset type: "
					.. tostring(group.makeupAssetType)
			)
			continue
		end

		local tokenId = Utils.getMakeupToken(game.GameId, avatarAssetType)
		if not tokenId or tokenId == "" then
			warn(
				"Skipping group '"
					.. tostring(group.name)
					.. "': no makeup creation token configured for avatar asset type "
					.. tostring(avatarAssetType)
					.. " in this universe (see Constants.TOKENS)."
			)
			continue
		end

		table.insert(entries, {
			TokenId = tokenId,
			Instance = BuildMakeupDecal(composite, projectionTransfer),
			AvatarAssetType = avatarAssetType,
			SortOrder = #entries + 1,
		})
	end

	for _, record in accessoryRecords do
		local entry, buildError = BuildMakeupAccessoryEntry(record.category, record, #entries + 1)
		if not entry then
			DestroyMakeupEntries(entries)
			ShowMessageEvent:FireClient(player, "Failed to publish makeup: " .. tostring(buildError))
			return
		end
		table.insert(entries, entry)
	end

	if #entries == 0 then
		ShowMessageEvent:FireClient(player, "Add visible makeup edits before publishing.")
		return
	end

	if #entries < MAKEUP_MIN_ASSETS then
		-- PromptCreateMakeupAsync requires at least MAKEUP_MIN_ASSETS entries, so a
		-- lone makeup item is published as a standalone asset instead.
		local entry = entries[1]
		PublishAvatarAsset(entry.TokenId, player, entry.Instance, entry.AvatarAssetType)
		DestroyMakeupEntries(entries)
		return
	end

	if #entries > MAKEUP_MAX_ASSETS then
		DestroyMakeupEntries(entries)
		ShowMessageEvent:FireClient(
			player,
			string.format("Makeup publish supports at most %d items. You have %d.", MAKEUP_MAX_ASSETS, #entries)
		)
		return
	end

	local complete, result, outfitIdOrError = pcall(function()
		return AvatarCreationService:PromptCreateMakeupAsync(player, entries)
	end)
	DestroyMakeupEntries(entries)

	if complete then
		ReportMakeupResult(player, result, outfitIdOrError)
	else
		warn("PromptCreateMakeupAsync error: " .. tostring(result))
		ShowMessageEvent:FireClient(player, "Failed to publish makeup. Reason: " .. tostring(result))
	end
end

local function PublishModel(player)
	local actionQueue = PlayerActionQueueMap[player]
	if not actionQueue then
		error("PlayerActionQueue not found for player " .. player.Name)
	end

	actionQueue:FlushQueue()

	local playerEditModel: ModelInfo.ModelInfoClass = actionQueue:GetPlayerModelInfo()

	playerEditModel:UpdateOutputColorMap()

	-- Makeup heads publish their layer groups as a makeup look rather than a
	-- body/accessory.
	if playerEditModel:GetCreationType() == Constants.CREATION_TYPES.Makeup then
		PublishMakeup(player, playerEditModel)
		return
	end

	local modelToPublish = playerEditModel:GetModel():Clone()

	AccessoryUtils.RevertToOriginalSizes(modelToPublish)
	AttachmentUtils.RevertToOriginalPositions(modelToPublish)

	local assetToUpload, avatarAssetType, avatarAssetToken
	for _, meshPart in modelToPublish:GetDescendants() do
		if not meshPart:IsA("MeshPart") then
			continue
		end

		meshPart.Anchored = false

		if meshPart.Parent:IsA("Accessory") then
			local accessoryType = meshPart.Parent.AccessoryType
			if accessoryType and ACCESSORY_TO_AVATAR_ASSET_TYPE[accessoryType] then
				avatarAssetType = ACCESSORY_TO_AVATAR_ASSET_TYPE[accessoryType]
				local token = Utils.getToken(game.GameId, avatarAssetType)
				if token then
					local modelParent = Instance.new("Model")
					meshPart.Parent.Parent = modelParent
					assetToUpload = meshPart.Parent
					avatarAssetToken = token
					meshPart.Parent.Name = "AccessoryForUpload"
				end
			end
			meshPart.Name = "Handle"
		elseif meshPart.Name ~= "PrimaryPart" then
			meshPart.TextureID = ""
		end

		-- Remove welds for layered accessories for publish
		local weldConstraint = meshPart:FindFirstChildOfClass("WeldConstraint")
		if weldConstraint then
			weldConstraint:Destroy()
		end

		-- If surface appearance, remove mesh TextureContent for publish
		local surfaceAppearance = meshPart:FindFirstChildOfClass("SurfaceAppearance")
		if surfaceAppearance then
			meshPart.TextureContent = Content.none
		end
	end

	if assetToUpload then
		PublishAvatarAsset(avatarAssetToken, player, assetToUpload, avatarAssetType)
	else
		local humanoidDescription = modelToPublish:FindFirstChildWhichIsA("HumanoidDescription")
		local bodyToken = Utils.getToken(game.GameId)
		PublishAvatar(bodyToken, player, humanoidDescription)
	end
end

BuyRemoteEvent.OnServerEvent:Connect(function(player)
	PublishModel(player)
end)

ResetPlayerModelServerEvent.OnServerEvent:Connect(ResetPlayerModel)

GetCreationPriceFunction.OnServerInvoke = function(player, tokenOrTokens: string | { string })
	if type(tokenOrTokens) == "table" then
		return Utils.getPricesForCreations(tokenOrTokens)
	end
	return Utils.getPriceForCreation(tokenOrTokens)
end

local function OnPlayerRemoving(player)
	ResetPlayerModel(player)
end

Players.PlayerRemoving:Connect(OnPlayerRemoving)
