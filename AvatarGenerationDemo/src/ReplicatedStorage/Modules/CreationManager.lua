local AvatarCreationService = game:GetService("AvatarCreationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Events = ReplicatedStorage:WaitForChild("Events")

local AllowEnterQueueEvent = Events:WaitForChild("AllowEnterQueueEvent")
local CloseUIEvent = Events:WaitForChild("CloseUIEvent")
local EquipModelEvent = Events:WaitForChild("EquipModelEvent")
local Generate2DEvent = Events:WaitForChild("Generate2DEvent")
local Generate3DModelEvent = Events:WaitForChild("Generate3DModelEvent")
local ImageGeneratedEvent = Events:WaitForChild("ImageGeneratedEvent")
local ImageSelectedEvent = Events:WaitForChild("ImageSelectedEvent")
local ModelGeneratedEvent = Events:WaitForChild("ModelGeneratedEvent")
local OpenAvatarEditorEvent = Events:WaitForChild("OpenAvatarEditorEvent")
local SelectImageEvent = Events:WaitForChild("SelectImageEvent")
local SessionReadyEvent = Events:WaitForChild("SessionReadyEvent")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local SelfiePreview = require(Modules:WaitForChild("SelfiePreview"))
local AvatarEditor = require(Modules:WaitForChild("AvatarEditor"))
local InGameButtons = require(Modules:WaitForChild("InGameButtons"))
local ModelDisplay = require(Modules:WaitForChild("ModelDisplay"))

local CreationManager = {}
CreationManager.__index = CreationManager

function CreationManager.new(textPromptUI)
	local self = {}
	setmetatable(self, CreationManager)

	self.textPromptUI = textPromptUI
	self.selfiePreview = SelfiePreview.new(self)
	self.inGameButtons = InGameButtons.new(self)
	self.avatarEditor = AvatarEditor.new(self)
	self.bIsGenerating2d = false
	self.images = {}
	self.models = {}
	self.humanoidDescriptions = {}

	if self.previewParams == nil then
		self.previewParams = {}
	end

	if self.modelParams == nil then
		self.modelParams = {}
	end

	-- Load pre-baked models
	local modelNameAssetIdMap = {
		["Orc"] = "rbxassetid://17661880467",
	}
	local modelFolder = workspace:WaitForChild("GeneratedModels")
	if modelFolder then
		for _, model in pairs(modelFolder:GetChildren()) do
			local modelData = {}
			modelData.name = model.Name
			modelData.model = model
			modelData.image = nil
			modelData.isGenerated = false
			local assetId = modelNameAssetIdMap[model.Name]
			if assetId then
				modelData.imageAssetId = assetId
			end
			self.models[#self.models + 1] = modelData
		end
	else
		error("Model folder not found")
	end

	self.modelDisplay = ModelDisplay.new(self)

	ImageGeneratedEvent.OnClientEvent:Connect(function(avatarPreview, prompt, jobId, photoData) self:OnImageGenerated(avatarPreview, prompt, jobId, photoData) end)
	ModelGeneratedEvent.OnClientEvent:Connect(function(modelName, imageId) self:OnAvatarGenerated(modelName, imageId) end)
	SessionReadyEvent.OnClientEvent:Connect(function(sessionInfo) self:OnSessionReady(sessionInfo) end)
	ImageSelectedEvent.OnClientEvent:Connect(function(fileId)
		self.textPromptUI.textPromptPanel.Visible = true
		self.textPromptUI.textPromptTextBox.Text = ""
		while self.textPromptUI.textPromptPanel.Visible do
			wait(.01)
		end
		if not self.generating2d then
			return
		end
		local prompt = self.textPromptUI.textPromptTextBox.Text.." "
		Generate2DEvent:FireServer(prompt, {["FileId"] = fileId}, photoData)
	end)

	OpenAvatarEditorEvent.Event:Connect(function()
		self:OpenAvatarEditor()
	end)

	EquipModelEvent.Event:Connect(function(modelName)
		-- If we're already showing, hide first
		if self.avatarEditor.screenGui.Enabled then
			self:CloseAvatarEditor()
		end

		self:OpenAvatarEditor()
	end)

	UserInputService.InputBegan:Connect(function(input)
		if (UserInputService:GetFocusedTextBox()) then
			return; -- make sure player's not chatting!
		end
		if input.KeyCode == Enum.KeyCode.RightBracket then
			self:CloseAvatarEditor()
		end
	end)

	return self
end

function CreationManager:CloseAvatarEditor()
	self.avatarEditor:Hide()
	self.inGameButtons:SetToggleButtonVisibility(true)
end

function CreationManager:OpenAvatarEditor()
	self.inGameButtons:SetToggleButtonVisibility(false)
	self.avatarEditor:Show()
end

function CreationManager:OnSessionReady(sessionInfo)
	self.selfiePreview.numGenerationsRemaining = sessionInfo["Allowed2DGenerations"]
	self.genEndTime = tick() + sessionInfo["SessionTime"]
end

function CreationManager:OnClickedGenerate2d()
	self.generating2d = true
	SelectImageEvent:FireServer()
end

function CreationManager:OnClickedGenerate3d(imageIndex)
	Generate3DModelEvent:FireServer(self.modelParams, imageIndex)
end

function CreationManager:OnImageGenerated(avatarPreview, prompt, jobId, photoData)
	self.lastGeneratedImageUrl = avatarPreview
	self.generating2d = false

	local editableImage = AvatarCreationService:LoadAvatar2DPreviewAsync(avatarPreview)

	self.selfiePreview:ShowGeneratedImage(editableImage, prompt, jobId)

	self:StoreImage(editableImage, prompt, jobId, photoData)
end

function CreationManager:StoreImage(editableImage, prompt, imageId, photoData)
	-- Each player can have multiple images, so we store them in a table indexed by an id
	-- These images are later shown in the list of 3d models
	local imageData = {}
	imageData.editableImage = editableImage
	imageData.prompt = prompt
	imageData.photoData = photoData
	self.images[imageId] = imageData
end

function CreationManager:GetImage(imageId)
	return self.images[imageId]
end

function CreationManager:RecursivePrintChildren(parent, indentation)
	if indentation == nil then
		indentation = ""
	end
	for _, child in pairs(parent:GetChildren()) do
		self:RecursivePrintChildren(child, indentation .. "  ")
	end
end

function CreationManager:OnAvatarGenerated(modelName, imageId)
	local humanoidDescription = AvatarCreationService:LoadGeneratedAvatarAsync(modelName)
	humanoidDescription.Name = "GeneratedHumanoidDescription" .. #self.models
	humanoidDescription.Parent = workspace

	local bpFolder = Instance.new("Folder")

	for _, c in humanoidDescription:GetChildren() do
		c.Instance.Parent = bpFolder
	end

	self.humanoidDescriptions[humanoidDescription.Name] = humanoidDescription

	local modelData = {}
	modelData.humanoidDescription = humanoidDescription
	if self.images[imageId] ~= nil then
		modelData.image = self.images[imageId].editableImage
	else
		print("image not found. Using default: last generated image")
		modelData.image = self.images[#self.images].editableImage
	end
	modelData.prompt = self.images[imageId].prompt
	modelData.name = "GeneratedHumanoidDescription" .. #self.models
	modelData.isGenerated = true
	modelData.GenerationId = modelName
	self.models[#self.models + 1] = modelData
end

function CreationManager:ReopenUI()
	self.selfiePreview:ReopenUI()
	self.inGameButtons:SetToggleButtonVisibility(false)
end

function CreationManager:OnCloseSelfiePreview()
	self.textPromptUI.textPromptPanel.Visible = false
	if not self.avatarEditor:IsShowing() then
		self.inGameButtons:SetToggleButtonVisibility(true)
	end

	if self.generating2d then
		self.generating2d = false
	end

	self.selfiePreview.generatedImage.ImageContent = Content.none
	CloseUIEvent:FireServer()
	AllowEnterQueueEvent:FireServer()
end


local function RunCreationManager(textPromptUI)
	return CreationManager.new(textPromptUI)
end

return RunCreationManager
