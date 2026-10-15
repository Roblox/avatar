-- Builds eyebrow/eyelash step buttons from definitions, independently of mesh editing.

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Banner = require(Components:WaitForChild("Banner"))
local BaseTile = require(Components:WaitForChild("BaseTile"))
local Panel = require(Components:WaitForChild("Panel"))
local StepButtons = require(Components:WaitForChild("StepButtons"))
local StampActionBar = require(Components:WaitForChild("StampActionBar"))
local TextButton = require(Components:WaitForChild("TextButton"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

local AccessoryCustomizeToolUI = {}
AccessoryCustomizeToolUI.__index = AccessoryCustomizeToolUI

local CATEGORY_DESCRIPTIONS = {
	Eyebrows = "Eyebrow Selected",
	Eyelashes = "Eyelash Selected",
}

function AccessoryCustomizeToolUI.new(
	onClosePanelCallback: () -> (),
	onConfirmCallback: () -> (),
	onSwapCallback: () -> (),
	onDeleteCallback: () -> (),
	onPreviewChangedCallback: (category: string, previewing: boolean) -> boolean,
	onShapeControlChangedCallback: ((category: string, controlId: string, value: number) -> ())?
)
	local self = setmetatable({}, AccessoryCustomizeToolUI)

	self.onShapeControlChangedCallback = onShapeControlChangedCallback
	self.controls = {}
	self.scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(self.scrollingFrame, StyleConsts.tags.ScrollFrame)
	self.selectionBanner = Banner.new({ text = "Swap", callback = onSwapCallback })
	local bannerFrame = self.selectionBanner:GetFrame()
	StyleUtils.AddStyleTag(bannerFrame, StyleConsts.tags.BannerEmphasis)
	StyleUtils.AddStyleTag(bannerFrame, StyleConsts.tags.BannerCompact)
	bannerFrame.Parent = self.scrollingFrame
	self.panel = Panel.createComponentFrame("Customize", onClosePanelCallback, onDeleteCallback, {
		self.scrollingFrame,
	})
	self.panel.Name = "AccessoryCustomizeToolPanel"
	self.previewButton = TextButton.createComponentFrame({
		text = "Preview",
		callback = function()
			if not self.category or not self.previewButton.Interactable then
				return
			end
			local request = {}
			self.previewRequest = request
			local previewing = not self.previewing
			self.previewButton.Interactable = false
			self:SetControlsEnabled(false)
			local success = onPreviewChangedCallback(self.category, previewing)
			if self.previewRequest == request then
				self:SetPreviewing(if success then previewing else self.previewing)
			end
		end,
	})
	StyleUtils.RemoveStyleTag(self.previewButton, StyleConsts.tags.DefaultButton)
	StyleUtils.AddStyleTag(self.previewButton, StyleConsts.tags.StampActionBarButton)
	StyleUtils.AddStyleTag(self.previewButton, StyleConsts.tags.ActionBarPreviewButton)
	self.actionBar = StampActionBar.new(self.previewButton, onDeleteCallback, onConfirmCallback, "Confirm")
	self.actionBar:GetFrame().Name = "AccessoryCustomizeActionBar"
	self:Close()

	return self
end

function AccessoryCustomizeToolUI:BuildControls(definitions, values: { [string]: number }?)
	for _, control in self.controls do
		control.tool:Destroy()
	end
	table.clear(self.controls)
	self.scrollingFrame.CanvasPosition = Vector2.zero
	for index, definition in definitions do
		local range = definition.max - definition.min
		local currentValue = if values then values[definition.id] else definition.default
		local initialValue = (currentValue - definition.min) / range
		local function onValueChanged(value)
			if self.category and self.onShapeControlChangedCallback then
				local controlValue = math.clamp(definition.min + value * range, definition.min, definition.max)
				self.onShapeControlChangedCallback(self.category, definition.id, controlValue)
			end
		end
		local buttons = StepButtons.new(
			initialValue,
			onValueChanged,
			definition.steps,
			definition.decreaseLabel or "- Less",
			definition.increaseLabel or "+ More"
		)
		local tool = ToolFrame.createComponentFrame(buttons:GetFrame(), definition.label)
		tool.Name = definition.id
		tool.LayoutOrder = index
		tool.Parent = self.scrollingFrame
		table.insert(self.controls, { buttons = buttons, tool = tool })
	end
end

function AccessoryCustomizeToolUI:Open(category: string, definitions, itemInfo, values: { [string]: number }?)
	self.category = nil
	self.previewRequest = nil
	self.selectionBanner:SetContent(itemInfo.name, CATEGORY_DESCRIPTIONS[category] or "Item Selected")
	self.selectionBanner:SetLeading(
		BaseTile.createViewportComponentFrame(itemInfo.previewInstance, nil, itemInfo.viewportOptions)
	)
	self:BuildControls(definitions, values)
	self.category = category
	self:SetPreviewing(false)
	self.panel.Visible = true
	self.actionBar:Open()
end

function AccessoryCustomizeToolUI:SetPreviewing(previewing: boolean)
	self.previewing = previewing
	self.previewButton.Interactable = true
	self:SetControlsEnabled(not previewing)
end

function AccessoryCustomizeToolUI:SetControlsEnabled(isEnabled: boolean)
	for _, control in self.controls do
		control.buttons:SetEnabled(isEnabled)
		StyleUtils.SetStyleTag(control.tool, StyleConsts.tags.ShapeControlDisabled, not isEnabled)
	end
end

function AccessoryCustomizeToolUI:Close()
	self.category = nil
	self.previewRequest = nil
	self.panel.Visible = false
	self.actionBar:Close()
	self.previewButton.Interactable = false
	self.selectionBanner:SetLeading(nil)
	self:SetControlsEnabled(false)
end

return AccessoryCustomizeToolUI
