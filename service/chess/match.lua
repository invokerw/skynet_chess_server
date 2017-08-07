local M = {
	list = {}
}

function M:add(info)
	table.insert(self.list, info)
end

function M:remove(id)
	for i,v in ipairs(self.list) do
		if v.id == id then
			table.remove(self.list,i)
			break
		end
	end
end

function M:peek()
	if #self.list < 2 then
		return
	end

	local p1 = table.remove(self.list,1)
	local p2 = table.remove(self.list,1)

	return p1, p2
end

return M 
