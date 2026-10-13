--[[
	Style manager using StyleSheets and tags to facilitate styling of several
	UI components.
	Relies on StyleRules and StyleThemes for defining UI properties.
]]

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = script.Parent.Parent
local StyleFolder = UI:WaitForChild("Style")
local StyleUtils = require(StyleFolder:WaitForChild("StyleUtils"))
local StyleThemes = require(StyleFolder:WaitForChild("StyleThemes"))
local StyleRules = require(StyleFolder:WaitForChild("StyleRules"))

local Style = {}
Style.__index = Style

local function createTheme(name, tokens)
	local themeSheet = Instance.new("StyleSheet")
	themeSheet.Name = name

	for label, value in tokens do
		themeSheet:SetAttribute(label, value)
	end

	themeSheet.Parent = ReplicatedStorage

	return themeSheet
end

function Style.new()
	local self = {}
	setmetatable(self, Style)

	self.coreSheet = Instance.new("StyleSheet")
	self.coreSheet.Name = "AvatarCreationStyleSheet"
	self.coreSheet.Parent = ReplicatedStorage

	self.phoneTheme = createTheme("MobileTheme", StyleThemes.mobileThemeTokens)
	self.desktopTheme = createTheme("DesktopTheme", StyleThemes.desktopThemeTokens)

	self.themeDerive = Instance.new("StyleDerive")
	self.themeDerive.Parent = self.coreSheet
	self.themeDerive.StyleSheet = self.phoneTheme

	self:GenerateRules()

	return self
end

function Style:Destroy()
	self.coreSheet:Destroy()
end

function Style:LinkGui(screenGui: ScreenGui)
	local styleLink = Instance.new("StyleLink")
	styleLink.Parent = screenGui
	styleLink.StyleSheet = self.coreSheet

	local function updateTheme()
		self:UpdateTheme(screenGui)
	end
	screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTheme)
	screenGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateTheme)
	updateTheme()
end

function Style:UpdateTheme(screenGui: ScreenGui)
	if StyleUtils.GetIsMobile(screenGui) then
		-- The panel reaches the full screen edge; the top bar ends at its safe-area edge.
		local screenRight = GuiService:GetInsetArea(Enum.ScreenInsets.None).Max.X
		local topbarRight = GuiService:GetInsetArea(Enum.ScreenInsets.TopbarSafeInsets).Max.X
		local positionToken = StyleThemes.themeTokens.LocalMenuPositionWithOpenPanel
		self.phoneTheme:SetAttribute(
			positionToken,
			StyleThemes.mobileThemeTokens[positionToken] + UDim2.fromOffset(screenRight - topbarRight, 0)
		)
		self.themeDerive.StyleSheet = self.phoneTheme
	else
		self.themeDerive.StyleSheet = self.desktopTheme
	end
end

function Style:AddRule(selector: string, properties: {}, priority: number?)
	local rule = Instance.new("StyleRule")
	rule.Parent = self.coreSheet
	rule.Selector = selector
	rule.Priority = if priority then priority else 0
	rule.Name = selector
	rule:SetProperties(properties)
end

function Style:GenerateRules()
	for selector, props in StyleRules.lowPriorityRules do
		self:AddRule(selector, props, 0)
	end
	for selector, props in StyleRules.standardRules do
		self:AddRule(selector, props, 50)
	end

	for selector, props in StyleRules.highPriorityRules do
		self:AddRule(selector, props, 100)
	end
end

return Style
