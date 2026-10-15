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
local KitbashSurface = require(MeshManipulation:WaitForChild("KitbashSurface"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local styleTokens = StyleConsts.styleTokens

local InputUtils = require(Client:WaitForChild("InputUtils"))

local Components = UI:WaitForChild("Components")
local EditHandle = require(Components:WaitForChild("EditHandle"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local KitbashData = require(Config:WaitForChild("KitbashData"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
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
	hasDrawnToAtlas: boolean?,
	atlasSlot: number,
	surfaceAnchor: { faceId: number, barycentric: Vector3 }?,
	pendingTransformAction: ActionUtils.Action?,
	lastTransformSent: number?,
}

function KitbashTool.new(modelInfo, inputManager, modelDisplay, historyTool)
	local self = {}
	setmetatable(self, KitbashTool)

	self.modelInfo = modelInfo
	self.inputManager = inputManager
	self.modelDisplay = modelDisplay
	self.historyTool = historyTool
	self.enabled = false
	self.useSurfaceAnchors = Constants.MAKEUP_ACCESSORY_ASSET_TYPES[modelInfo:GetServerEditTarget()] == true
	self.placementSurfaces = {}

	self.placedPieces = modelInfo:GetPlacedKitbashPieces()
	modelInfo:SavePlacedKitbashPieces(self.placedPieces)
	self.currentlySelectedPiece = nil
	self.isDragging = false
	self.isRotating = false
	self.isScaling = false

	self.connections = {}
	self.UIHandles = {}

	self:SetupHandles()

	-- Whenever the player rotates/moves the model, we need to update the screen location of UI handles.
	for _, meshPart in modelInfo:GetMeshParts() do
		local connection = meshPart:GetPropertyChangedSignal("CFrame"):Connect(function()
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

function KitbashTool:PreparePlacementSurfaces()
	if not self.useSurfaceAnchors then
		self.modelInfo:GetMeshInfo():UpdateDeformedEditableMeshes()
		return
	end
	self.preparingSurface = true
	local success, message = pcall(function()
		for part, info in self.modelInfo:GetMeshInfo():GetModelMeshInfo() do
			local surface = self.placementSurfaces[part]
			if not surface then
				surface = KitbashSurface.new(info)
				self.placementSurfaces[part] = surface
			end
			surface:Update()
		end
	end)
	self.preparingSurface = false
	if not success then
		error(message)
	end
end

function KitbashTool:GetPlacementMaps()
	local meshInfo = self.modelInfo:GetMeshInfo()
	if not self.useSurfaceAnchors then
		return meshInfo:GetEditableMeshMap(), meshInfo:GetScaleFactorMap()
	end
	local meshes, scales = {}, {}
	for part, surface in self.placementSurfaces do
		meshes[part], scales[part] = surface.mesh, Vector3.one
	end
	return meshes, scales
end

function KitbashTool:SetSurfaceAnchor(piece, hit)
	piece.surfaceAnchor = self.placementSurfaces[hit.meshPart]:GetAnchor(hit.triangleId, hit.barycentricCoordinate)
	self:RefreshMarkerPosition(piece)
end

function KitbashTool:RefreshMarkerPosition(selectedPiece)
	if selectedPiece then
		local offset = selectedPiece.positionMarkerOffset
		if self.useSurfaceAnchors and selectedPiece.surfaceAnchor then
			local anchor = selectedPiece.surfaceAnchor
			local restFrame, deformedFrame =
				self.placementSurfaces[selectedPiece.targetMeshPart]:GetFrames(anchor.faceId, anchor.barycentric)
			selectedPiece.positionMarkerOffset = restFrame
			offset = deformedFrame
		end
		selectedPiece.positionMarker.CFrame = selectedPiece.targetMeshPart.CFrame:ToWorldSpace(offset)

		self:UpdatePieceTransform(selectedPiece)
		self:RefreshHandleUI()
	end
end

function KitbashTool:Enable()
	self.enabled = true
	if self.useSurfaceAnchors then
		local success, message = pcall(self.PreparePlacementSurfaces, self)
		if not success then
			self.enabled = false
			warn("Could not prepare kitbash placement surface: " .. tostring(message))
			return
		end
		if not self.enabled then
			return
		end
	end
	-- If we have placed pieces, select the top one
	if #self.placedPieces > 0 then
		self.currentlySelectedPiece = #self.placedPieces

		-- Enable handles at the piece's position
		self.inputGui.Enabled = true
		self:RefreshMarkerPosition(self.placedPieces[self.currentlySelectedPiece])
	end
end

function KitbashTool:Disable()
	self.enabled = false
	self.isDragging = false
	self.isRotating = false
	self.isScaling = false
	-- Hide handles
	if self.inputGui then
		self.inputGui.Enabled = false
	end
	local piece = self.currentlySelectedPiece and self.placedPieces[self.currentlySelectedPiece]
	while self.isPlacing or self.preparingSurface or (piece and piece.isMerging) do
		task.wait()
		piece = self.currentlySelectedPiece and self.placedPieces[self.currentlySelectedPiece]
	end
	self:MergeCurrentPiece()

	self.currentlySelectedPiece = nil
	if not self.enabled then
		for _, surface in self.placementSurfaces do
			surface:Destroy()
		end
		table.clear(self.placementSurfaces)
	end
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
	if pieceData.isMerging then
		return
	end
	if pieceData.isMerged or pieceData.hasDrawnToAtlas then
		if not self:UnmergePiece(pieceData, true) then
			return
		end
	end

	-- Remove the visual piece for editing
	pieceData.meshPart:Destroy()
	pieceData.positionMarker:Destroy()

	-- If another piece exists, reselect the previously added piece
	table.remove(self.placedPieces, self.currentlySelectedPiece)
	if #self.placedPieces > 0 then
		self.currentlySelectedPiece = math.min(self.currentlySelectedPiece, #self.placedPieces)

		self.inputGui.Enabled = true
		self:RefreshMarkerPosition(self.placedPieces[self.currentlySelectedPiece])
	else
		self.currentlySelectedPiece = nil
		self.inputGui.Enabled = false
	end
end

-- Remove piece geometry from target MeshPart. Optionally, remove texture from
-- atlas when deleting since unmerge may also be called when simply updating an
-- already merged piece via translation, rotation, or scaling. In which case, the
-- atlas remains unchanged
function KitbashTool:UnmergePiece(pieceData: KitbashPieceData, isDeleting)
	if pieceData.isMerging or (not pieceData.isMerged and not isDeleting) then
		return false
	end

	local unmergeActionMetadata: MeshEditActions.UnmergeKitbashPieceActionMetadata = {
		targetMeshPartName = pieceData.targetMeshPart.Name,
		pieceSlot = pieceData.atlasSlot,
		atlasSlot = if isDeleting then pieceData.atlasSlot else nil,
	}

	local unmergeAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.UnmergeKitbashPiece, unmergeActionMetadata, self.modelInfo)
	if not Actions.ExecuteAction(self.modelInfo, unmergeAction, nil, self.historyTool) then
		return false
	end

	SendActionToServerEvent:FireServer(unmergeAction)

	-- Make the visual piece visible again for editing
	pieceData.meshPart.Transparency = if self.useSurfaceAnchors then 1 else 0
	pieceData.isMerged = false
	pieceData.pendingTransformAction = nil
	return true
end

function KitbashTool:FlushPieceTransform(piece)
	if piece.pendingTransformAction then
		SendActionToServerEvent:FireServer(piece.pendingTransformAction)
		piece.pendingTransformAction = nil
		piece.lastTransformSent = os.clock()
	end
end

function KitbashTool:UpdateMergedPiece(piece)
	local action = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.UpdateKitbashPiece, {
		targetMeshPartName = piece.targetMeshPart.Name,
		pieceSlot = piece.atlasSlot,
		positionMarkerOffset = piece.positionMarkerOffset,
		scale = piece.scale,
		rotation = piece.rotation,
	}, self.modelInfo)
	if Actions.ExecuteAction(self.modelInfo, action, nil, self.historyTool) then
		piece.pendingTransformAction = action
		if os.clock() - (piece.lastTransformSent or 0) >= 1 / 30 then
			self:FlushPieceTransform(piece)
		end
	end
end

--  Combine the kitbash piece with the target MeshPart. This involves the following:
-- 1. Combining geometry via adding vertices/faces
-- 2. Updating our texture atlas with the kitbash piece texture
-- 3. Updating the piece's UVs to map to the atlas texture
function KitbashTool:MergeCurrentPiece()
	local pieceData = self.currentlySelectedPiece and self.placedPieces[self.currentlySelectedPiece]
	if pieceData and pieceData.isMerged and self.useSurfaceAnchors then
		self:FlushPieceTransform(pieceData)
		return
	end
	if not pieceData or pieceData.isMerged or pieceData.isMerging then
		return
	end
	pieceData.isMerging = true
	self.modelDisplay:SetRotationEnabled(false)
	-- Finish reading the drag surface before changing topology.
	while self.refreshingDragMesh do
		task.wait()
	end

	local metadata: MeshEditActions.MergeKitbashPieceActionMetadata = {
		targetMeshPartName = pieceData.targetMeshPart.Name,
		kitbashMeshId = pieceData.sourcePart.MeshId,
		kitbashTextureId = pieceData.sourcePart.TextureID,
		kitbashSourcePart = pieceData.sourcePart,
		positionMarkerOffset = pieceData.positionMarkerOffset,
		scale = pieceData.scale,
		rotation = pieceData.rotation,
		atlasSlot = pieceData.atlasSlot,
		hasDrawnToAtlas = pieceData.hasDrawnToAtlas or false,
	}
	local action = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.MergeKitbashPiece, metadata, self.modelInfo)
	local success, result = pcall(function()
		assert(Actions.ExecuteAction(self.modelInfo, action, nil, self.historyTool), "Invalid kitbash placement")
	end)
	pieceData.isMerging = false
	self.modelDisplay:SetRotationEnabled(true)
	if not success then
		pieceData.meshPart.Transparency = 0
		warn("Could not merge kitbash piece: " .. tostring(result))
		return
	end
	pieceData.meshPart.Transparency = 1
	pieceData.hasDrawnToAtlas = true
	pieceData.isMerged = true
	SendActionToServerEvent:FireServer(action)
end

function KitbashTool:CanEditCurrentPiece(): boolean
	local piece = self.currentlySelectedPiece and self.placedPieces[self.currentlySelectedPiece]
	return self.enabled
		and not self.isPlacing
		and not self.preparingSurface
		and not self.isEndingDrag
		and piece ~= nil
		and not piece.isMerging
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
		if InputUtils.isValidSelectingInput(input) and self:CanEditCurrentPiece() then
			if self.isRotating or self.isScaling or not self.inputManager:TryGrabLock(self) then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged and not self.useSurfaceAnchors then
				-- Unmerge so we can drag the visual piece again
				if not self:UnmergePiece(pieceData) then
					return
				end
			end
			local inputPosition = InputUtils.getInputPosition(input)
			local camera = workspace.CurrentCamera
			local markerPosition = pieceData.positionMarker.Position
			local screenPosition = camera:WorldToScreenPoint(markerPosition)
			-- Preserve the pointer's grab offset within the handle.
			self.dragPointerOffset = Vector2.new(screenPosition.X - inputPosition.X, screenPosition.Y - inputPosition.Y)
			self.dragPlanePoint = markerPosition
			self.dragPlaneNormal = camera.CFrame.LookVector
			self.isDragging = true
		end
	end)
	table.insert(self.connections, moveHandleInputBegan)

	local inputChanged = UserInputService.InputChanged:Connect(function(input)
		if self.isDragging and not self.isEndingDrag and InputUtils.isValidDraggingInput(input) then
			self:DragPiece(input)
		elseif self.isRotating and InputUtils.isValidDraggingInput(input) then
			self:RotatePiece(input)
		elseif self.isScaling and InputUtils.isValidDraggingInput(input) then
			self:ScalePiece(input)
		end
	end)
	table.insert(self.connections, inputChanged)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if InputUtils.isValidSelectingInput(input) then
			if self.isDragging then
				-- Apply the release position after any pending surface refresh.
				self.isEndingDrag = true
				while self.refreshingDragMesh do
					task.wait()
				end
				if self.isDragging then
					self:DragPiece(input)
				end
				self.isDragging = false
				self.isEndingDrag = false
				self:MergeCurrentPiece()
			elseif self.isRotating then
				if self.useSurfaceAnchors then
					self:RotatePiece(input)
				end
				self.isRotating = false
				self:MergeCurrentPiece()
			elseif self.isScaling then
				if self.useSurfaceAnchors then
					self:ScalePiece(input)
				end
				self.isScaling = false
				self:MergeCurrentPiece()
			end
		end
	end)
	table.insert(self.connections, inputEnded)

	local rotateHandleInputBegan = rotateHandle.InputBegan:Connect(function(input)
		if InputUtils.isValidSelectingInput(input) and self:CanEditCurrentPiece() then
			if self.isDragging or self.isScaling then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged and not self.useSurfaceAnchors then
				-- Unmerge so we can rotate the visual piece again
				self:UnmergePiece(pieceData)
			end
			self.isRotating = true
		end
	end)
	table.insert(self.connections, rotateHandleInputBegan)

	local scaleHandleInputBegan = scaleHandle.InputBegan:Connect(function(input)
		if InputUtils.isValidSelectingInput(input) and self:CanEditCurrentPiece() then
			if self.isDragging or self.isRotating then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			local pieceData = self.placedPieces[self.currentlySelectedPiece]
			if pieceData and pieceData.isMerged and not self.useSurfaceAnchors then
				-- Unmerge so we can scale the visual piece again
				self:UnmergePiece(pieceData)
			end

			self.isScaling = true

			local inputPosition = InputUtils.getInputPosition(input)
			self.mouseDownPos = inputPosition
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
	if not self.enabled or not self.currentlySelectedPiece then
		self.inputGui.Enabled = false
		return
	else
		self.inputGui.Enabled = true
	end

	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	local piece3dPos = pieceData.positionMarker.Position

	local worldRadius = pieceData.meshPart.Size.Magnitude * Constants.KITBASH_HANDLE_WORLD_RADIUS_FACTOR
	self.UIHandles:Refresh(piece3dPos, worldRadius, pieceData.rotation)
end

-- Update the mesh part's CFrame to reflect rotation and scale
function KitbashTool:UpdatePieceTransform(pieceData: KitbashPieceData, updateGeometry: boolean?)
	local baseCFrame = pieceData.positionMarker.CFrame

	local rotationCFrame = CFrame.Angles(0, 0, math.rad(pieceData.rotation))
	local finalCFrame = baseCFrame * rotationCFrame * KitbashData.GetPlacementRotation(pieceData.sourcePart)

	local baseSize = pieceData.sourcePart.Size
	pieceData.meshPart.Size = baseSize * pieceData.scale

	pieceData.meshPart.CFrame = finalCFrame
	if updateGeometry and self.useSurfaceAnchors and pieceData.isMerged then
		self:UpdateMergedPiece(pieceData)
	end
end

function KitbashTool:SelectPiece(sourcePart: MeshPart, minScale, maxScale)
	if self.isDragging or self.isRotating or self.isScaling then
		return
	end
	if self.isPlacing or self.preparingSurface or not self.enabled or not self.modelInfo:GetKitbashingEnabled() then
		return
	end
	self.isPlacing = true
	local success, message = pcall(function()
		self:PlacePiece(sourcePart, minScale, maxScale)
	end)
	self.isPlacing = false
	if not success then
		warn("Could not place kitbash piece: " .. tostring(message))
	end
end

function KitbashTool:PlacePiece(sourcePart: MeshPart, minScale, maxScale)
	self:MergeCurrentPiece()
	if not sourcePart:IsA("MeshPart") or not sourcePart:IsDescendantOf(KitbashPieces) then
		warn("Kitbash piece is no longer in ReplicatedStorage.KitbashPieces")
		return
	end
	local pieceName = sourcePart.Name

	-- Untextured pieces also consume an atlas slot.
	local atlasSlot = self:AllocateAtlasSlot()
	if not atlasSlot or #self.placedPieces >= Constants.ATLAS_MAX_KITBASH_PIECES then
		return
	end

	local meshParts = self.modelInfo:GetMeshParts()
	self:PreparePlacementSurfaces()
	if not self.enabled then
		return
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
	local placementMeshes, placementScales = self:GetPlacementMaps()

	local raycastResult = MeshUtils.RaycastAll(Ray.new(rayOrigin, rayDirection), placementMeshes, placementScales)

	if not raycastResult then
		-- Paired brows/lashes may have a gap at the part's center.
		local candidates = {}
		for part, mesh in placementMeshes do
			local scaleFactor = placementScales[part]
			for _, faceId in mesh:GetFaces() do
				local vertices = mesh:GetFaceVertices(faceId)
				local center = (
					mesh:GetPosition(vertices[1])
					+ mesh:GetPosition(vertices[2])
					+ mesh:GetPosition(vertices[3])
				) / 3
				local worldCenter = part.CFrame:PointToWorldSpace(center / scaleFactor)
				table.insert(candidates, worldCenter)
			end
		end
		table.sort(candidates, function(a, b)
			return (a - averagePos).Magnitude < (b - averagePos).Magnitude
		end)
		for _, point in candidates do
			raycastResult =
				MeshUtils.RaycastAll(Ray.new(rayOrigin, point - rayOrigin), placementMeshes, placementScales)
			if raycastResult then
				break
			end
		end
		if not raycastResult then
			warn("Could not raycast to place piece")
			return
		end
	end

	local targetMeshPart = raycastResult.meshPart

	-- Create kitbash piece to be transformed for editing
	-- This will indicate where to merge
	local piece = sourcePart:Clone()
	piece.Name = "KitbashPiece_" .. pieceName
	piece.CanCollide = false
	piece.Anchored = true
	piece.Transparency = if self.useSurfaceAnchors then 1 else 0

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

	local isMakeupAccessory = Constants.MAKEUP_ACCESSORY_ASSET_TYPES[self.modelInfo:GetServerEditTarget()] == true
	local scaleMultiplier = if isMakeupAccessory then Constants.MAKEUP_KITBASH_SCALE else 1
	local pieceMinScale = (minScale or Constants.DEFAULT_KITBASH_MIN_SCALE) * scaleMultiplier
	if isMakeupAccessory then
		pieceMinScale = math.max(pieceMinScale, Constants.MAKEUP_KITBASH_MIN_SCALE)
	end
	local newPieceData: KitbashPieceData = {
		name = pieceName,
		sourcePart = sourcePart,
		meshPart = piece,
		positionMarker = positionMarker,
		positionMarkerOffset = targetMeshPart.CFrame:ToObjectSpace(markerCFrame),
		targetMeshPart = targetMeshPart,
		normal = markerCFrame.LookVector,
		rotation = 0,
		scale = if isMakeupAccessory then Constants.MAKEUP_KITBASH_DEFAULT_SCALE else scaleMultiplier,
		minScale = pieceMinScale,
		maxScale = (maxScale or Constants.DEFAULT_KITBASH_MAX_SCALE) * scaleMultiplier,
		isMerged = false,
		isMerging = false,
		atlasSlot = atlasSlot,
	}

	table.insert(self.placedPieces, newPieceData)
	self.currentlySelectedPiece = #self.placedPieces
	if self.useSurfaceAnchors then
		self:SetSurfaceAnchor(newPieceData, raycastResult)
	else
		self:UpdatePieceTransform(newPieceData)
	end
	self:RefreshHandleUI()
	self:MergeCurrentPiece()
end

function KitbashTool:DragPiece(input)
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if not pieceData or self.refreshingDragMesh then
		return
	end

	if not self.useSurfaceAnchors then
		local meshInfo = self.modelInfo:GetMeshInfo()
		self.refreshingDragMesh = true
		local success, message = pcall(meshInfo.UpdateDeformedEditableMeshes, meshInfo)
		self.refreshingDragMesh = false
		if not success then
			warn("Could not refresh kitbash drag surface: " .. tostring(message))
			return
		end
	end
	if not self.enabled or not self.isDragging or self.placedPieces[self.currentlySelectedPiece] ~= pieceData then
		return
	end

	local inputPosition = InputUtils.getInputPosition(input)
	local pointer = Vector2.new(inputPosition.X, inputPosition.Y) + self.dragPointerOffset
	local ray = workspace.CurrentCamera:ScreenPointToRay(pointer.X, pointer.Y)
	local placementMeshes, placementScales = self:GetPlacementMaps()
	local raycastResult
	if self.useSurfaceAnchors then
		raycastResult = MeshUtils.RaycastOrFindNearestSurface(
			ray,
			placementMeshes,
			placementScales,
			self.dragPlanePoint,
			self.dragPlaneNormal
		)
	else
		raycastResult = MeshUtils.RaycastAll(ray, placementMeshes, placementScales)
	end

	if not raycastResult then
		return
	end
	if self.useSurfaceAnchors then
		if raycastResult.meshPart == pieceData.targetMeshPart then
			self:SetSurfaceAnchor(pieceData, raycastResult)
			self:UpdateMergedPiece(pieceData)
		end
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

	self:UpdatePieceTransform(pieceData, true)
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

	local inputPosition = InputUtils.getInputPosition(input)
	local mousePos = Vector2.new(inputPosition.X, inputPosition.Y)

	local deltaPos = mousePos - centerPos
	local angle = math.deg(math.atan2(deltaPos.Y, deltaPos.X))

	-- Account for cursor placement along handle
	pieceData.rotation = angle + 90 - styleTokens.RotateHandlePosDegrees

	self:UpdatePieceTransform(pieceData, true)
	self:RefreshHandleUI()
end

function KitbashTool:ScalePiece(input)
	local pieceData = self.placedPieces[self.currentlySelectedPiece]
	if not pieceData then
		return
	end

	local inputPosition = InputUtils.getInputPosition(input)
	if not self.mouseDownPos then
		self.mouseDownPos = inputPosition
		return
	end

	local scaleRotation = math.rad(pieceData.rotation - StyleConsts.styleTokens.ScaleHandlePosDegrees)
	local mouseMovement = inputPosition - self.mouseDownPos
	local scaleChange = (mouseMovement.X * math.cos(scaleRotation) + mouseMovement.Y * math.sin(scaleRotation))
		* Constants.SCALE_DRAG_SENSITIVITY
	pieceData.scale = math.clamp(pieceData.scale + scaleChange, pieceData.minScale, pieceData.maxScale)
	self.mouseDownPos = inputPosition

	self:UpdatePieceTransform(pieceData, true)
	self:RefreshHandleUI()
end

function KitbashTool:Destroy()
	self:Disable()
	for _, surface in self.placementSurfaces do
		surface:Destroy()
	end
	table.clear(self.placementSurfaces)
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
