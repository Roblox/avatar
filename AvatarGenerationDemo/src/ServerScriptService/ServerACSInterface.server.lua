local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local AvatarCreationService = game:GetService("AvatarCreationService")
local TextService = game:GetService("TextService")

local Events = ReplicatedStorage:WaitForChild("Events")
local Generate2DEvent = Events:WaitForChild("Generate2DEvent")
local Generate3DModelEvent = Events:WaitForChild("Generate3DModelEvent")

local ImageGeneratedEvent = Events:WaitForChild("ImageGeneratedEvent")
local ImageFailedEvent = Events:WaitForChild("ImageFailedEvent")
local ModelGeneratedEvent = Events:WaitForChild("ModelGeneratedEvent")
local ModelProgressUpdateEvent = Events:WaitForChild("ModelProgressUpdateEvent")
local SelectImageEvent = Events:WaitForChild("SelectImageEvent")
local ImageSelectedEvent = Events:WaitForChild("ImageSelectedEvent")

local EnterQueueEvent = Events:WaitForChild("EnterQueueEvent")
local ShowQueueUIEvent = Events:WaitForChild("ShowQueueUIEvent")
local QueueProgressEvent = Events:WaitForChild("QueueProgressEvent")
local AllowEnterQueueEvent = Events:WaitForChild("AllowEnterQueueEvent")
local CloseUIEvent = Events:WaitForChild("CloseUIEvent")
local SessionReadyEvent = Events:WaitForChild("SessionReadyEvent")


local Modules = ReplicatedStorage:WaitForChild("Modules")

local SESSION_INFO = "sessionInfo"
local SESSION_CONNECTION = "sessionConnection"

-- Keep track of all image jobs for each player
local playerImageJobs = {}
local playerSessions = {}
local canEnterQueue = true


local function GetSessionWaitTime(player)
	playerSessions[player] = {}
	local conn, waitTime = AvatarCreationService:RequestAvatarGenerationSessionAsync(player, function(sessionInfo)
		playerSessions[player][SESSION_INFO] = sessionInfo
		SessionReadyEvent:FireClient(player, sessionInfo)
	end)
	playerSessions[player][SESSION_CONNECTION] = conn
	return waitTime
end

local function CloseUI(player)
	if playerSessions[player] == nil then
		return
	end
	playerSessions[player][SESSION_CONNECTION]:Disconnect()
	playerSessions[player] = nil
end

local function GetPlayerSessionAsync(player)
	while playerSessions[player][SESSION_INFO] == nil do
		wait(1)
	end
	return playerSessions[player][SESSION_INFO]
end

local function OnPlayerClickedEnterQueue(player)
	if canEnterQueue ~= true then
		return
	end
	local waitTime = GetSessionWaitTime(player)
	QueueProgressEvent:FireClient(player, waitTime)
	canEnterQueue = false
end

local function OnAllowEnterQueue(player)
	canEnterQueue = true
end

local function SelectImage(player)
	local success, result = pcall(function()
		return AvatarCreationService:PromptSelectAvatarGenerationImageAsync(player)
	end)
	if not success then
		print("PromptSelectAvatarGenerationImageAsync, error:", result)
		ImageFailedEvent:FireClient(player, "Failed to select image")
		return
	end
	local fileId = result
	print("Image selected with fileId: "..fileId)
	ImageSelectedEvent:FireClient(player, fileId)
end

local function Generate2D(player, prompt, inputParams, photoData)
	local fileId = inputParams["FileId"] 
	print("generate2d selected with fileId: "..fileId)

	local session = GetPlayerSessionAsync(player)
	if not session or not session.SessionId then
		warn("failed to start new session")
		ImageFailedEvent:FireClient(player, "Failed to start new session")
		return
	end

	success, result = pcall(function()
		return AvatarCreationService:GenerateAvatar2DPreviewAsync({
			SessionId = session.SessionId,
			FileId = fileId,
			TextPrompt = prompt
		})
	end)

	if not success then
		warn("avatar preview job failed:", result)
		ImageFailedEvent:FireClient(player, result)
		return
	end

	local previewImageUrl = result
	local imageJobs = playerImageJobs[player]
	if imageJobs == nil then
		imageJobs = {}
	end
	local jobIndex = #imageJobs + 1
	imageJobs[jobIndex] = previewImageUrl
	playerImageJobs[player] = imageJobs

	ImageGeneratedEvent:FireClient(player, previewImageUrl, prompt, jobIndex, photoData)

end

local function StoreGeneratedHumanoidDescription(generationId)
	local hd = game:GetService("AvatarCreationService"):LoadGeneratedAvatarAsync(generationId)
	hd.Name = generationId
	hd.Parent = ServerStorage

	local bpFolder = Instance.new("Folder")
	bpFolder.Name = "BodyPartsFolder"..generationId
	bpFolder.Parent = ServerStorage

	for _, c in ServerStorage:WaitForChild(generationId):GetChildren() do
		c.Instance.Parent = bpFolder
	end
end

local function Generate3D(player, inputParams, imageId)
	local previewJobId = playerImageJobs[player][imageId]
	if previewJobId == nil then
		error(`No preview job found for player: {player.Name}, imageId: {imageId}`)
		return
	end

	local session = GetPlayerSessionAsync(player)
	if not session then
		warn("failed to start new session")
		return
	end

	playerSessions[player] = nil

	local success, result = pcall(function()
		return AvatarCreationService:GenerateAvatarAsync({
			SessionId = session.SessionId,
			PreviewId = previewJobId,
		})
	end)

	if not success then
		warn("avatar model job failed:", result)
		ModelProgressUpdateEvent:FireClient(player, -1)
		return
	end

	local modelJobId = result
	ModelGeneratedEvent:FireClient(player, modelJobId, imageId)
	StoreGeneratedHumanoidDescription(modelJobId)
end

EnterQueueEvent.Event:Connect(OnPlayerClickedEnterQueue)
AllowEnterQueueEvent.OnServerEvent:Connect(OnAllowEnterQueue)
Generate2DEvent.OnServerEvent:Connect(Generate2D)
SelectImageEvent.OnServerEvent:Connect(SelectImage)
Generate3DModelEvent.OnServerEvent:Connect(Generate3D)
CloseUIEvent.OnServerEvent:Connect(CloseUI)
