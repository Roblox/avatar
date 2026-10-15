-- Processes actions for layer management on the client and server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type definitions

local LayerEditActions = {}

export type BasicGroupActionMetaData = {
	groupId: string,
	targetMeshPartName: string,
}

export type BasicLayerActionMetaData = {
	targetLayerInfo: GroupInfo.TargetLayerInfo,
	targetMeshPartName: string,
}

local function isBasicGroupActionValid(modelInfo, actionMetaData, shouldExist)
	local groupId = actionMetaData.groupId
	if not groupId or type(groupId) ~= "string" then
		return false, "Invalid groupId"
	end

	local targetMeshPartName = actionMetaData.targetMeshPartName
	if not targetMeshPartName or type(targetMeshPartName) ~= "string" then
		return false, "Invalid target mesh part name"
	end
	local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)
	if not targetMeshPart then
		return false, "Target mesh part not found"
	end

	local textureInfo = modelInfo:GetTextureInfo()
	if shouldExist and not textureInfo:GetGroup(targetMeshPart, groupId) then
		return false, "Group does not exist"
	elseif not shouldExist and textureInfo:GetGroup(targetMeshPart, groupId) then
		return false, "Group already exists"
	end

	return true
end

local function isBasicLayerActionValid(modelInfo, actionMetaData, shouldExist)
	local textureInfo = modelInfo:GetTextureInfo()

	local targetLayerInfo = actionMetaData.targetLayerInfo
	if not targetLayerInfo then
		return false, "Invalid targetLayerInfo"
	end

	local groupId = targetLayerInfo.groupId
	if not groupId or type(groupId) ~= "string" then
		return false, "Invalid groupId"
	end

	-- Validate group and target mesh part; group should always exist.
	local isValid, reason = isBasicGroupActionValid(
		modelInfo,
		{ groupId = groupId, targetMeshPartName = actionMetaData.targetMeshPartName },
		true
	)
	if not isValid then
		return false, reason
	end

	local layerId = targetLayerInfo.layerId
	if not layerId or type(layerId) ~= "string" then
		return false, "Invalid layerId"
	end

	local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
	if shouldExist and not textureInfo:HasLayer(targetMeshPart, targetLayerInfo) then
		return false, "Layer does not exist"
	elseif not shouldExist and textureInfo:HasLayer(targetMeshPart, targetLayerInfo) then
		return false, "Layer already exists"
	end

	return true
end

export type AddLayerActionMetaData = BasicLayerActionMetaData

LayerEditActions.AddLayerAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local isValid, reason = isBasicLayerActionValid(modelInfo, actionMetaData, false)
		if not isValid then
			return false, reason
		end

		local targetLayerInfo = actionMetaData.targetLayerInfo
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)

		if
			#textureInfo:GetGroup(targetMeshPart, targetLayerInfo.groupId).inputLayers >= Constants.MAX_LAYERS_PER_GROUP
		then
			return false, "Maximum layer count reached"
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local targetLayerInfo = actionMetaData.targetLayerInfo
		local targetMeshPartName = actionMetaData.targetMeshPartName

		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)
		textureInfo:GetOrCreateLayer(targetMeshPart, targetLayerInfo)
		textureInfo:UpdateOutputColorMap(targetMeshPart)
	end,
}

export type DeleteLayerActionMetaData = BasicLayerActionMetaData

LayerEditActions.DeleteLayerAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local isValid, reason = isBasicLayerActionValid(modelInfo, actionMetaData, true)
		if not isValid then
			return false, reason
		end

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()

		if #textureInfo:GetGroup(targetMeshPart, actionMetaData.targetLayerInfo.groupId).inputLayers <= 0 then
			return false, "No layers to delete"
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData, _, historyTool: any?)
		local targetLayerInfo = actionMetaData.targetLayerInfo
		local targetMeshPartName = actionMetaData.targetMeshPartName

		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)
		textureInfo:RemoveLayer(targetMeshPart, targetLayerInfo, --[[DestroyEI = ]]true)

		local currentTarget = textureInfo:GetTargetLayerInfo()
		if currentTarget.layerId == targetLayerInfo.layerId and currentTarget.groupId == targetLayerInfo.groupId then
			textureInfo:SetTargetLayerInfo({ groupId = nil, layerId = Constants.BRUSH_LAYER })
		end

		if historyTool then
			historyTool:clearIfTrackingLayer(targetMeshPartName, targetLayerInfo)
		end
	end,
}

export type SetTargetLayerActionMetaData = BasicLayerActionMetaData

LayerEditActions.SetTargetLayerAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		return isBasicLayerActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		textureInfo:SetActiveGroup(actionMetaData.targetLayerInfo.groupId)
		textureInfo:SetTargetLayerInfo(actionMetaData.targetLayerInfo)
	end,
}

export type MoveLayerActionMetaData = BasicLayerActionMetaData & {
	direction: number, --[[ 1 for down, -1 for up ]]
}

LayerEditActions.MoveLayerAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local direction = actionMetaData.direction
		if direction ~= 1 and direction ~= -1 then
			return false, "Invalid direction"
		end

		return isBasicLayerActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPartName = actionMetaData.targetMeshPartName
		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)

		local targetLayerInfo = actionMetaData.targetLayerInfo
		local direction = actionMetaData.direction

		textureInfo:MoveLayerInGroup(targetMeshPart, targetLayerInfo, direction)
	end,
}

export type SetLayerOpacityActionMetaData = BasicLayerActionMetaData & {
	opacity: number,
}

LayerEditActions.SetLayerOpacityAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local opacity = actionMetaData.opacity
		if type(opacity) ~= "number" or opacity ~= opacity or opacity < 0 or opacity > 1 then
			return false, "Invalid opacity"
		end

		return isBasicLayerActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		textureInfo:SetLayerOpacity(targetMeshPart, actionMetaData.targetLayerInfo, actionMetaData.opacity)
	end,
}

export type SetLayerVisibilityActionMetaData = BasicLayerActionMetaData & {
	isVisible: boolean,
}

LayerEditActions.SetLayerVisibilityAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		if type(actionMetaData.isVisible) ~= "boolean" then
			return false, "Invalid visibility"
		end

		return isBasicLayerActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		textureInfo:SetLayerVisible(targetMeshPart, actionMetaData.targetLayerInfo, actionMetaData.isVisible)
	end,
}

export type AddGroupActionMetaData = BasicGroupActionMetaData & {
	makeupAssetType: string?,
}

local function getMakeupGroupPool(assetType: string?): string?
	return assetType and Constants.MAKEUP_ASSET_TYPE_TO_POOL[assetType] or nil
end

LayerEditActions.AddGroupAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local isValid, reason = isBasicGroupActionValid(modelInfo, actionMetaData, false)
		if not isValid then
			return false, reason
		end

		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local existingGroups = textureInfo:GetAllGroups(targetMeshPart)

		local newPool = getMakeupGroupPool(actionMetaData.makeupAssetType)
		if newPool then
			-- Makeup group: cap against its pool's shared limit.
			local count = 0
			for _, group in existingGroups do
				if getMakeupGroupPool(group.makeupAssetType) == newPool then
					count += 1
				end
			end
			if count >= Constants.MAKEUP_POOL_GROUP_LIMITS[newPool] then
				return false, "Maximum number of makeup items reached"
			end
		elseif #existingGroups >= Constants.MAX_GROUPS then
			-- Non-makeup group: fall back to the flat total cap.
			return false, "Maximum group count reached"
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local groupId = actionMetaData.groupId
		local targetMeshPartName = actionMetaData.targetMeshPartName

		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)
		textureInfo:CreateGroup(targetMeshPart, groupId, actionMetaData.makeupAssetType)

		-- Make the new group active so its (soon-to-be-added) default layer is
		-- created as a live EditableImage.
		textureInfo:SetActiveGroup(groupId)
	end,
}

export type DeleteGroupActionMetaData = BasicGroupActionMetaData

LayerEditActions.DeleteGroupAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		return isBasicGroupActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData, _, historyTool: any?)
		local groupId = actionMetaData.groupId
		local targetMeshPartName = actionMetaData.targetMeshPartName

		local textureInfo = modelInfo:GetTextureInfo()

		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)
		textureInfo:DeleteGroup(targetMeshPart, groupId)

		-- Only clear the active group when the deleted group was the active one;
		-- deleting an inactive group must not deactivate the current group.
		if textureInfo:GetActiveGroupId() == groupId then
			textureInfo:SetActiveGroup(nil)
		end

		local currentTarget = textureInfo:GetTargetLayerInfo()
		if currentTarget.groupId == groupId then
			textureInfo:SetTargetLayerInfo({ groupId = nil, layerId = Constants.BRUSH_LAYER })
		end

		if historyTool then
			historyTool:clearIfTrackingGroup(targetMeshPartName, groupId)
		end
	end,
}

export type SetTargetGroupActionMetaData = BasicGroupActionMetaData

LayerEditActions.SetTargetGroupAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		return isBasicGroupActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()

		-- Keep the selected group's layers live (and cache the previous group's).
		textureInfo:SetActiveGroup(actionMetaData.groupId)

		-- Selecting a group without a specific layer targets the brush layer,
		-- matching the behavior when a selected group is deleted.
		textureInfo:SetTargetLayerInfo({ groupId = nil, layerId = Constants.BRUSH_LAYER })
	end,
}

export type MoveGroupActionMetaData = BasicGroupActionMetaData & {
	direction: number, --[[ 1 for down, -1 for up ]]
}

LayerEditActions.MoveGroupAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		local direction = actionMetaData.direction
		if direction ~= 1 and direction ~= -1 then
			return false, "Invalid direction"
		end

		return isBasicGroupActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPartName = actionMetaData.targetMeshPartName
		local targetMeshPart = modelInfo:GetMeshPartByName(targetMeshPartName)

		local groupId = actionMetaData.groupId
		local direction = actionMetaData.direction

		textureInfo:MoveGroup(targetMeshPart, groupId, direction)
	end,
}

export type SetGroupVisibilityActionMetaData = BasicGroupActionMetaData & {
	isVisible: boolean,
}

LayerEditActions.SetGroupVisibilityAction = {
	IsValidAction = function(modelInfo, actionMetaData)
		if type(actionMetaData.isVisible) ~= "boolean" then
			return false, "Invalid visibility"
		end

		return isBasicGroupActionValid(modelInfo, actionMetaData, true)
	end,
	ExecuteAction = function(modelInfo, actionMetaData)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		textureInfo:SetGroupVisible(targetMeshPart, actionMetaData.groupId, actionMetaData.isVisible)
	end,
}

return LayerEditActions
