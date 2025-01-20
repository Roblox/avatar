-- CreationManager is the main module for the body creation demo.
-- It is responsible for setting up the model, layers, tools, and UI.

--[[ Roblox Services ]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = PlayersService.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")

--[[ Constants ]]--
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local BaseUI = require(UI:WaitForChild("BaseUI"))
local Message = require(UI:WaitForChild("Message"))
local MeshEditingWidgetManager = require(Client:WaitForChild("MeshEditingWidgetManager"))

local ModelDisplay = require(Client:WaitForChild("ModelDisplay"))
local InputManager = require(Client:WaitForChild("InputManager"))
local CameraManager = require(Client:WaitForChild("CameraManager"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Utils = require(Modules:WaitForChild("Utils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BlanksData = require(Config:WaitForChild("BlanksData"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))

--[[ Tools ]]--
local Tools = Client:WaitForChild("Tools")
local FabricTool = require(Tools:WaitForChild("FabricTool"))
local StickerTool = require(Tools:WaitForChild("StickerTool"))
local BrushTool = require(Tools:WaitForChild("BrushTool"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PlayerClickedHumanoidEvent = Remotes:WaitForChild("OnPlayerClickedHumanoid")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")

-- Set visibility of the loading screen
local function SetLoadingScreenVisible(visible: boolean)
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local LoadingScreen = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("LoadingScreen")
	LoadingScreen.Visible = visible
	return PlayerGui, LoadingScreen
end

-- Set to true to have the avatar previewed locally in the game world after exiting edit mode
-- This is useful for debugging things like animations with the scaled avatar
local DEBUG_PREVIEW_AVATAR_LOCALLY = false

local CreationManager = {}
CreationManager.__index = CreationManager

local function GetAverageMeshPartPosition(model: Model): Vector3
	local averageMeshPartPosition = Vector3.zero
	local numMeshParts = 0
	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("MeshPart") then
			averageMeshPartPosition = averageMeshPartPosition + child.Position
			numMeshParts = numMeshParts + 1
		end
	end

	averageMeshPartPosition = averageMeshPartPosition / numMeshParts
	return averageMeshPartPosition
end

local function UpdateCameraForEditMode(modelInfo: ModelInfo.ModelInfoClass)
	modelInfo:InitializeMeshPartPositions()
	local averageMeshPartPosition = GetAverageMeshPartPosition(modelInfo:GetModel())

	local camera = workspace.CurrentCamera

	local cameraPosition = averageMeshPartPosition + (Vector3.new(0, 0, 1) * 10)
	local targetPosition = averageMeshPartPosition

	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(cameraPosition, targetPosition)
end

local function SetupClientModel(blankData: BlanksData.BlankData): Model
	-- Create loading screen while model is loading
	local PlayerGui, LoadingScreen = SetLoadingScreenVisible(true)

	local newModel: Model = blankData.sourceModel:Clone()
	newModel.Parent = workspace

	return newModel
end

local function GetPlayerControls()
	local playerModule = require(LocalPlayer.PlayerScripts.PlayerModule) :: any
	return playerModule:GetControls()
end

function CreationManager.new(modelInfo: ModelInfo.ModelInfoClass)
	local self = {}
	setmetatable(self, CreationManager)

	GetPlayerControls():Disable()

	self.cameraResetPos = workspace.CurrentCamera.CFrame.Position
	self.modelInfo = modelInfo

	-- Setup camera controls
	self.cameraManager = CameraManager.new(modelInfo)
	self.modelDisplay = ModelDisplay.new(modelInfo)
	self.inputManager = InputManager.new(self.cameraManager, self.modelDisplay)

	-- Hide loading screen now that model + textures are finished loading
	local PlayerGui, LoadingScreen = SetLoadingScreenVisible(false)

	self.brushTool = BrushTool.new(self.modelInfo, self.inputManager)
	self.fabricTool = FabricTool.new(self.modelInfo)
	self.stickerTool = StickerTool.new(self.modelInfo, self.inputManager)
	self.baseUI = BaseUI.new(self, self.fabricTool, self.stickerTool, self.brushTool)
	self.meshEditingWidgetManager = MeshEditingWidgetManager.new(self.modelInfo, self.modelDisplay, self.inputManager, self.cameraManager)

	-- Enable virtual cursor on console when entering edit mode
	if GuiService:IsTenFootInterface() then
		GamepadService:EnableGamepadCursor(nil)
	end

	return self
end

local lastEditedModelInfo = nil

local function DestroyLastModel()
	if lastEditedModelInfo then
		ResetPlayerModelServerEvent:FireServer()
		lastEditedModelInfo:Destroy()
		lastEditedModelInfo = nil
	end
end

local function FixUpMultipleFolders(humanoidDescription : HumanoidDescription)
	for _, child in humanoidDescription:GetChildren() do
		if not child:isA("BodyPartDescription") then
			continue
		end

		local bodyPartDescription : BodyPartDescription = child
		if bodyPartDescription.BodyPart == Enum.BodyPart.Head then
			continue
		end

		local bodyPart = bodyPartDescription.Instance

		local newFolder = Instance.new("Folder")
		newFolder.Name = bodyPart.Name

		local r15ArtistIntent = Instance.new("Folder")
		r15ArtistIntent.Name = "R15ArtistIntent"

		for _, child in pairs(bodyPart:GetChildren()) do
			child.Parent = r15ArtistIntent
		end

		r15ArtistIntent.Parent = newFolder

		local r6 = Instance.new("Folder")
		r6.Name = "R6"
		r6.Parent = newFolder

		newFolder.Parent = bodyPart.Parent

		bodyPartDescription.Instance = newFolder
	end
end

local function UnAnchorModel(model: Model)
	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Anchored = false

			if child.Parent:IsA("Accessory") then
				child.Name = "Handle"
			end
		end
	end
end

local function PreviewAvatarLocally(modelInfo: ModelInfo.ModelInfoClass)
	local model = modelInfo:GetModel():Clone()
	local humanoidDescription = model:FindFirstChildWhichIsA("HumanoidDescription")

	FixUpMultipleFolders(humanoidDescription)

	local humanoidModel = PlayersService:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	humanoidModel.Name = "TestCharacter"

	UnAnchorModel(humanoidModel)

	local currentCharacter = LocalPlayer.Character
	humanoidModel:SetPrimaryPartCFrame(currentCharacter:GetPrimaryPartCFrame())
	currentCharacter.Parent = nil

	humanoidModel.Parent = workspace

	LocalPlayer.Character = humanoidModel

	local animate = humanoidModel:FindFirstChild("Animate")
	animate.Enabled = false
	task.wait()
	animate.Enabled = true
end

function CreationManager:Quit()
	if DEBUG_PREVIEW_AVATAR_LOCALLY then
		PreviewAvatarLocally(self.modelInfo)
	end

	self.modelDisplay:Destroy()
	self.inputManager:Destroy()
	self.cameraManager:Destroy()

	self.brushTool:Destroy()
	self.fabricTool:Destroy()
	self.stickerTool:Destroy()

	self.meshEditingWidgetManager:Destroy()

	self.baseUI:Destroy()

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	local characterRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		workspace.CurrentCamera.FieldOfView = 70
		workspace.CurrentCamera.CFrame = CFrame.lookAt(self.cameraResetPos, characterRoot.CFrame.Position)
	end

	GetPlayerControls():Enable()

	if GuiService:IsTenFootInterface() then
		-- Disable virtual cursor on console when leaving edit mode
		GamepadService:DisableGamepadCursor(nil)
	end
end

function CreationManager:SetEditMode(editMode)
	self.editMode = editMode
end

function CreationManager:GetEditMode()
	return self.editMode
end

function CreationManager:ExitEditMode()
	self:SetEditMode(Constants.EDIT_MODE_NONE)
	self.modelDisplay:OnExitedEditMode()
end

function CreationManager:ResetCamera()
	self.cameraManager:ResetCamera(true --[[useTween]])
end

function CreationManager:PanToRight()
	self.cameraManager:PanToRight()
end

function CreationManager:ShowMeshEditControls(controlGroupName)
	self.modelDisplay:ResetModel()
	self.meshEditingWidgetManager:SetupWidgets(controlGroupName)
end

function CreationManager:HideMeshEditControls()
	self.meshEditingWidgetManager:HideWidgets()

	-- Deform any dirty mesh parts
	local meshInfo: MeshInfo.MeshInfoClass = self.modelInfo:GetMeshInfo()
	meshInfo:UpdateDeformedEditableMeshes()
end

function CreationManager:IsShowingMeshEditControls()
	return self.meshEditingWidgetManager:IsShowingWidgets()
end

function CreationManager:GetInputManager()
	return self.inputManager
end

local function InitModelFromBlankData(blankData: BlanksData.BlankData)
	-- Editing a different model, so destroy any existing modelInfo
	DestroyLastModel()
	local model = SetupClientModel(blankData)

	InitializeServerModelEvent:FireServer(blankData.name)
	return ModelInfo.new(model, blankData)
end

-- Creates a new CreationManager instance for the given model name
-- and sets up the camera view for edit mode.
--
-- If the model name matches the previously edited model, the existing
-- modelInfo is reused (maintaining all previous edits).
-- Otherwise, a new modelInfo is created from the blank data.
local function EnterCreationMode(modelName)
	local blankData = Utils.GetBlankDataByName(modelName)
	if not blankData then
		warn("No blank data found for model name: " .. modelName)
		return
	end

	if not lastEditedModelInfo or lastEditedModelInfo:GetBlankName() ~= modelName then
		lastEditedModelInfo = InitModelFromBlankData(blankData)
	end

	UpdateCameraForEditMode(lastEditedModelInfo)
	CreationManager.new(lastEditedModelInfo)
end

local debounceEnterModel = false

local function EnterCreationModeInitial(modelName)
	if debounceEnterModel then
		return
	end
	debounceEnterModel = true

	local result, err = pcall(function() EnterCreationMode(modelName) end)
	if not result then
		local PlayerGui, LoadingScreen = SetLoadingScreenVisible(false)
		warn(err)
		Message.CreateMessageGui("Setup failed, out of Memory.")
	end

	task.wait(3)
	debounceEnterModel = false
end

PlayerClickedHumanoidEvent.OnClientEvent:Connect(EnterCreationModeInitial)

function CreationManager:ResetModelInfo()
	self:Quit()

	if not lastEditedModelInfo then
		warn("No model info to reset")
		return
	end

	local modelName = lastEditedModelInfo:GetBlankName()
	DestroyLastModel()
	EnterCreationMode(modelName)
end
