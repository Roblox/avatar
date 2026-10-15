--[[
    Identical to the sticker tool except "committing" a stamp bakes it into the layer. From there it
    can be modified by normal texture editing tools but cannot be altered via the editHandle anymore
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local StickerTool = require(script.Parent:WaitForChild("StickerTool"))

local StampTool = setmetatable({}, { __index = StickerTool })
StampTool.__index = StampTool

function StampTool.new(modelInfo, inputManager, historyTool, openConfirmBakeModal: () -> ())
	local self = StickerTool.new(modelInfo, inputManager)
	setmetatable(self, StampTool)
	self.minScale = Constants.MIN_STAMP_SCALE
	if modelInfo.blankData.isMakeupAccessory then
		self.defaultScale = Constants.MAKEUP_ACCESSORY_STAMP_SCALE
	end
	self.maxScale = self.defaultScale * Constants.MAX_STAMP_SCALE_MULTIPLIER
	-- Stamps mirror by default
	self.objectSpaceMirrorPlane = CFrame.identity
	self.openConfirmBakeModal = openConfirmBakeModal
	self.onBakeConfirmed = nil
	-- Used to record each bake as a single undo step (see CommitStamp).
	self.historyTool = historyTool
	return self
end

-- Override the sticker tool allocation with the separate layer.
function StampTool:AllocateLayer()
	return Constants.STAMP_LAYER_NUMBER
end

-- Whether a stamp is currently being positioned (placed but not yet baked).
function StampTool:HasActiveStamp(): boolean
	return self.appliedStickers[self.currentlySelectedSticker] ~= nil
end

-- Bake the currently-selected stamp down onto the selected brush layer and drop it from the live
-- sticker list
function StampTool:CommitStamp()
	local stamp = self.appliedStickers[self.currentlySelectedSticker]
	if stamp == nil then
		return
	end

	local bakeStampActionMetadata = {
		targetMeshPartName = stamp.targetMeshPart.Name,
		stickerLayerNumber = stamp.stickerLayerNumber,
		-- Carries the stamp's projection so both peers can record a replay-safe undo step.
		projection = stamp.projectionParams,
	}

	local bakeStampAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.BakeStamp, bakeStampActionMetadata, self.modelInfo)
	-- Passing the historyTool records this bake as one undo step (moving the stamp is not tracked).
	Actions.ExecuteAction(self.modelInfo, bakeStampAction, nil, self.historyTool)

	local textureInfo = self.modelInfo:GetTextureInfo()
	textureInfo:UpdateOutputColorMap(stamp.targetMeshPart)

	SendActionToServerEvent:FireServer(bakeStampAction)

	table.remove(self.appliedStickers, self.currentlySelectedSticker)

	if self.currentlySelectedSticker == #self.appliedStickers + 1 then
		self.currentlySelectedSticker = #self.appliedStickers
	end

	self.stickerCounter = self.stickerCounter - 1
	self:RefreshHandleUI()

	stamp.positionMarker:Destroy()

	if self.onBakeConfirmed then
		self.onBakeConfirmed()
		self.onBakeConfirmed = nil
	end
end

-- This function sets a new stamp to be actively being placed. Selecting a new stamp commits the
-- one currently being positioned first, confirming via the modal.
function StampTool:ApplySticker(imageAssetId)
	if not self:HasActiveStamp() then
		StickerTool.ApplySticker(self, imageAssetId)
		return
	end

	self.onBakeConfirmed = function()
		StickerTool.ApplySticker(self, imageAssetId)
	end
	self.openConfirmBakeModal()
end

-- Called from the panel's x button. When a stamp is being positioned we confirm the bake through the
-- modal and only run the continuation once the user merges; otherwise the continuation runs now.
function StampTool:RequestBake(onConfirmed: () -> ())
	if not self:HasActiveStamp() then
		onConfirmed()
		return
	end

	self.onBakeConfirmed = onConfirmed
	self.openConfirmBakeModal()
end

-- Silently bake the active stamp before the tool is hidden so nothing is left un-committed when
-- switching tools or leaving editing. No modal is shown on this path.
function StampTool:Disable()
	self:CancelPendingPlacement()
	self:CommitStamp()
	-- Free the stamp layer now that the tool is idle; it will be lazily recreated on next use.
	self.modelInfo:GetTextureInfo():ReleaseStampEditableImage()
	StickerTool.Disable(self)
end

function StampTool:CancelPendingBake(): ()
	self.onBakeConfirmed = nil
end

function StampTool:Destroy()
	self:CancelPendingPlacement()
	self:CancelPendingBake()
	self:CommitStamp()
	self.modelInfo:GetTextureInfo():ReleaseStampEditableImage()
	StickerTool.Destroy(self)
end

return StampTool
