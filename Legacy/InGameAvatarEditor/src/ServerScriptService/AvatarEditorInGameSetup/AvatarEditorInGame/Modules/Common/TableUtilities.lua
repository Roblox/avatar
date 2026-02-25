-----------------------------------------------------------------------------
---                                                                       ---
---                   Under Migration to CorePackages                     ---
---                                                                       ---
---      Please put your changes in AppTempCommon.                        ---
---      NOTE: You will have to rebuild for changes to kick in            ---
-----------------------------------------------------------------------------

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local tutils = require(Modules.Packages.tutils)

return {
	CheckListConsistency = tutils.checkListConsistency,
	DeepEqual = tutils.deepEqual,
	EqualKey = tutils.equalKey,
	FieldCount = tutils.fieldCount,
	ListDifference = tutils.listDifferences,
	Print = tutils.print,
	RecursiveToString = tutils.toString,
	ShallowEqual = tutils.shallowEqual,
	TableDifference = tutils.tableDifference,
}

