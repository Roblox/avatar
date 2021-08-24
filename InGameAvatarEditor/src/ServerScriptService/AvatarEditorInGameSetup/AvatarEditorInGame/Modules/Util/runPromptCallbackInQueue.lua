
local queue = {}
local callbackRunning = false

local function runPromptCallbackInQueue(callback)
	if callbackRunning then
		table.insert(queue, callback)
		return
	end
	
	callbackRunning = true
	
	coroutine.wrap(function()
		callback()
		
		while #queue > 0 do
			local currentCallback = queue[1]
			table.remove(queue, 1)
			
			currentCallback()
		end
		
		callbackRunning = false
	end)()
end

return runPromptCallbackInQueue