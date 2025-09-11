local uiutils = {}

-- Adds a UICorner to the element that is passed in.
uiutils.AddUICorner = function(element, radiusPixels, radiusPercent)
	local UICorner = Instance.new("UICorner")
	if radiusPixels == nil and radiusPercent == nil then
		radiusPixels = 8
		radiusPercent = 0
	else
		radiusPixels = radiusPixels or 0
		radiusPercent = radiusPercent or 0
	end
	UICorner.CornerRadius = UDim.new(radiusPercent, radiusPixels)
	UICorner.Parent = element
end

uiutils.RemoveUICorner = function(element)
	local uiCorner = element:FindFirstChildOfClass("UICorner")
	if uiCorner then
		uiCorner:Destroy()
	end
end

uiutils.HasUICorner = function(element)
	return element:FindFirstChildOfClass("UICorner") ~= nil
end

uiutils.AddUIPadding = function(element, pixelPadding)
	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0, pixelPadding)
	UIPadding.PaddingTop = UDim.new(0, pixelPadding)
	UIPadding.PaddingLeft = UDim.new(0, pixelPadding)
	UIPadding.PaddingRight = UDim.new(0, pixelPadding)
	UIPadding.Parent = element
	return UIPadding
end

uiutils.AddListLayout = function(element, pixelPadding)
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pixelPadding = pixelPadding or 0
	listLayout.Padding = UDim.new(0, pixelPadding)
	listLayout.Parent = element
	return listLayout
end

uiutils.CreateOutlineButton = function(text, outlineColor, bgColor, textColor)
	-- Creates two frames with corners because Roblox doesn't support corners on borders
	transparency = transparency or 0
	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = outlineColor
	background.BorderSizePixel = 0
	uiutils.AddUICorner(background)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 1, -2)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.new(0.5, 0, 0.5, 0)
	button.BackgroundTransparency = 0
	button.BackgroundColor3 = bgColor
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = textColor
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 16
	button.Parent = background
	uiutils.AddUICorner(button)
	return background, button
end

-- Helper to show only the right half of an image. Returns ImageRectSize, ImageRectOffset
function uiutils.GetImageRightHalfRect(editableImage)
	local imageRectSize, imageRectOffset
	if editableImage then
		local imageWidth = editableImage.Size.X
		local imageHeight = editableImage.Size.Y
		if imageWidth > imageHeight then
			imageRectSize = Vector2.new(imageWidth / 2, imageHeight)
			imageRectOffset = Vector2.new(imageWidth / 2, 0)
		end
	end
	return imageRectSize, imageRectOffset
end

return uiutils
