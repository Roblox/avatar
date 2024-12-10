local AvatarCreationService = game:GetService("AvatarCreationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local Utils = require(Modules:WaitForChild("Utils"))
local Actions = require(Modules:WaitForChild("Actions"))

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

-- If you republish this game, you will need to create a new token in the creator dashboard for the new game

local GAME_ID_TOKEN_MAP = {
	[6812969780] = "6703e42c-6c3f-42fb-8b35-206c345c9a9f",
	[5113694998] = "fd0639ed-595e-42a9-bdd4-8944840c8f52",
}

local DEMO_TOKEN = GAME_ID_TOKEN_MAP[game.GameId]

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

local function SetupPlayerEditModel(player, blankName)
	local blankData = Utils.GetBlankDataByName(blankName)
	if not blankData then
		error("BlankData not found for blankName " .. blankName)
	end

	if PlayerActionQueueMap[player] then
		error("PlayerActionQueue already exists for player " .. player.Name)
	end
	local actionQueue = ActionQueue.new(player)
	PlayerActionQueueMap[player] = actionQueue

	local model = blankData.sourceModel:Clone()
	model.Parent = Utils.GetVisualizeServerEdits() and workspace or GetServerModelStorage()

	local playerEditModel = ModelInfo.new(model, blankData)

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

local function PublishModel(player)
	local actionQueue = PlayerActionQueueMap[player]
	if not actionQueue then
		error("PlayerActionQueue not found for player " .. player.Name)
	end

	actionQueue:FlushQueue()

	local playerEditModel: ModelInfo.ModelInfoClass = actionQueue:GetPlayerModelInfo()

	playerEditModel:UpdateOutputColorMap()

	local humanoidDescription = playerEditModel:GetHumanoidDescription()

	AccessoryUtils.RevertToOriginalSizes(playerEditModel:GetModel())
	AttachmentUtils.RevertToOriginalPositions(playerEditModel:GetModel())

	for _, meshPart in playerEditModel:GetMeshParts() do
		meshPart.Anchored = false

		if meshPart.Parent:IsA("Accessory") then
			meshPart.Name = "Handle"
		end
	end

	local complete, result, resultMessage = pcall(function()
		return AvatarCreationService:PromptCreateAvatarAsync(DEMO_TOKEN, player, humanoidDescription)
	end)
	if complete then
		if result == Enum.PromptCreateAvatarResult.Success then
			print("successfully uploaded, AssetId: ", resultMessage)
			ShowMessageEvent:FireClient(player, "Successfully uploaded avatar! OutfitId: " .. resultMessage)
		else
			print("Received result", result)
			print("ResultMessage:", resultMessage)
			ShowMessageEvent:FireClient(
				player,
				"Failed to upload avatar. Result: " .. tostring(result) .. " | Error: " .. resultMessage
			)
		end
	else
		print("error")
		print(result)
		ShowMessageEvent:FireClient(player, "Failed to upload avatar. Reason: " .. tostring(result))
	end
end

BuyRemoteEvent.OnServerEvent:Connect(function(player)
	PublishModel(player)
end)

local function ResetPlayerModel(player)
	local actionQueue = PlayerActionQueueMap[player]
	PlayerActionQueueMap[player] = nil

	if actionQueue then
		local playerEditModel: ModelInfo.ModelInfoClass? = actionQueue:GetPlayerModelInfo()
		if playerEditModel then
			playerEditModel:Destroy()
		end
	end
end

ResetPlayerModelServerEvent.OnServerEvent:Connect(ResetPlayerModel)

local function OnPlayerRemoving(player)
	ResetPlayerModel(player)
end

Players.PlayerRemoving:Connect(OnPlayerRemoving)
