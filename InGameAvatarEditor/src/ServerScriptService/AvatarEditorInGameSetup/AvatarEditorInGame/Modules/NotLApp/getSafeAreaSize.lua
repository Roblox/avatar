local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Common.ArgCheck)

local function getSafeAreaSize(screenSize, guiInset)
	assert(typeof(screenSize) == "Vector2", "getSafeAreaSize expects screenSize to be a Vector2")
	assert(type(guiInset) == "table", "getSafeAreaSize expects guiInset to be a table")
	ArgCheck.isNonNegativeNumber(guiInset.left, "getSafeAreaSize: guiInset.left")
	ArgCheck.isNonNegativeNumber(guiInset.right, "getSafeAreaSize: guiInset.right")
	ArgCheck.isNonNegativeNumber(guiInset.top, "getSafeAreaSize: guiInset.top")
	ArgCheck.isNonNegativeNumber(guiInset.bottom, "getSafeAreaSize: guiInset.bottom")

	local safeAreaWidth = screenSize.X - guiInset.left - guiInset.right
	local safeAreaHeight = screenSize.Y - guiInset.top - guiInset.bottom

	ArgCheck.isNonNegativeNumber(safeAreaWidth, "getSafeAreaSize: safeAreaWidth")
	ArgCheck.isNonNegativeNumber(safeAreaHeight, "getSafeAreaSize: safeAreaHeight")

	return UDim2.new(0, safeAreaWidth, 0, safeAreaHeight)
end

return getSafeAreaSize