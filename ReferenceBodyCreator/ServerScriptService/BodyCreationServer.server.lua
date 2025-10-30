local AvatarCreationService = game:GetService("AvatarCreationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local Utils = require(Modules:WaitForChild("Utils"))
local Actions = require(Modules:WaitForChild("Actions"))
local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))

local ServerModules = ServerStorage:WaitForChild("Modules")
local ActionQueue = require(ServerModules:WaitForChild("ActionQueue"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")
local ShowMessageEvent = Remotes:WaitForChild("ShowMessageEvent")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")
local ResetCompleteEvent = Remotes:WaitForChild("ResetCompleteEvent")


local ACCESSORY_TO_AVATAR_ASSET_TYPE = {
	[Enum.AccessoryType.TShirt] = Enum.AvatarAssetType.TShirtAccessory,
	[Enum.AccessoryType.Hat] = Enum.AvatarAssetType.Hat,
} 

local PlayerActionQueueMap = {}

local function GetServerModelStorage()
	local serverModelStorage = ServerStorage:FindFirstChild("ServerModelStorage")
	if not serverModelStorage then
		serverModelStorage = Instance.new("Folder")
		serverModelStorage.Name = "ServerModelStorage"
		serverModelStorage.Parent = ServerStorage
	end

	return serverModelStorage
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

	ResetCompleteEvent:FireClient(player)
end

local function SetupPlayerEditModel(player, blankName, resolutionIndex)
	local blankData = Utils.GetBlankDataByName(blankName)
	if not blankData then
		error("BlankData not found for blankName " .. blankName)
	end

	if PlayerActionQueueMap[player] then
		warn("PlayerActionQueue already exists for player " .. player.Name)
		ResetPlayerModel(player)
	end
	local actionQueue = ActionQueue.new(player)
	PlayerActionQueueMap[player] = actionQueue

	local model = blankData.sourceModel:Clone()
	model.Parent = Utils.GetVisualizeServerEdits() and workspace or GetServerModelStorage()

	ResolutionManager.SetResolutionIndex(resolutionIndex)

	local playerEditModel = ModelInfo.new(model, blankData)
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

local function ReceivedActionFromClient(player, action)
	local playerActionQueue = PlayerActionQueueMap[player]
	if not playerActionQueue then
		error("PlayerActionQueue not found for player " .. player.Name)
	end

	if not Actions.IsKnownActionType(action.actionType) then
		warn("Unknown actionType received from player " .. player.Name .. " with actionType " .. action.actionType)
		return
	end

	playerActionQueue:AddAction(action)
end
SendActionToServerEvent.OnServerEvent:Connect(ReceivedActionFromClient)

local function ReportCreationResult(player, promptCreationEnum, promptResult, resultMessage)
	if promptResult == promptCreationEnum["Success"] then
		print("successfully uploaded, ItemId: ", resultMessage)
		ShowMessageEvent:FireClient(player, "Successfully uploaded item! ItemId: " .. resultMessage)
	else
		print("Received result", promptResult)
		print("ResultMessage:", resultMessage)
		ShowMessageEvent:FireClient(
			player,
			"Failed to upload item. Result: " .. tostring(promptResult) .. " | Error: " .. resultMessage
		)

		if promptResult ~= promptCreationEnum["PermissionDenied"] and
			promptResult ~= promptCreationEnum["Timeout"] then
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
		print("error")
		print(result)

		ShowMessageEvent:FireClient(player, "Failed to upload asset. Reason: " .. tostring(result))
	end
end

local function PublishAvatar(token,  player, humanoidDescription)
	local complete, result, resultMessage = pcall(function()
		return AvatarCreationService:PromptCreateAvatarAsync(token, player, humanoidDescription)
	end)
	if complete then
		ReportCreationResult(player, Enum.PromptCreateAvatarResult, result, resultMessage)
	else
		print("error")
		print(result)

		ShowMessageEvent:FireClient(player, "Failed to upload avatar. Reason: " .. tostring(result))
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
		end

		-- Remove welds for layered accessories for publish
		local weldConstraint = meshPart:FindFirstChildOfClass("WeldConstraint")
		if weldConstraint then
			weldConstraint:Destroy()
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

local function OnPlayerRemoving(player)
	ResetPlayerModel(player)
end

Players.PlayerRemoving:Connect(OnPlayerRemoving)
