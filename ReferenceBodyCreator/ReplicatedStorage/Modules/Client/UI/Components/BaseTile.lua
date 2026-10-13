--[[
	Generic interactive tile displaying a thumbnail, for use in a grid system. Used for
	stickers and kitbashing.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

local VIEWPORT_AMBIENT = Color3.new(1, 1, 1)
local VIEWPORT_LIGHT_COLOR = Color3.new(1, 1, 1)
local VIEWPORT_LIGHT_DIRECTION = Vector3.new(0, -1, -1)
local VIEWPORT_FIELD_OF_VIEW = 25

local BaseTile = {}

export type ViewportOptions = {
	ambient: Color3?,
	lightColor: Color3?,
	lightDirection: Vector3?,
	fieldOfView: number?,
	fitPadding: number?, -- Multiplier for the automatic camera fit; 1 fills the tile.
	cameraCFrame: CFrame?,
	preserveAnchoring: boolean?,
}

local function createFrame(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "BaseTile"
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.BaseTile)
	return frame
end

local function createTextButton(frame: Frame, onButtonActivated: (() -> ())?): TextButton
	local button = Instance.new("TextButton")
	button.Name = "TextButton"
	button.Text = ""
	button.Parent = frame

	if onButtonActivated then
		button.Activated:Connect(onButtonActivated)
	else
		button.Active = false
		button.Interactable = false
	end

	StyleUtils.AddStyleTag(button, StyleConsts.tags.BaseTileButton)
	return button
end

function BaseTile.createComponentFrame(image: (string | Content)?, onButtonActivated: (() -> ())?)
	local frame = createFrame()

	if not image then
		return frame
	end

	local button, icon = IconButton.createComponentFrame(image, onButtonActivated)
	button.Parent = frame
	if not onButtonActivated then
		button.Interactable = false
	end
	StyleUtils.AddStyleTag(button, StyleConsts.tags.BaseTileButton)

	return frame, icon
end

-- Convert options with nil values to default values, so that we don't have to check for nil values later
local function resolveOptions(options: ViewportOptions?): ViewportOptions
	if not options then
		return {
			ambient = VIEWPORT_AMBIENT,
			lightColor = VIEWPORT_LIGHT_COLOR,
			lightDirection = VIEWPORT_LIGHT_DIRECTION,
			fieldOfView = VIEWPORT_FIELD_OF_VIEW,
			fitPadding = 1,
		}
	end

	local resolvedOptions = {}

	resolvedOptions.ambient = options.ambient or VIEWPORT_AMBIENT
	resolvedOptions.lightColor = options.lightColor or VIEWPORT_LIGHT_COLOR
	resolvedOptions.lightDirection = options.lightDirection or VIEWPORT_LIGHT_DIRECTION
	resolvedOptions.fieldOfView = options.fieldOfView or VIEWPORT_FIELD_OF_VIEW
	resolvedOptions.fitPadding = options.fitPadding or 1
	resolvedOptions.cameraCFrame = options.cameraCFrame
	resolvedOptions.preserveAnchoring = options.preserveAnchoring

	return resolvedOptions
end

function BaseTile.createViewportComponentFrame(
	previewInstance: Model | BasePart,
	onButtonActivated: (() -> ())?,
	options: ViewportOptions?
)
	local resolvedOptions = resolveOptions(options)

	local frame = createFrame()
	local button = createTextButton(frame, onButtonActivated)

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "PreviewViewport"
	viewport.Ambient = resolvedOptions.ambient
	viewport.LightColor = resolvedOptions.lightColor
	viewport.LightDirection = resolvedOptions.lightDirection
	viewport.Parent = button

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local previewClone = previewInstance:Clone()
	local boundsCFrame: CFrame
	local boundsSize: Vector3
	if previewClone:IsA("Model") then
		if not resolvedOptions.preserveAnchoring then
			for _, descendant in previewClone:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = true
				end
			end
		end
		previewClone:PivotTo(CFrame.identity)
		boundsCFrame, boundsSize = previewClone:GetBoundingBox()
	else
		previewClone.Anchored = true
		previewClone.CFrame = CFrame.identity
		boundsCFrame = previewClone.CFrame
		boundsSize = previewClone.Size
	end
	previewClone.Parent = worldModel

	local camera = Instance.new("Camera")
	camera.FieldOfView = resolvedOptions.fieldOfView
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	if resolvedOptions.cameraCFrame then
		camera.Focus = previewClone:GetPivot()
		camera.CFrame = camera.Focus * resolvedOptions.cameraCFrame
	else
		local fieldOfView = math.rad(camera.FieldOfView)
		local visibleSize = math.max(boundsSize.X, boundsSize.Y) * resolvedOptions.fitPadding
		local distance = visibleSize / (2 * math.tan(fieldOfView / 2)) + boundsSize.Z / 2
		local targetPosition = boundsCFrame.Position
		camera.CFrame = CFrame.lookAt(targetPosition - Vector3.zAxis * distance, targetPosition)
	end

	return frame
end

return BaseTile
