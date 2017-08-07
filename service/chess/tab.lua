local skynet = require "skynet"
local env = require "env"
local protopack = require "protopack"
local M = {}

M.__index = M

function M.new()
	local o = {
		id = env.room:get_tab_id()
	}
	print("log: table id = 2???  get_tab_id()== ",o.id)
	setmetatable(o, M)
	return o
end

local function print_chessboard(chessboard)
	for i=1,9 do
		local s = ""
		for j=1,9 do
			s = s..chessboard[i][j].." "
		end
		print(s)
	end
end
function M:init(p1, p2)
	self.red = p1
	self.black = p2
	self.status = "wait"
	--加上棋盘数据
	self.chessboard = {
		 {5, 4, 3, 2, 1, 2, 3, 4, 5},
		 {0, 0, 0, 0, 0, 0, 0, 0, 0},
		 {0, 6, 0, 0, 0, 0, 0, 6, 0},
		 {7, 0, 7, 0, 7, 0, 7, 0, 7},
		 {0, 0, 0, 0, 0, 0, 0, 0, 0},
		 {0, 0, 0, 0, 0, 0, 0, 0, 0},
		 {7, 0, 7, 0, 7, 0, 7, 0, 7},
		 {0, 6, 0, 0, 0, 0, 0, 6, 0},
		 {0, 0, 0, 0, 0, 0, 0, 0, 0},
		 {5, 4, 3, 2, 1, 2, 3, 4, 5}
	}
	--print("self.chessboard:")
	--print_chessboard(self.chessboard)

	local msg1 = {
		i_am_red = true,
		name = p2.name,
		lv = p2.lv,
		icon = p2.icon
	}

	skynet.send(p1.agent, "lua", "send", "Table.MatchResult", msg1)

	local msg2 = {
		i_am_red = false,
		name = p1.name,
		lv = p1.lv,
		icon = p1.icon
	}

	skynet.send(p2.agent, "lua", "send", "Table.MatchResult", msg2)
end

function M:move(info, msg)
	--解析数据进行移动
	local chessman = self.chessboard[msg.move.srow][msg.move.scol]
	self.chessboard[msg.move.srow][msg.move.scol] = 0
	self.chessboard[msg.move.drow][msg.move.dcol] = chessman
	--print("self.chessboard:")
	--print_chessboard(self.chessboard)
	skynet.send(self.red.agent, "lua", "send", "Table.MoveNotify", msg)
	skynet.send(self.black.agent, "lua", "send", "Table.MoveNotify", msg)
end

return M
