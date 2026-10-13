--[[
	Generic banner with optional leading media, a title and description, and an action.
	Visual variants and density are supplied through style tags.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local TextButton = require(script.Parent:WaitForChild("TextButton"))

local Banner = {}
Banner.__index = Banner

function Banner.new(action: TextButton.ButtonInfo?)
	local self = setmetatable({}, Banner)

	self.frame = Instance.new("Frame")
	self.frame.Name = "Banner"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.Banner)

	self.leading = Instance.new("Frame")
	self.leading.Name = "Leading"
	self.leading.Visible = false
	self.leading.Parent = self.frame

	local content = Instance.new("Frame")
	content.Name = "Content"
	StyleUtils.AddStyleTag(content, StyleConsts.tags.BannerContent)
	content.Parent = self.frame

	self.title = Instance.new("TextLabel")
	self.title.Name = "Title"
	self.title.Text = ""
	self.title.Parent = content

	self.description = Instance.new("TextLabel")
	self.description.Name = "Description"
	self.description.Text = ""
	self.description.Parent = content

	if action then
		local button = TextButton.createComponentFrame(action)
		button.Name = "Action"
		StyleUtils.AddStyleTag(button, StyleConsts.tags.SmallButton)
		StyleUtils.AddStyleTag(button, StyleConsts.tags.BannerAction)
		button.Parent = self.frame
	end

	return self
end

function Banner:GetFrame(): Frame
	return self.frame
end

function Banner:SetContent(title: string, description: string)
	self.title.Text = title
	self.description.Text = description
	self.description.Visible = description ~= ""
end

function Banner:SetLeading(media: GuiObject?)
	if self.media == media then
		return
	end
	if self.media then
		self.media:Destroy()
	end
	self.media = media
	self.leading.Visible = media ~= nil
	if media then
		media.Parent = self.leading
	end
end

return Banner
