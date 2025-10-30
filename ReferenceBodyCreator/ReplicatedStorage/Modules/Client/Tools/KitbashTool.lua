--[[
Allows users to place, edit, and merge 3D MeshParts onto a target MeshPart
Pieces are placed on the target MeshPart surface via raycasting
Users can drag, rotate, and scale pieces using interactive handles
On update of the piece placement, the piece is merged into the target mesh geometry
Textures are packed into a 2x2 atlas to support multiple textured kitbash pieces
UVs are remapped to fit each piece into its assigned grid entry

ATLAS TEXTURE LAYOUT:
┌─────────────┬─────────────┐
│             │             │
│   Target    │  Piece 1    │
│  Texture    │             │
│             │             │
│             │             │
├─────────────┼─────────────┤
│             │             │
│  Piece 2    │  Piece 3    │
│             │             │
│             │             │
│             │             │
└─────────────┴─────────────┘
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local KitbashPieces = ReplicatedStorage:WaitForChild("KitbashPieces")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))
local Utils = require(Modules:WaitForChild("Utils"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local styleTokens = StyleConsts.styleTokens

local Components = UI:WaitForChild("Components")
local EditHandle = require(Components:WaitForChild("EditHandle"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Actions = require(Modules:WaitForChild("Actions"))
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local KitbashTool = {}
KitbashTool.__index = KitbashTool

local HANDLE_GUI_NAME = "KitbashHandleGui"

type KitbashPieceData = {
	name: string,
	sourcePart: MeshPart,
	meshPart: MeshPart,
	positionMarker: Part,
	positionMarkerOffset: CFrame,
	targetMeshPart: MeshPart,
	normal: Vector3,
	rotation: number,
	scale: number,
	minScale: number,
	maxScale: number,

	-- Track merge state
	isMerged: boolean,
	isMerging: boolean,
	mergedFaceIds: { number }?,
	hasDrawnToAtlas: boolean?,
	atlasSlot: number?,
}

function KitbashTool.new(modelInfo, inputManager, modelDisplay)
	local self = {}
	setmetatable(self, KitbashTool)

	self.modelInfo = modelInfo
	self.inputManager = inputManager
	self.modelDisplay = modelDisplay

	self.placedPieces = modelInfo:GetPlacedKitbashPieces()
	self.currentlySelectedPiece = nil
	self.isDragging = false
	self.isRotating = false
	self.isScaling = false

	self.connections = {}
	self.UIHandles = {}

	self:SetupHandles()

	-- Whenever the player rotates/moves the model, we need to update the screen location of UI handles.
	for _, meshPart in modelInfo:GetMeshParts() do
		local connection = meshPart:GetPropertyChangedSignal("Position"):Connect(function()
			local selectedPiece = self.placedPieces[self.currentlySelectedPiece]
			if selectedPiece ~= nil then
				self:RefreshMarkerPosition(selectedPiece)
			end
		end)
		table.insert(self.connections, connection)
	end

	return self
end

function KitbashTool:ConnectHandlesToStyle(style)
	style:LinkGui(self.inputGui)
end

function KitbashTool:RefreshMarkerPosition(selectedPiece)
	if selectedPiece then
		selectedPiece.positionMarker.CFrame =
			selectedPiece.targetMeshPart.CFrame:ToWorldSpace(selectedPiece.positionMarkerOffset)

		local directionIndicator = selectedPiece.positionMarker:FindFirstChild("StickerDirectionMarker")
		if directionIndicator then
			directionIndicator.Position = selectedPiece.positionMarker.Position + selectedPiece.projectionDirection
		end

		self:RefreshHandleUI()
	end
end

function KitbashTool:Enable()
	-- If we have placed pieces, select the top one
	if #self.placedPieces > 0 then
		self.currentlySelectedPiece = #self.placedPieces

		-- Enable handles at the piece's position
		self.inputGui.Enabled = true
		self:RefreshHandleUI()
	end
end

function KitbashTool:Disable()
	-- Hide handles
	if self.inputGui then
		self.inputGui.Enabled = false
	end

	self.currentlySelectedPiece = nil
	self.isDragging = false
	self.isRotating = false
	self.isScaling = false
end

-- When merging a kitbash piece onto a target MeshPart,
-- we check for space in the atlas and allocate it for
-- the texture of the kitbashed piece
function KitbashTool:AllocateAtlasSlot()
	local usedSlots = {}
	for _, pieceData in self.placedPieces do
		if pieceData.atlasSlot then
			usedSlots[pieceData.atlasSlot] = true
		end
	end

	for i = 1, Constants.ATLAS_MAX_KITBASH_PIECES do
		if not usedSlots[i] then
			return i
		end
	end

	return nil
end

-- Delete the currently selected piece off of the creation.
-- This includes unmerging the geometry and clearing the texture
-- off the atlas, reallocating that space for another piece
function KitbashTool:DeleteCurrentPiece()
	if not self.currentlySelectedPiece then
		warn("No piece selected to delete!")
		return
	end

	-- Unmerge piece geometry and reallocate atlas texture space
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if pieceData.isMerged then
		self:UnmergePiece(pieceData, true --[[isDeleting]])
	end

	-- Remove the visual piece for editing
	pieceData.meshPart:Destroy()
	pieceData.positionMarker:Destroy()

	-- If another piece exists, reselect the previously added piece
	table.remove(self.placedPieces, self.currentlySelectedPiece)
	if #self.placedPieces > 0 then
		self.currentlySelectedPiece = math.min(self.currentlySelectedPiece, #self.placedPieces)

		local newSelectedPiece = self.placedPieces[self.currentlySelectedPiece]

		self.inputGui.Enabled = true
		self:RefreshHandleUI()
	else
		self.currentlySelectedPiece = nil
		self.inputGui.Enabled = false
	end
end

-- Trigger WrapDeformer to recompute by touching a single cage vertex
function KitbashTool:RefreshWrapDeformer(targetMeshPart)
	local meshInfo = self.modelInfo:GetMeshInfo()
	local targetMeshInfo = meshInfo:GetMeshInfoByName(targetMeshPart.Name)
	if targetMeshInfo.cageInfo then
		local cageMesh = targetMeshInfo.cageInfo.cageEditableMesh
		local vertices = cageMesh:GetVertices()

		if #vertices > 0 then
			local vertexId = vertices[1]
			cageMesh:SetPosition(vertexId, cageMesh:GetPosition(vertexId))
		end
	end
end

-- Remove piece geometry from target MeshPart. Optionally, remove texture from
-- atlas when deleting since unmerge may also be called when simply updating an
-- already merged piece via translation, rotation, or scaling. In which case, the
-- atlas remains unchanged
function KitbashTool:UnmergePiece(pieceData: KitbashPieceData, isDeleting)
	if not pieceData.isMerged or pieceData.isMerging then
		return
	end

	local unmergeActionMetadata: MeshEditActions.UnmergeKitbashPieceActionMetadata = {
		targetMeshPartName = pieceData.targetMeshPart.Name,
		mergedFaceIds = pieceData.mergedFaceIds,
		atlasSlot = if isDeleting then pieceData.atlasSlot else nil,
	}

	local unmergeAction = Actions.CreateNewAction(Actions.ActionTypes.UnmergeKitbashPiece, unmergeActionMetadata)
	Actions.ExecuteAction(self.modelInfo, unmergeAction)

	self:RefreshWrapDeformer(pieceData.targetMeshPart)

	SendActionToServerEvent:FireServer(unmergeAction)

	-- Make the visual piece visible again for editing
	pieceData.meshPart.Transparency = 0
	pieceData.isMerged = false
end

--  Combine the kitbash piece with the target MeshPart. This involves the following:
-- 1. Combining geometry via adding vertices/faces
-- 2. Updating our texture atlas with the kitbash piece texture
-- 3. Updating the piece's UVs to map to the atlas texture
function KitbashTool:MergeCurrentPiece()
	if not self.currentlySelectedPiece then
		warn("No piece selected to merge!")
		return
	end

	local pieceData = self.placedPieces[self.currentlySelectedPiece]

	if pieceData.isMerged or pieceData.isMerging then
		return
	end
	pieceData.isMerging =  true
	self.modelDisplay:SetRotationEnabled(false)

	local meshInfo = self.modelInfo:GetMeshInfo()
	local textureInfo = self.modelInfo:GetTextureInfo()

	local targetMeshPart = pieceData.targetMeshPart
	local editableMeshMap = meshInfo:GetKitbashEditableMeshMap()
	local targetEditableMesh = editableMeshMap[targetMeshPart]
	local meshScaleFactorMap = meshInfo:GetScaleFactorMap()
	local targetScaleFactor = meshScaleFactorMap[targetMeshPart]
	local baseTextureLayer = textureInfo:GetBaseLayer(targetMeshPart)

	-- Merge piece directly on the Client to return the face
	-- ids added during the geometry merge. This will enable us
	-- to remove these added faces/verts when we need to unmerge this
	-- piece.
	local addedFaceIds = MeshUtils.MergeKitbashPiece({
		targetMeshPart = targetMeshPart,
		targetEditableMesh = targetEditableMesh,
		targetScaleFactor = targetScaleFactor,
		kitbashMeshId = pieceData.sourcePart.MeshId,
		kitbashTextureId = pieceData.sourcePart.TextureID,
		positionMarkerCFrame = pieceData.positionMarker.CFrame,
		scale = pieceData.scale,
		rotation = pieceData.rotation,
		baseTextureLayer = baseTextureLayer,
		atlasSlot = pieceData.atlasSlot,
		hasDrawnToAtlas = pieceData.hasDrawnToAtlas or false,
	})

	if not pieceData.hasDrawnToAtlas then
		textureInfo:UpdateOutputColorMap(targetMeshPart)
	end

	self:RefreshWrapDeformer(targetMeshPart)

	pieceData.mergedFaceIds = addedFaceIds

	-- Hide the visual piece
	pieceData.meshPart.Transparency = 1

	-- Send action to server
	local mergeActionMetadata: MeshEditActions.MergeKitbashPieceActionMetadata = {
		targetMeshPartName = pieceData.targetMeshPart.Name,
		kitbashMeshId = pieceData.sourcePart.MeshId,
		kitbashTextureId = pieceData.sourcePart.TextureID,
		positionMarkerOffset = pieceData.positionMarkerOffset,
		scale = pieceData.scale,
		rotation = pieceData.rotation,
		atlasSlot = pieceData.atlasSlot,
		hasDrawnToAtlas = pieceData.hasDrawnToAtlas or false,
	}
	local mergeAction = Actions.CreateNewAction(Actions.ActionTypes.MergeKitbashPiece, mergeActionMetadata)
	SendActionToServerEvent:FireServer(mergeAction)

	pieceData.hasDrawnToAtlas = true
	pieceData.isMerged = true
	pieceData.isMerging = false
	self.modelDisplay:SetRotationEnabled(true)
end

function KitbashTool:SetupHandles()
	local handleGui = Instance.new("ScreenGui")
	handleGui.Name = HANDLE_GUI_NAME
	handleGui.Parent = PlayerGui
	self.inputGui = handleGui
	handleGui.Enabled = false

	self.UIHandles = EditHandle.new()

	local moveHandle = self.UIHandles.moveHandle
	moveHandle.Parent = handleGui
	-- These are already children of the moveHandle
	local rotateHandle = self.UIHandles.rotateHandle
	local scaleHandle = self.UIHandles.scaleHandle

	local moveHandleInputBegan = moveHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isRotating or self.isScaling or not self.inputManager:TryGrabLock(self) then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged then
				-- Unmerge so we can drag the visual piece again
				self:UnmergePiece(pieceData)
			end
			self.isDragging = true
		end
	end)
	table.insert(self.connections, moveHandleInputBegan)

	local inputChanged = UserInputService.InputChanged:Connect(function(input)
		if self.isDragging and Utils.isValidDraggingInput(input) then
			self:DragPiece(input)
		elseif self.isRotating and Utils.isValidDraggingInput(input) then
			self:RotatePiece(input)
		elseif self.isScaling and Utils.isValidDraggingInput(input) then
			self:ScalePiece(input)
		end
	end)
	table.insert(self.connections, inputChanged)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isDragging then
				self.isDragging = false
				self:MergeCurrentPiece()
			elseif self.isRotating then
				self.isRotating = false
				self:MergeCurrentPiece()
			elseif self.isScaling then
				self.isScaling = false
				self:MergeCurrentPiece()
			end
		end
	end)
	table.insert(self.connections, inputEnded)

	local rotateHandleInputBegan = rotateHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isDragging or self.isScaling then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged then
				-- Unmerge so we can rotate the visual piece again
				self:UnmergePiece(pieceData)
			end
			self.isRotating = true
		end
	end)
	table.insert(self.connections, rotateHandleInputBegan)

	local scaleHandleInputBegan = scaleHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isDragging or self.isRotating then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged then
				-- Unmerge so we can scale the visual piece again
				self:UnmergePiece(pieceData)
			end

			self.isScaling = true
			self.mouseDownPos = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)
	table.insert(self.connections, scaleHandleInputBegan)

	local cameraChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		self:RefreshHandleUI()
	end)
	table.insert(self.connections, cameraChangedConnection)
end

function KitbashTool:RefreshHandleUI()
	-- Don't show handles if no piece selected
	if not self.currentlySelectedPiece then
		self.inputGui.Enabled = false
		return
	else
		self.inputGui.Enabled = true
	end

	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	local piece3dPos = pieceData.positionMarker.Position
	local camera = workspace.CurrentCamera

	local screenPos = camera:WorldToScreenPoint(piece3dPos)

	self.UIHandles:Refresh(screenPos, pieceData.scale, pieceData.rotation)
end

-- Update the mesh part's CFrame to reflect rotation and scale
function KitbashTool:UpdatePieceTransform(pieceData: KitbashPieceData)
	local baseCFrame = pieceData.positionMarker.CFrame

	local rotationCFrame = CFrame.Angles(0, 0, math.rad(pieceData.rotation))
	local finalCFrame = baseCFrame * rotationCFrame

	local baseSize = pieceData.sourcePart.Size
	pieceData.meshPart.Size = baseSize * pieceData.scale

	pieceData.meshPart.CFrame = finalCFrame
end

local function GetPieceData(pieceName)
	return {
		name = pieceName,
		sourcePart = KitbashPieces:FindFirstChild(pieceName),
	}
end

function KitbashTool:SelectPiece(pieceName, minScale, maxScale)
	local meshInfo = self.modelInfo:GetMeshInfo()
	local meshParts = self.modelInfo:GetMeshParts()

	local pieceData = GetPieceData(pieceName)

	if not pieceData.sourcePart then
		warn("Could not find", pieceName, "in ReplicatedStorage.KitbashPieces")
		return
	end

	-- Allocate slot if needed and not already allocated
	local hasKitbashTexture = pieceData.sourcePart.TextureID ~= ""
	local atlasSlot = 0
	if hasKitbashTexture and not pieceData.atlasSlot then
		local slot = self:AllocateAtlasSlot()
		if not slot then
			warn(
				string.format(
					"No atlas slots available! Maximum %d kitbash pieces.",
					Constants.ATLAS_MAX_KITBASH_PIECES
				)
			)
			return
		end
		atlasSlot = slot
	end

	local averagePos = Vector3.zero
	for _, part in meshParts do
		averagePos = averagePos + part.Position
	end
	averagePos = averagePos / #meshParts

	-- Raycast from camera to the average position
	local camera = workspace.CurrentCamera
	local rayOrigin = camera.CFrame.Position
	local rayDirection = (averagePos - rayOrigin).Unit * 100

	local raycastResult = MeshUtils.RaycastAll(
		Ray.new(rayOrigin, rayDirection),
		meshInfo:GetEditableMeshMap(),
		meshInfo:GetScaleFactorMap()
	)

	if not raycastResult then
		warn("Could not raycast to place piece - trying first mesh part")
		local firstPart = meshParts[1]
		rayDirection = (firstPart.Position - rayOrigin).Unit * 100
		raycastResult = MeshUtils.RaycastAll(
			Ray.new(rayOrigin, rayDirection),
			meshInfo:GetEditableMeshMap(),
			meshInfo:GetScaleFactorMap()
		)

		if not raycastResult then
			warn("Could not raycast to place piece")
			return
		end
	end

	local targetMeshPart = raycastResult.meshPart

	-- Create kitbash piece to be transformed for editing
	-- This will indicate where to merge
	local piece = pieceData.sourcePart:Clone()
	piece.Name = "KitbashPiece_" .. pieceData.name
	piece.CanCollide = false
	piece.Anchored = true
	piece.Transparency = 0

	local positionMarker = Instance.new("Part")
	positionMarker.Name = "KitbashPositionMarker"
	positionMarker.Anchored = true
	positionMarker.CanCollide = false
	positionMarker.CanTouch = false
	positionMarker.CanQuery = false
	positionMarker.Size = Vector3.new(0.1, 0.1, 0.1)
	positionMarker.Transparency = 1
	positionMarker.Parent = workspace

	-- Use the raycast result to position the piece on the surface
	local markerCFrame = MeshUtils.EditableMeshRaycastToCFrame(
		raycastResult.editableMesh,
		raycastResult.meshPart,
		raycastResult.point,
		raycastResult.triangleId,
		raycastResult.scaleFactor
	)

	positionMarker.CFrame = markerCFrame
	piece.Parent = workspace

	local newPieceData: KitbashPieceData = {
		name = pieceData.name,
		sourcePart = pieceData.sourcePart,
		meshPart = piece,
		positionMarker = positionMarker,
		positionMarkerOffset = targetMeshPart.CFrame:ToObjectSpace(markerCFrame),
		targetMeshPart = targetMeshPart,
		normal = markerCFrame.LookVector,
		rotation = 0,
		scale = 1,
		minScale = minScale or Constants.DEFAULT_KITBASH_MIN_SCALE,
		maxScale = maxScale or Constants.DEFAULT_KITBASH_MAX_SCALE,
		isMerged = false,
		isMerging = false,
		atlasSlot = atlasSlot,
	}

	self:UpdatePieceTransform(newPieceData)
	table.insert(self.placedPieces, newPieceData)
	self.currentlySelectedPiece = #self.placedPieces
	self:RefreshHandleUI()
	self:MergeCurrentPiece()
end

function KitbashTool:DragPiece(input)
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if not pieceData then
		return
	end

	local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y, 1)

	local meshInfo = self.modelInfo:GetMeshInfo()
	local raycastResult = MeshUtils.RaycastAll(ray, meshInfo:GetEditableMeshMap(), meshInfo:GetScaleFactorMap())

	if not raycastResult then
		return
	end

	-- Update the piece position
	local newCFrame = MeshUtils.EditableMeshRaycastToCFrame(
		raycastResult.editableMesh,
		raycastResult.meshPart,
		raycastResult.point,
		raycastResult.triangleId,
		raycastResult.scaleFactor
	)

	pieceData.positionMarker.CFrame = newCFrame
	pieceData.positionMarkerOffset = raycastResult.meshPart.CFrame:ToObjectSpace(newCFrame)
	pieceData.targetMeshPart = raycastResult.meshPart
	pieceData.normal = newCFrame.LookVector

	self:UpdatePieceTransform(pieceData)
	self:RefreshHandleUI()
end

function KitbashTool:RotatePiece(input)
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if not pieceData then
		return
	end

	local camera = workspace.CurrentCamera
	local centerScreenPos = camera:WorldToScreenPoint(pieceData.positionMarker.Position)
	local centerPos = Vector2.new(centerScreenPos.X, centerScreenPos.Y)

	local mousePos = Vector2.new(input.Position.X, input.Position.Y)

	local deltaPos = mousePos - centerPos
	local angle = math.deg(math.atan2(deltaPos.Y, deltaPos.X))

	-- Account for cursor placement along handle
	pieceData.rotation = angle + 90 - styleTokens.RotateHandlePosDegrees

	self:UpdatePieceTransform(pieceData)
	self:RefreshHandleUI()
end

function KitbashTool:ScalePiece(input)
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if not pieceData then
		return
	end

	local currentMousePos = Vector2.new(input.Position.X, input.Position.Y)
	if not self.mouseDownPos then
		self.mouseDownPos = currentMousePos
		return
	end

	local mouseMovement = currentMousePos - self.mouseDownPos
	local scaleChange = mouseMovement.X * 0.01
	pieceData.scale = math.clamp(pieceData.scale + scaleChange, pieceData.minScale, pieceData.maxScale)
	self.mouseDownPos = currentMousePos

	self:UpdatePieceTransform(pieceData)
	self:RefreshHandleUI()
end

function KitbashTool:Destroy()
	self.modelInfo:SavePlacedKitbashPieces(self.placedPieces)
	-- Disconnect all event connections
	for _, connection in self.connections do
		connection:Disconnect()
	end
	self.connections = {}

	-- Clean up UI
	if self.inputGui then
		self.inputGui:Destroy()
	end

	self.placedPieces = {}
end

return KitbashTool
