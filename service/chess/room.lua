local Tab = require "tab"
local Utils = require "utils"

Utils.print(Table)

local M = {}

M.__index = M

function M.new()
	local o = {
		players = {},
		tables = {},
		player_2_tab = {},
		id = 1
	}
	setmetatable(o, M)
	return o
end

function M:init(id)
end

function M:get_tab_id()
	self.id = self.id+1
	return self.id
end

function M:enter(info)
	local old = self.players[info.id]
    if old then
		return false
	end

	self.players[info.id] = info
	return true
end

function M:add_table(tab)
	self.tables[tab.id] = tab
	self.player_2_tab[tab.red.id] = tab.id
	self.player_2_tab[tab.black.id] = tab.id
end

function M:leave(id)
	self.players[id] = nil
end

function M:get_table_by_player_id(id)
	local tab_id = self.player_2_tab[id]
	return self.tables[tab_id]
end

return M
