local Root = script.Parent.Parent
local enumerate = require(Root.enumerate)

return enumerate("RoundingBehaviour", {
	"RoundToClosest",
	"Truncate",
})