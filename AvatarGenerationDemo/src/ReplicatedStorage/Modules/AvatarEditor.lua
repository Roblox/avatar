-- A clean sims-like view of an avatar in the middle and UI elements to equip different heads/bodies/accessories
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local UIUtils = require(Modules:WaitForChild("UIUtils"))

local TEXT_FONT = Enum.Font.GothamSemibold

local AvatarEditor = {}
AvatarEditor.__index = AvatarEditor

function AvatarEditor.new(creationManager)
	local self = {}
	setmetatable(self, AvatarEditor)

	self.creationManager = creationManager
	self.originalHumanoidDescription = game.Players.LocalPlayer.Character.Humanoid:GetAppliedDescription()
	self.currentHumanoidDescription = self.originalHumanoidDescription:Clone()
	self.currentHumanoidDescription.Parent = workspace

	game.Players.LocalPlayer.Character.Archivable = true

	self:CreateUI()

	self.screenGui.Enabled = false

	return self
end

-- Creates the various UI elements for the avatar editor
-- On the right: a set of grid views for heads, bodies, and accessories
-- In the middle: a 3D view of the avatar
-- On the left: a set of buttons to change the avatar's pose?
-- Also need a button to reset the avatar to their original appearance
function AvatarEditor:CreateUI()

	-- ScreenGui to hold all UI
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "AvatarEditorGui"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Right side: grid views for heads, bodies, and accessories
	self.rightFrame = Instance.new("Frame")
	self.rightFrame.Size = UDim2.new(0, 332, 1, 0)
	self.rightFrame.AnchorPoint = Vector2.new(1, 0)
	self.rightFrame.Position = UDim2.new(1, 0, 0, 70)
	self.rightFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	self.rightFrame.BackgroundTransparency = 1
	self.rightFrame.Parent = self.screenGui

	-- Button to zoom in on the head
	self.zoomButton = Instance.new("TextButton")
	self.zoomButton.Size = UDim2.new(0, 150, 0, 40)
	self.zoomButton.AnchorPoint = Vector2.new(0.5, 0)
	self.zoomButton.Position = UDim2.new(0.5, 0, 0, 20)
	self.zoomButton.Text = "Zoom In"
	self.zoomButton.TextSize = 16
	self.zoomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.zoomButton.Font = TEXT_FONT
	self.zoomButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	self.zoomButton.ZIndex = 2
	self.zoomButton.Parent = self.screenGui
	UIUtils.AddUICorner(self.zoomButton, 5)
	self.zoomButtonState = 0

	self.zoomButton.Activated:Connect(function()
		if self.zoomButtonState == 0 then
			-- Zoom in on the head
			self:ZoomToHead()
		else
			-- Zoom out to the full body
			self:ZoomToBody()
		end
	end)

	-- The right side of the screen is a vertical list of grid views
	-- Each grid view is scrollable, and also the entire list is scrollable
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, -150)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollFrame.BackgroundColor3 = Color3.fromHex("#121215")
	scrollFrame.BackgroundTransparency = 0
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
	scrollFrame.Parent = self.rightFrame

	UIUtils.AddListLayout(scrollFrame)
	UIUtils.AddUIPadding(scrollFrame, 10)
	UIUtils.AddUICorner(scrollFrame, 8)

	local headParent, headGrid = self:SetupGridView("Heads")
	self.headGrid = headGrid
	headParent.Parent = scrollFrame
	headParent.LayoutOrder = 1

	-- "Reset appearance" button on the left
	self.leftFrame = Instance.new("Frame")
	self.leftFrame.Size = UDim2.new(1, 0, 1, 0)
	self.leftFrame.AnchorPoint = Vector2.new(0, 0)
	self.leftFrame.Position = UDim2.new(0, 20, 0, 0)
	self.leftFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	self.leftFrame.BackgroundTransparency = 1
	self.leftFrame.Parent = self.screenGui

	local resetButton = Instance.new("TextButton")
	resetButton.Size = UDim2.new(0, 150, 0, 40)
	resetButton.AnchorPoint = Vector2.new(0, 1)
	resetButton.Position = UDim2.new(0, 0, 1, -20)
	resetButton.Text = "Reset Appearance"
	resetButton.TextSize = 16
	resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	resetButton.Font = TEXT_FONT
	resetButton.BackgroundColor3 = Color3.fromHex("#121215")
	resetButton.BackgroundTransparency = 0.08
	resetButton.Parent = self.leftFrame
	UIUtils.AddUICorner(resetButton, 10)

	resetButton.Activated:Connect(function()
		-- Reset the avatar to its original appearance
		self.currentGeneratedAvatarId = ""
		self.currentHumanoidDescription = self.originalHumanoidDescription:Clone()
		self:RefreshModel()
	end)

	local tryOnClothingButton = Instance.new("TextButton")
	tryOnClothingButton.Size = UDim2.new(0, 150, 0, 40)
	tryOnClothingButton.AnchorPoint = Vector2.new(0, 1)
	tryOnClothingButton.Position = UDim2.new(0, 160, 1, -20)
	tryOnClothingButton.Text = "Try on Clothing"
	tryOnClothingButton.TextSize = 16
	tryOnClothingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tryOnClothingButton.Font = TEXT_FONT
	tryOnClothingButton.BackgroundColor3 = Color3.fromHex("#121215")
	tryOnClothingButton.BackgroundTransparency = 0.08
	tryOnClothingButton.Parent = self.leftFrame
	UIUtils.AddUICorner(tryOnClothingButton, 10)

	tryOnClothingButton.Activated:Connect(function()
	   	self:EquipTShirt(7178736794)
	   	self:EquipPant(9174391966)
	end)

	-- Button to close the editor
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 40)
	closeButton.AnchorPoint = Vector2.new(1, 1)
	closeButton.Position = UDim2.new(1, -20, 1, -20)
	closeButton.Text = "Exit"
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = TEXT_FONT
	closeButton.BackgroundColor3 = Color3.fromHex("#121215")
	closeButton.BackgroundTransparency = 0.08
	closeButton.ZIndex = 2
	closeButton.Parent = self.leftFrame
	UIUtils.AddUICorner(closeButton, 10)

	closeButton.Activated:Connect(function()
		self.creationManager:CloseAvatarEditor()
	end)
end

function AvatarEditor:SetupGridView(name)
	-- Parent frame with text header
	local parentFrame = Instance.new("Frame")
	parentFrame.Name = name
	parentFrame.Size = UDim2.new(1, 0, 0, 0)
	parentFrame.AutomaticSize = Enum.AutomaticSize.Y
	parentFrame.Position = UDim2.new(0, 0, 0, 0)
	parentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	parentFrame.BackgroundTransparency = 1
	parentFrame.BorderSizePixel = 0
	parentFrame.Parent = self.rightFrame
	UIUtils.AddUICorner(parentFrame, 5)
	UIUtils.AddListLayout(parentFrame)

	local gridFrame = Instance.new("Frame")
	gridFrame.Name = name
	gridFrame.Size = UDim2.new(1, 0, 0, 0)
	gridFrame.AutomaticSize = Enum.AutomaticSize.Y
	gridFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
	gridFrame.BackgroundTransparency = 1
	gridFrame.BorderSizePixel = 0
	gridFrame.Parent = parentFrame
	gridFrame.LayoutOrder = 2
	UIUtils.AddUIPadding(gridFrame, 5)

	-- Add grid layout
	local gridLayout = Instance.new("UIGridLayout")
	local tileWidthPixels = 100
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.CellSize = UDim2.new(0, tileWidthPixels, 0, tileWidthPixels)
	gridLayout.Parent = gridFrame

	return parentFrame, gridFrame
end

function AvatarEditor:SetupGeneratedHeadItemTile(headModelName, editableImage, imageAssetId, playerPromptString, modelData)
	local tileWidthPixels = 100
	local tileFrame = Instance.new("ImageButton")
	tileFrame.Name = "HeadTile"
	tileFrame.Size = UDim2.new(0, tileWidthPixels, 0, tileWidthPixels)
	tileFrame.Position = UDim2.new(0, 0, 0, 0)
	tileFrame.BackgroundColor3 = Color3.fromHex("#191A1F")
	tileFrame.BackgroundTransparency = 0.08
	tileFrame.BorderSizePixel = 0
	tileFrame.Parent = self.headGrid
	UIUtils.AddUICorner(tileFrame, 5)

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Color = Color3.fromHex("#D0D9FB")
	uiStroke.Transparency = 0.84
	uiStroke.Parent = tileFrame

	local headImage = Instance.new("ImageLabel")
	headImage.Name = "HeadImage"
	headImage.Size = UDim2.new(1, -4, 1, -4)
	headImage.AnchorPoint = Vector2.new(0.5, 0.5)
	headImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	headImage.BackgroundTransparency = 1
	headImage.Parent = tileFrame
	UIUtils.AddUICorner(headImage, 5)

	if editableImage then
		local imageRectSize, imageRectOffset = UIUtils.GetImageRightHalfRect(editableImage)
		headImage.ImageContent = Content.fromObject(editableImage)
		if imageRectSize then
			headImage.ImageRectOffset = imageRectOffset
			headImage.ImageRectSize = imageRectSize
		end
	elseif imageAssetId then
		headImage.ImageContent = Content.fromUri(imageAssetId)
	else
		-- Create a text label with the head model name
		local noImageText = Instance.new("TextLabel")
		noImageText.Name = "NoImageText"
		noImageText.Size = UDim2.new(1, 0, 1, 0)
		noImageText.Position = UDim2.new(0, 0, 0, 0)
		noImageText.Text = headModelName
		noImageText.TextSize = 14
		noImageText.TextColor3 = Color3.new(1, 1, 1)
		noImageText.Font = TEXT_FONT
		noImageText.BackgroundTransparency = 1
		noImageText.Parent = headImage
	end

	tileFrame.Activated:Connect(function()
		-- Equip the head model
		self:EquipGeneratedHeadAndBody(headModelName, playerPromptString, modelData)
	end)
end

-- Used to populate the BodyPartDescription for a single limb (left arm, head, torso, etc)
function AvatarEditor:PopulateBodyPartDescription(hd, parentModel, folderName, bodyPart, partNames)
	local topFolder = Instance.new("Folder")
	topFolder.Name = folderName
	topFolder.Parent = workspace

	local r15Folder = Instance.new("Folder")
	r15Folder.Name = "R15"
	r15Folder.Parent = topFolder

	local r15ArtistIntentFolder = Instance.new("Folder")
	r15ArtistIntentFolder.Name = "R15ArtistIntent"
	r15ArtistIntentFolder.Parent = topFolder

	local r6Folder = Instance.new("Folder")
	r6Folder.Name = "R6"
	r6Folder.Parent = topFolder

	local color = nil
	for _, partName in pairs(partNames) do
		local partInstance = parentModel:WaitForChild(partName):Clone()
		partInstance.Parent = r15ArtistIntentFolder
		if color == nil then
			color = partInstance.Color
		end

		-- Attachment points are rotated 180 degrees, so we need to rotate them back
		for _, child in pairs(partInstance:GetChildren()) do
			if child:IsA("Attachment") then
				child.Orientation = Vector3.new(0, 0, 0)
			end
		end
	end

	local bd = Instance.new("BodyPartDescription")
	bd.Parent = hd
	bd.BodyPart = bodyPart
	bd.Instance = topFolder
	bd.Color = color
end

-- Removes accessories that may block the view of the head
-- Also removes any existing eyebrows/eyelashes
function AvatarEditor:RemoveHeadAccessories(humanoidDescription)
	humanoidDescription.HatAccessory = ""
	humanoidDescription.NeckAccessory = ""
	humanoidDescription.FaceAccessory = ""

	-- Loop over AccessoryDescriptions and remove any that are attached to the head
	for _, child in pairs(humanoidDescription:GetChildren()) do
		if child:IsA("AccessoryDescription")
			and (child.AccessoryType == Enum.AccessoryType.Hat
			or child.AccessoryType == Enum.AccessoryType.Face
			or child.AccessoryType == Enum.AccessoryType.Neck
			or child.AccessoryType == Enum.AccessoryType.Hair
			or child.AccessoryType == Enum.AccessoryType.Eyebrow
			or child.AccessoryType == Enum.AccessoryType.Eyelash) then
			child:Destroy()
		end
	end
end

function AvatarEditor:EquipTShirt(assetId)
	for _, d in self.currentHumanoidDescription:GetChildren() do
		if d:IsA("AccessoryDescription") and d.AccessoryType == Enum.AccessoryType.TShirt then
			d:Destroy()
		end
	end
	local accessoryDescription = Instance.new("AccessoryDescription")
	accessoryDescription.AssetId = assetId
	accessoryDescription.AccessoryType = Enum.AccessoryType.TShirt
	accessoryDescription.Parent = self.currentHumanoidDescription
	
	self:RefreshModel()
end

function AvatarEditor:EquipPant(assetId)
	for _, d in self.currentHumanoidDescription:GetChildren() do
		if d:IsA("AccessoryDescription") and d.AccessoryType == Enum.AccessoryType.Pants then
			d:Destroy()
		end
	end
	local accessoryDescription = Instance.new("AccessoryDescription")
	accessoryDescription.AssetId = assetId
	accessoryDescription.AccessoryType = Enum.AccessoryType.Pants
	accessoryDescription.Parent = self.currentHumanoidDescription
	
	self:RefreshModel()
end

function AvatarEditor:EquipGeneratedHeadAndBody(modelName, playerPromptString, modelData)
	self.equippedHeadModel = modelName
	self.currentGeneratedAvatarId = ""

	if modelData.isGenerated then
		self:RefreshModelFromHumanoidDescription(workspace:WaitForChild(modelName))
		self.currentGeneratedAvatarId = modelData.GenerationId
		return
	end

	self.currentHumanoidDescription = Instance.new("HumanoidDescription")

	-- Remove existing head and body from humanoid description
	for _, child in pairs(self.currentHumanoidDescription:GetChildren()) do
		if child:IsA("BodyPartDescription") then
			child:Destroy()
		end
	end

	self:RemoveHeadAccessories(self.currentHumanoidDescription)

	local model = workspace:WaitForChild("GeneratedModels"):WaitForChild(modelName)

	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "Head", Enum.BodyPart.Head, {"Head"})
	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "LeftArm", Enum.BodyPart.LeftArm, {"LeftHand", "LeftLowerArm", "LeftUpperArm"})
	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "RightArm", Enum.BodyPart.RightArm, {"RightHand", "RightLowerArm", "RightUpperArm"})
	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "LeftLeg", Enum.BodyPart.LeftLeg, {"LeftFoot", "LeftLowerLeg", "LeftUpperLeg"})
	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "RightLeg", Enum.BodyPart.RightLeg, {"RightFoot", "RightLowerLeg", "RightUpperLeg"})
	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, "Torso", Enum.BodyPart.Torso, {"UpperTorso", "LowerTorso"})

	self:EquipHead(modelName, playerPromptString)
	self:RefreshModel()
end

function AvatarEditor:EquipHead(modelName, playerPromptString)
	self.equippedHeadModel = modelName


	-- Remove existing head from humanoid description
	for _, child in pairs(self.currentHumanoidDescription:GetChildren()) do
		if child:IsA("BodyPartDescription") and child.BodyPart == Enum.BodyPart.Head then
			if child.Instance then
				if child.Instance.Name == modelName then
					child:Destroy()
					local originalHd = self.originalHumanoidDescription:clone()
					for _, originalChild in pairs(originalHd:GetChildren()) do
						if originalChild:IsA("BodyPartDescription") and originalChild.BodyPart == Enum.BodyPart.Head then
							originalChild.Parent = self.currentHumanoidDescription
						end
					end
					self:RemoveHeadAccessories(self.currentHumanoidDescription)
					self:RefreshModel()
					return
				end
			end
			child:Destroy()
		end
	end

	self:RemoveHeadAccessories(self.currentHumanoidDescription)

	local model = workspace:WaitForChild("GeneratedModels"):WaitForChild(modelName)

	self:PopulateBodyPartDescription(self.currentHumanoidDescription, model, modelName, Enum.BodyPart.Head, {"Head"})

end

function AvatarEditor:RecursivePrintChildren(parent, indentation)
	if indentation == nil then
		indentation = ""
	end
	for _, child in pairs(parent:GetChildren()) do
		local printStr = child.Name
		if child.ClassName == "BodyPartDescription" then
			if child.AssetId ~= 0 then
				printStr = printStr .. " (BodyPart = " .. tostring(child.BodyPart) .. ", AssetId = " .. child.AssetId .. ")"
			elseif child.Instance then
				printStr = printStr .. " (BodyPart = " .. tostring(child.BodyPart) .. ", Instance = " .. child.Instance.Name .. ")"
			end
		end
		self:RecursivePrintChildren(child, indentation .. "  ")
	end
end

function AvatarEditor:RefreshModel()
	self:FixDuplicateBodyParts()

	self.currentHumanoidDescription.DepthScale = 1
	self.currentHumanoidDescription.HeightScale = 1
	self.currentHumanoidDescription.ProportionScale = 0
	self.currentHumanoidDescription.BodyTypeScale = 0
	self.currentHumanoidDescription.WidthScale = 1
	self.currentHumanoidDescription.HeadScale = 1

	local newModel = game.Players:CreateHumanoidModelFromDescription(self.currentHumanoidDescription, Enum.HumanoidRigType.R15)
	newModel.Name = "AvatarModel"
	newModel.Parent = workspace
	newModel.PrimaryPart.Anchored = true
	newModel:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
	local newAnim = game.StarterPlayer.StarterCharacterScripts.Animate:Clone()
	newAnim.Parent = newModel
	local prevModel = self.avatarModel
	if prevModel then
		prevModel:Destroy()
	end
	self.avatarModel = newModel
	self.creationManager.modelDisplay:SetupModel(self.avatarModel)
end

function AvatarEditor:RefreshModelFromHumanoidDescription(humanoidDescription)
	self:FixDuplicateBodyParts()
	for _, c in humanoidDescription:GetChildren() do
		if c:IsA("AccessoryDescription") and c.AccessoryType ~= Enum.AccessoryType.Hair then
			c:Destroy()
		end
	end

	self.currentHumanoidDescription = humanoidDescription

	humanoidDescription.DepthScale = 1
	humanoidDescription.HeightScale = 1
	humanoidDescription.ProportionScale = 0
	humanoidDescription.BodyTypeScale = 0
	humanoidDescription.WidthScale = 1
	humanoidDescription.HeadScale = 1

	local newModel = game.Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	newModel.Name = "AvatarModel"
	newModel.Parent = workspace
	newModel.PrimaryPart.Anchored = true
	newModel:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
	local newAnim = game.StarterPlayer.StarterCharacterScripts.Animate:Clone()
	newAnim.Parent = newModel
	local prevModel = self.avatarModel
	if prevModel then
		prevModel:Destroy()
	end
	self.avatarModel = newModel
	self.creationManager.modelDisplay:SetupModel(self.avatarModel)
end

function AvatarEditor:FixDuplicateBodyParts()
	-- Debug: print out the current humanoid description
	self:RecursivePrintChildren(self.currentHumanoidDescription, "	")

	-- Somehow, it's possible for the HD to get into a bad state where it has multiple bodypartdescriptions for the same body part
	-- We want to remove all but the first one
	local bodyPartDescriptions = {}
	for _, child in pairs(self.currentHumanoidDescription:GetChildren()) do
		if child:IsA("BodyPartDescription") then
			if bodyPartDescriptions[child.BodyPart] == nil then
				bodyPartDescriptions[child.BodyPart] = child
			else
				warn("Removing duplicate BodyPartDescription for " .. tostring(child.BodyPart))
				child:Destroy()
			end
		end
	end
end

function AvatarEditor:ZoomToHead()
	local Camera = workspace.CurrentCamera
	local modelPosition = self.avatarModel.Head.CFrame.Position

	-- Use tweening to smoothly move the camera to the head
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local tween = game:GetService("TweenService"):Create(Camera, tweenInfo, {CFrame = CFrame.lookAt(modelPosition + Vector3.new(0, 0, 3), modelPosition)})
	tween:Play()

	self.zoomButtonState = 1
	self.zoomButton.Text = "Zoom Out"
end

function AvatarEditor:ZoomToBody()
	local Camera = workspace.CurrentCamera
	local modelPosition = self.avatarModel.PrimaryPart.CFrame.Position

	-- Use tweening to smoothly move the camera to the head
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local tween = game:GetService("TweenService"):Create(Camera, tweenInfo, {CFrame = CFrame.lookAt(modelPosition + Vector3.new(0, 0, 9), modelPosition)})
	tween:Play()

	self.zoomButtonState = 0
	self.zoomButton.Text = "Zoom In"
end

function AvatarEditor:Show()
	self.screenGui.Enabled = true

	-- Refresh the avatar view with what the player currently looks like
	if self.avatarModel then
		self.avatarModel:Destroy()
	end
	self.currentHumanoidDescription = game.Players.LocalPlayer.Character.Humanoid:GetAppliedDescription():Clone()

	self.avatarModel = game.Players.LocalPlayer.Character:Clone()
	self.avatarModel.Name = "AvatarModel"
	self.avatarModel.PrimaryPart.Anchored = true
	self.avatarModel.Parent = workspace
	self.avatarModel:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
	self.creationManager.modelDisplay:SetupModel(self.avatarModel)

	-- Create a background for the avatar
	self.background = ReplicatedStorage:WaitForChild("background"):Clone()
	self.background.Parent = workspace

	-- Focus the camera on the avatar
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable
	local modelPosition = self.avatarModel.PrimaryPart.CFrame.Position
	Camera.CFrame = CFrame.lookAt(modelPosition + Vector3.new(0, 0, 9), modelPosition)

	-- Refresh the grid views with the available heads, bodies, and accessories
	self:ResetGrids()
	local models = self.creationManager.models
	for _, modelData in pairs(models) do
		self:SetupGeneratedHeadItemTile(
			modelData.name,
			modelData.image,
			modelData.imageAssetId,
			modelData.playerPromptString,
			modelData
		)
	end

end

function AvatarEditor:ResetGrids()
	for _, child in pairs(self.headGrid:GetChildren()) do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end
end

function AvatarEditor:IsShowing()
	return self.screenGui.Enabled
end

function AvatarEditor:Hide()
	self.zoomButtonState = 0
	self.zoomButton.Text = "Zoom In"
	self.screenGui.Enabled = false

	if self.background then
		self.background:Destroy()
	end

	self:FixDuplicateBodyParts()

	-- Replace player character with new model
	local newModel = game.Players:CreateHumanoidModelFromDescription(self.currentHumanoidDescription, Enum.HumanoidRigType.R15)
	newModel.Parent = workspace
	local prevModel = game.Players.LocalPlayer.Character
	newModel.Name = prevModel.Name
	local cframe = prevModel.PrimaryPart.CFrame
	game.Players.LocalPlayer.Character = newModel
	local newAnim = game.StarterPlayer.StarterCharacterScripts.Animate:Clone()
	newAnim.Parent = newModel
	prevModel:Destroy()
	newModel:SetPrimaryPartCFrame(cframe.Rotation + cframe.Position)

	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = game.Players.LocalPlayer.Character
	camera.CFrame = newModel.Head.CFrame

	-- Destroy the avatar model
	self.avatarModel:Destroy()
end

function AvatarEditor:IsCurrentEquippedAvatarGenerated()
	if self.currentGeneratedAvatarId ~= nil and self.currentGeneratedAvatarId ~= "" then
		return true
	end
	return false
end

function AvatarEditor:GetCurrentGeneratedAvatarId()
	return self.currentGeneratedAvatarId
end

return AvatarEditor
