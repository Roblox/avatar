--!strict

--[[
    Generic queues and stacks for undo/redo
]]

type Node<T> = {
	read payload: T,
	read nextNode: Node<T>?,
}

export type Queue<T> = {
	read inbox: Node<T>?, -- newest on top; enqueue pushes here
	read outbox: Node<T>?, -- oldest on top; dequeue pops here
	read length: number,
}

export type Stack<T> = {
	read top: Node<T>?,
	read length: number,
}

local UtilTypes = {}

-- Appends newAction as the newest entry. O(1) worst-case.
function UtilTypes.enqueue<T>(q: Queue<T>, newItem: T): Queue<T>
	return {
		inbox = { payload = newItem, nextNode = q.inbox },
		outbox = q.outbox,
		length = q.length + 1,
	}
end

-- Removes and returns the oldest item
function UtilTypes.dequeue<T>(q: Queue<T>): (Queue<T>, T?)
	local inbox, outbox = q.inbox, q.outbox
	if not outbox then
		-- refill: reverse inbox (newest-on-top) into outbox (oldest-on-top)
		while inbox do
			outbox = { payload = inbox.payload, nextNode = outbox }
			inbox = inbox.nextNode
		end
	end
	if not outbox then
		return q, nil -- empty
	end
	return {
		inbox = inbox, -- nil if we just refilled
		outbox = outbox.nextNode,
		length = q.length - 1,
	},
		outbox.payload
end

function UtilTypes.newQueue<T>(): Queue<T>
	return { inbox = nil, outbox = nil, length = 0 }
end

function UtilTypes.push<T>(stack: Stack<T>, newItem: T): Stack<T>
	local node: Node<T> = {
		payload = newItem,
		nextNode = stack.top,
	}
	return { top = node, length = stack.length + 1 }
end

function UtilTypes.pop<T>(stack: Stack<T>): (Stack<T>, T?)
	if stack.top then
		return { top = stack.top.nextNode, length = stack.length - 1 }, stack.top.payload
	end
	return { top = nil, length = 0 }, nil
end
function UtilTypes.newStack<T>(): Stack<T>
	return { top = nil, length = 0 }
end

return UtilTypes
