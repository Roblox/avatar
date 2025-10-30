local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Utils = require(Modules:WaitForChild("Utils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local BoundsValidation = Modules:WaitForChild("BoundsValidation")
local UGCBoundsUtil = require(BoundsValidation:WaitForChild("UGCBoundsUtil"))
local BoundsConstants = require(BoundsValidation:WaitForChild("BoundsConstants"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local MeshWidgetUtils = {}

local controlEndpointKeys = {
	"controlP1",
	"controlP2",
	"controlP3",
	"controlP4",
}

local function GetMeshPartScaleFactor(meshInfo: MeshInfo.MeshInfo)
	assert(meshInfo.cageInfo ~= nil, "MeshInfo needs to have cageInfo for deformation")
	return meshInfo.cageInfo.initialSize / meshInfo.meshPart.Size
end

local function GetOffsetMeshPartCFrame(meshInfo: MeshInfo.MeshInfo, scaleFactor: Vector3, offset: Vector3)
	local meshPart = meshInfo.meshPart
	local worldSpaceOffset = meshPart.CFrame:VectorToWorldSpace(offset * scaleFactor)
	local partRotationOnly = meshPart.CFrame - meshPart.CFrame.Position
	return partRotationOnly + (meshPart.Position - worldSpaceOffset)
end

-- originalSize should be bigger than minSize and smaller than maxSize on all axes
local function ValidateOriginalSizeFromLimits(outOfBoundsData: UGCBoundsUtil.OutOfBoundsData)
	local originalScaleFromMin = outOfBoundsData.originalSize / outOfBoundsData.minSize
	if originalScaleFromMin.X < 1 or originalScaleFromMin.Y < 1 or originalScaleFromMin.Z < 1 then
		error(
			string.format(
				"Combined original size of (%s) for all parts in %s is smaller than the minimum size of (%s). If you are seeing this error you need to adjust the mesh sizes of the base body for this experience.",
				tostring(outOfBoundsData.originalSize),
				outOfBoundsData.assetTypeEnum.Name,
				tostring(outOfBoundsData.minSize)
			)
		)
	end
	local originalScaleFromMax = outOfBoundsData.maxSize / outOfBoundsData.originalSize
	if originalScaleFromMax.X < 1 or originalScaleFromMax.Y < 1 or originalScaleFromMax.Z < 1 then
		error(
			string.format(
				"Combined original size of (%s) for all parts in %s is larger than the maximum size of (%s). If you are seeing this error you need to adjust the mesh sizes of the base body for this experience.",
				tostring(outOfBoundsData.originalSize),
				outOfBoundsData.assetTypeEnum.Name,
				tostring(outOfBoundsData.maxSize)
			)
		)
	end
end

local function GetScaleFactorFromVectorComponent(outOfBoundsData: UGCBoundsUtil.OutOfBoundsData, key: string)
	local originalSizeComp = outOfBoundsData.originalSize[key]
	local currentSizeComp = outOfBoundsData.size[key]
	local minSizeComp = outOfBoundsData.minSize[key]
	local maxSizeComp = outOfBoundsData.maxSize[key]

	if currentSizeComp >= minSizeComp and currentSizeComp <= maxSizeComp then
		return 1
	end

	local scaleFromOriginal = currentSizeComp / originalSizeComp

	local diffFromOriginal, diffFromLimit

	if scaleFromOriginal < 1 then
		diffFromOriginal = (originalSizeComp - currentSizeComp) / originalSizeComp
		diffFromLimit = (originalSizeComp - minSizeComp) / originalSizeComp
	else
		diffFromOriginal = (currentSizeComp - originalSizeComp) / originalSizeComp
		diffFromLimit = (maxSizeComp - originalSizeComp) / originalSizeComp
	end

	return diffFromLimit / diffFromOriginal
end

local function GetWidgetScaleFactor(
	currentPosition: Vector3,
	startPosition: Vector3,
	outOfBoundsDatas: { UGCBoundsUtil.OutOfBoundsData }
)
	local scaleFactorX = math.huge
	local scaleFactorY = math.huge
	local scaleFactorZ = math.huge

	for _, outOfBoundsData in outOfBoundsDatas do
		ValidateOriginalSizeFromLimits(outOfBoundsData)

		scaleFactorX = math.min(scaleFactorX, GetScaleFactorFromVectorComponent(outOfBoundsData, "X"))
		scaleFactorY = math.min(scaleFactorY, GetScaleFactorFromVectorComponent(outOfBoundsData, "Y"))
		scaleFactorZ = math.min(scaleFactorZ, GetScaleFactorFromVectorComponent(outOfBoundsData, "Z"))
	end

	return math.min(scaleFactorX, math.min(scaleFactorY, scaleFactorZ))
end

local function GetNewControlPosition(currentPosition: Vector3, startPosition: Vector3, scaleFactor: number)
	local direction = currentPosition - startPosition
	return startPosition + (direction.Unit * (direction.Magnitude * scaleFactor * BoundsConstants.BoundsPadding))
end

local function GetInitialSimMeshInfo(meshInfoClass: MeshInfo.MeshInfoClass)
	local initialMeshInfo = {} :: BoundsConstants.SimMeshInfos
	for part, meshInfo: MeshInfo.MeshInfo in meshInfoClass:GetModelMeshInfo() do
		if not meshInfo.cageInfo then
			continue
		end

		local scaleFactor = GetMeshPartScaleFactor(meshInfo)
		local initialVertexPositions = meshInfo.cageInfo.initialVertexPositionsMap
		local scaledVertices = {}
		for vertexId, vertexPos in initialVertexPositions do
			scaledVertices[vertexId] = vertexPos / scaleFactor
		end

		initialMeshInfo[part.Name] = {
			Verts = scaledVertices,
			CFrame = meshInfo.meshPart.CFrame,
		} :: BoundsConstants.SimMeshInfo
	end

	return initialMeshInfo
end

local function GetDeformedSimMeshInfo(meshInfoClass: MeshInfo.MeshInfoClass, widget: MeshInfo.WidgetData)
	local deformedMeshInfo = {} :: BoundsConstants.SimMeshInfos
	for _, deformedPartName in widget.deformsPartNames do
		local meshInfo: MeshInfo.MeshInfo = meshInfoClass:GetMeshInfoByName(deformedPartName)

		local widgets = {widget}
		if widget.mirroredWidget then
			table.insert(widgets, widget.mirroredWidget)
		end

		local deformedPositions = MeshWidgetUtils.GetDeformedMeshData(meshInfoClass, widgets, deformedPartName)
		local min, max = MeshUtils.GetVertexBounds(deformedPositions)
	
		local center = (min + max) / 2
		local scaleFactor = GetMeshPartScaleFactor(meshInfo)
		local newCFrame = GetOffsetMeshPartCFrame(meshInfo, scaleFactor, -center)
		for vertexId, vertexPos in deformedPositions do
			deformedPositions[vertexId] = (vertexPos - center) / scaleFactor
		end

		if not next(deformedPositions) then
			continue
		end

		deformedMeshInfo[deformedPartName] = {
			Verts = deformedPositions,
			CFrame = newCFrame,
		} :: BoundsConstants.SimMeshInfo
	end

	return deformedMeshInfo
end

local function CombineSimMeshInfo(
	meshInfoClass: MeshInfo.MeshInfoClass,
	initialMeshInfo: BoundsConstants.SimMeshInfos,
	deformedMeshInfo: BoundsConstants.SimMeshInfos
)
	for part, meshInfo: MeshInfo.MeshInfo in meshInfoClass:GetModelMeshInfo() do
		local initialInfoForPart: BoundsConstants.SimMeshInfo = initialMeshInfo[part.Name]
		local deformedInfoForPart: BoundsConstants.SimMeshInfo = deformedMeshInfo[part.Name]

		if not deformedInfoForPart and initialInfoForPart then
			deformedMeshInfo[part.Name] = initialInfoForPart
		end
	end
end

local function CopyWidgetData(widgetData: MeshInfo.WidgetData, newPosition: Vector3) : MeshInfo.WidgetData
	local oldMirroredWidget = widgetData.mirroredWidget
	widgetData.mirroredWidget = nil
	local widgetDataCopy = Utils.DeepCopy(widgetData)
	widgetDataCopy.position = newPosition

	if oldMirroredWidget then
		widgetDataCopy.mirroredWidget = Utils.DeepCopy(oldMirroredWidget)
		widgetDataCopy.mirroredWidget.position = widgetDataCopy.position * Vector3.new(-1, 1, 1)
	end 

	-- Restore mirrored widget
	widgetData.mirroredWidget = oldMirroredWidget

	return widgetDataCopy
end

local function CopyWidgetControl(widgetDataCopy: MeshInfo.WidgetData, widgetControl: MeshInfo.WidgetControl)
	local widgetControlCopy = {}
	for key, value in widgetControl :: { [any]: any } do
		widgetControlCopy[key] = value
	end

	if widgetControlCopy.controlType == "Line" then
		-- Calculate how far the widget has moved along the line
		local lineDirection = (widgetControlCopy.controlP2 - widgetControlCopy.controlP1)
		local closestLinePoint = Utils.GetClosestPointOn3dLineSegment(
			widgetDataCopy.position,
			widgetControlCopy.controlP1,
			widgetControlCopy.controlP2
		)
		local controlLinearProgress = (closestLinePoint - widgetControlCopy.controlP1).Magnitude
			/ lineDirection.Magnitude

		widgetControlCopy.linearProgress = controlLinearProgress
		widgetDataCopy.activeControl = widgetControlCopy
	end
end

local function SimulateWidgetMoved(
	meshInfoClass: MeshInfo.MeshInfoClass,
	widgetData: MeshInfo.WidgetData,
	widgetControl: MeshInfo.WidgetControl,
	newPosition: Vector3
)
	local widgetDataCopy = CopyWidgetData(widgetData, newPosition)

	CopyWidgetControl(widgetDataCopy, widgetControl)
	if widgetDataCopy.mirroredWidget then
		CopyWidgetControl(widgetDataCopy.mirroredWidget, widgetControl)
	end

	local initialMeshInfo = GetInitialSimMeshInfo(meshInfoClass)
	local deformedMeshInfo = GetDeformedSimMeshInfo(meshInfoClass, widgetDataCopy)
	CombineSimMeshInfo(meshInfoClass, initialMeshInfo, deformedMeshInfo)

	return initialMeshInfo, deformedMeshInfo
end

local function GetFixedControlPositions(
	meshInfoClass: MeshInfo.MeshInfoClass,
	widgetControl: MeshInfo.WidgetControl,
	widgetData: MeshInfo.WidgetData
)
	local fixedControlPositions = {}
	for _, key in controlEndpointKeys do
		local controlPosition = widgetControl[key]
		if controlPosition then
			local initialMeshInfo, deformedMeshInfo =
				SimulateWidgetMoved(meshInfoClass, widgetData, widgetControl, controlPosition)
			local outOfBoundsDatas =
				UGCBoundsUtil.ValidateBounds(initialMeshInfo, deformedMeshInfo, widgetData.deformsPartNames)
		
			if outOfBoundsDatas and #outOfBoundsDatas > 0 then
				local scaleFactor = GetWidgetScaleFactor(controlPosition, widgetData.startPosition, outOfBoundsDatas)
				fixedControlPositions[key] =
					GetNewControlPosition(controlPosition, widgetData.startPosition, scaleFactor)
			end
		end
	end
	return fixedControlPositions
end

local function UpdateWidgetControl(
	widgetControl: MeshInfo.WidgetControl,
	widgetData: MeshInfo.WidgetData,
	fixedControlPositions
)
	for key, controlPosition in fixedControlPositions do
		widgetControl[key] = controlPosition
	end

	if widgetControl.controlType == "Line" then
		local oldStartLinearProgress = widgetControl.startLinearProgress
		local lineDirection = (widgetControl.controlP2 - widgetControl.controlP1)
		widgetControl.startLinearProgress = (widgetData.startPosition - widgetControl.controlP1).Magnitude
			/ lineDirection.Magnitude
		widgetControl.linearProgress = widgetControl.startLinearProgress
		widgetData.radius = widgetData.radius
			* (1 - math.abs(widgetControl.startLinearProgress - oldStartLinearProgress))
			* BoundsConstants.BoundsPadding
	end
end

-- Deform a single vertex based on the widget's position
local function DeformSingleVertex(
	vertexPos: Vector3,
	widgetData: MeshInfo.WidgetData,
	startPosition: Vector3,
	currentPosition: Vector3
)
	if widgetData.widgetType == Constants.WIDGET_TYPE_SPHERE then
		local widgetOffset = currentPosition - startPosition
		local distance = (vertexPos - startPosition).Magnitude
		if distance <= widgetData.radius then
			local falloff = 1 - math.clamp(distance / widgetData.radius, 0, 1)

			local newDeformedPos = vertexPos + widgetOffset * falloff * 0.5
			return newDeformedPos
		end
		return vertexPos
	end

	local activeLineControl = widgetData.activeControl :: MeshInfo.LineWidgetControl?
	if not activeLineControl then
		return vertexPos
	end

	if widgetData.widgetType == Constants.WIDGET_TYPE_GROW_SHRINK then
		local offset = vertexPos - startPosition
		local distance = offset.Magnitude
		if distance <= widgetData.radius then
			local falloff = 1 - math.clamp(distance / widgetData.radius, 0, 1)

			local newDeformedPos = vertexPos
				+ offset * falloff * (activeLineControl.linearProgress - activeLineControl.startLinearProgress)
			return newDeformedPos
		end
	elseif widgetData.widgetType == Constants.WIDGET_TYPE_AXIS_STRETCH then
		assert(widgetData.meshSpaceAxisStart ~= nil, "Axis stretch widget has no meshSpaceAxisStart")

		local axisDirection = widgetData.meshSpaceAxisStart.Direction
		local offset = vertexPos - widgetData.meshSpaceAxisStart.Origin
		local axisProjection = offset:Dot(axisDirection) * axisDirection.Unit
		local distance = offset.Magnitude
		if distance <= widgetData.radius then
			local falloff = 1 - math.clamp(distance / widgetData.radius, 0, 1)

			local newDeformedPos = vertexPos
				+ axisProjection
					* falloff
					* (activeLineControl.linearProgress - activeLineControl.startLinearProgress)
			return newDeformedPos
		end
	elseif widgetData.widgetType == Constants.WIDGET_TYPE_CYLINDER then
		assert(widgetData.meshSpaceAxisStart ~= nil, "Cylinder widget has no meshSpaceAxisStart")

		local closestPoint = widgetData.meshSpaceAxisStart:ClosestPoint(vertexPos)
		local offset = vertexPos - closestPoint
		local distanceToAxis = offset.Magnitude
		if distanceToAxis <= widgetData.radius then
			-- Move this vertex in relation to the axis
			local falloff = 1 - math.clamp(distanceToAxis / widgetData.radius, 0, 1)

			local newDeformedPos = vertexPos
				+ offset * falloff * (activeLineControl.linearProgress - activeLineControl.startLinearProgress)
			return newDeformedPos
		end
	elseif widgetData.widgetType == Constants.WIDGET_TYPE_MUSCLE then
		if widgetData.meshSpaceAxisStart == nil then
			error("Muscle widget has no meshSpaceAxisStart")
		end

		local closestPointOnSegment, t = Utils.GetClosestPointOn3dLineSegment(
			vertexPos,
			widgetData.meshSpaceAxisStart.Origin,
			widgetData.meshSpaceAxisEnd
		)
		if t < 0 or t > 1 then
			t = 0
		end
		local distanceFromCenter = math.abs(0.5 - math.abs(t - 0.5)) * 2
		local offset = vertexPos - closestPointOnSegment
		local distanceToAxis = offset.Magnitude
		local falloff = 1 - math.clamp(distanceToAxis / widgetData.radius, 0, 1)
		falloff = falloff * distanceFromCenter

		local newDeformedPos = vertexPos
			+ offset * falloff * (activeLineControl.linearProgress - activeLineControl.startLinearProgress) * 2
		return newDeformedPos
	else
		print("No widget type found for widgetData.widgetType: ", widgetData.widgetType)
		return vertexPos
	end

	-- If we get here, this vertex was not affected by the widget
	return vertexPos
end

function MeshWidgetUtils.WidgetDeformsPart(widgetData: MeshInfo.WidgetData, partName: string)
	for _, deformedPartName in widgetData.deformsPartNames do
		if deformedPartName == partName then
			return true
		end
	end
	return false
end

function MeshWidgetUtils.GetDeformedMeshData(
	meshInfoClass: MeshInfo.MeshInfoClass,
	widgets: { [any]: MeshInfo.WidgetData },
	deformedPartName: string
)
	local meshInfo: MeshInfo.MeshInfo = meshInfoClass:GetMeshInfoByName(deformedPartName)

	assert(meshInfo.cageInfo ~= nil, "MeshInfo needs to have cageInfo for deformation")

	local initialCageVertexPositions = meshInfo.cageInfo.initialVertexPositionsMap

	local deformedPositions = {}

	for _, widgetData: MeshInfo.WidgetData in widgets do
		if widgetData.startPosition == widgetData.position then
			continue
		end

		if not MeshWidgetUtils.WidgetDeformsPart(widgetData, deformedPartName) then
			continue
		end

		local startPosition = widgetData.startPosition
		local currentPosition = widgetData.position
		if widgetData.meshPart.Name ~= deformedPartName then
			local worldStartPosition = widgetData.meshPart.CFrame:PointToWorldSpace(startPosition)
			startPosition = meshInfo.meshPart.CFrame:PointToObjectSpace(worldStartPosition)

			local worldCurrentPosition = widgetData.meshPart.CFrame:PointToWorldSpace(currentPosition)
			currentPosition = meshInfo.meshPart.CFrame:PointToObjectSpace(worldCurrentPosition)
		end

		for vertexId, vertexPos in pairs(initialCageVertexPositions) do
			local currentDeformedPos = deformedPositions[vertexId]
			if currentDeformedPos == nil then
				currentDeformedPos = vertexPos
			end

			-- We transform the cage vertex into MeshPart space for deformation calculations
			vertexPos = meshInfo.cageInfo.cageOrigin * vertexPos
			local deformedPos = DeformSingleVertex(vertexPos, widgetData, startPosition, currentPosition)

			-- We don't need to transform back since we are getting the diff caused by the deformation here
			local diff: Vector3 = deformedPos - vertexPos
			deformedPositions[vertexId] = currentDeformedPos + diff
		end
	end

	return deformedPositions
end

function MeshWidgetUtils.FixupWidgets(meshInfo: MeshInfo.MeshInfoClass)
	for _, widgetData in meshInfo:GetAllWidgets() do
		for _, widgetControl in widgetData.controls do
			UpdateWidgetControl(
				widgetControl,
				widgetData,
				GetFixedControlPositions(meshInfo, widgetControl, widgetData)
			)
		end
	end
end

return MeshWidgetUtils
