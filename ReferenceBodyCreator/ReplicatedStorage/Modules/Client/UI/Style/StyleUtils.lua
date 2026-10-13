--[[
	Utility functions specific for UI styling and functionality.
]]

local GuiService = game:GetService("GuiService")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))

local StyleUtils = {}

-- Simple wrapper for adding tags to UI components for style sheet
function StyleUtils.AddStyleTag(component: Instance, tag: string)
	if not tag then
		-- Body creation client will capture the warning produced by the AddTag
		-- method, so this gives us a bit more info.
		warn(`Cannot tag {component.Name}: tag is nil`)
	else
		component:AddTag(tag)
	end
end

function StyleUtils.RemoveStyleTag(component: Instance, tag: string)
	if not tag then
		-- Body creation client will capture the warning produced by the
		-- RemoveTag method, so this gives us a bit more info.
		warn(`Cannot untag {component.Name}: tag is nil`)
	else
		component:RemoveTag(tag)
	end
end

-- Adds the style tag when enabled, removes it otherwise.
function StyleUtils.SetStyleTag(component: Instance, tag: string, enabled: boolean)
	if enabled then
		StyleUtils.AddStyleTag(component, tag)
	else
		StyleUtils.RemoveStyleTag(component, tag)
	end
end

-- Returns a Vector2 where X and Y are between 0 and 1 representing the position of the mouse relative to the component
function StyleUtils.GetMousePositionScaleOnComponent(component: GuiObject, mousePosition: Vector2 | Vector3): Vector2
	local distanceFromLeft = mousePosition.X - component.AbsolutePosition.X
	local mousePositionXScale = math.clamp(distanceFromLeft / component.AbsoluteSize.X, 0, 1)

	local distanceFromTop = mousePosition.Y - component.AbsolutePosition.Y
	local mousePositionYScale = math.clamp(distanceFromTop / component.AbsoluteSize.Y, 0, 1)

	return Vector2.new(mousePositionXScale, mousePositionYScale)
end

-- The top-left GUI inset (e.g. the Roblox topbar). AbsolutePosition and drag
-- input positions are reported in inset-relative coordinates; add this to
-- convert an input position into a ScreenGui that ignores the inset, or
-- subtract it to convert an AbsolutePosition into that ScreenGui's space.
function StyleUtils.GetTopLeftInset(): Vector2
	return GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
end

function StyleUtils.GetIsMobile(screenGui: ScreenGui)
	if not screenGui then
		return false
	end
	return screenGui.AbsoluteSize.X <= StyleConsts.MobileWidthCutoff
		and screenGui.AbsoluteSize.Y <= StyleConsts.MobileWidthCutoff
end

return StyleUtils
