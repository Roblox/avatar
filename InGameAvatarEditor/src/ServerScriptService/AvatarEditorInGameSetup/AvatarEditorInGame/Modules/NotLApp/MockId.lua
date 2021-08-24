-----------------------------------------------------------------------------
---                                                                       ---
---                   Under Migration to CorePackages                     ---
---                                                                       ---
---      Please put your changes in AppTempCommon.                        ---
---      NOTE: You will have to rebuild for changes to kick in            ---
-----------------------------------------------------------------------------


local lastId = 0

return function()
	lastId = lastId + 1
	return tostring(lastId)
end