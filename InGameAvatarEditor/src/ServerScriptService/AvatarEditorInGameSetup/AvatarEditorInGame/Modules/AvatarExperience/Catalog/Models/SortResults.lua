--[[
	Model for sort results in the Catalog.
	{
		items =
		{
			"id": string,
			"type": string
		},

        "keyword":string,
        "previousPageCursor": string,
        "nextPageCursor": string
	}
]]

local SortResults = {}

function SortResults.new()
    local sortResults = {}

	return sortResults
end

function SortResults.mock()
	local self = SortResults.new()

	self.items = {
		id = "",
		type = ""
    }

	self.keyword = ""
	self.previousPageCursor = ""
	self.nextPageCursor = ""

	return self
end

function SortResults.fromSearchItemsDetails(itemDetailsResponse)
	local self = SortResults.new()

	self.items = {}
    for i, itemData in ipairs(itemDetailsResponse.data) do
		self.items[i] = {
			id = tostring(itemData.id),
			type = tostring(itemData.itemType)
		}
    end

	self.keyword = itemDetailsResponse.keyword
	self.previousPageCursor = itemDetailsResponse.previousPageCursor
	self.nextPageCursor = itemDetailsResponse.nextPageCursor

	return self
end

return SortResults