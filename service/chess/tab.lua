local skynet = require "skynet"
local env = require "env"
local protopack = require "protopack"
local tb = require "handler.table"
local M = {}

M.__index = M

function M.new()
	local o = {
		id = env.room:get_tab_id()
	}
	setmetatable(o, M)
	return o
end

function M:init(p1, p2)
	self.red = p1
	self.black = p2
	self.status = "wait"
	self.redrun = true
	--加上棋盘数据
	--十几的棋子是红方
	--棋盘的16*16会更加好的判定边界问题，行走问题
	self.chessboard = { 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, 39, 37, 35, 33, 32, 34, 36, 38, 40, -1, -1, -1, -1,
		-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
		-1, -1, -1,  0, 41,  0,  0,  0,  0,  0, 42,  0, -1, -1, -1, -1, 
		-1, -1, -1, 43,  0, 44,  0, 45,  0, 46,  0, 47, -1, -1, -1, -1, 
		-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
		--				     楚河            汉界
		-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
		-1, -1, -1, 27,  0, 28,  0, 29,  0, 30,  0, 31, -1, -1, -1, -1, 
		-1, -1, -1,  0, 25,  0,  0,  0,  0,  0, 26,  0, -1, -1, -1, -1, 
		-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
		-1, -1, -1, 23, 21, 19, 17, 16, 18, 20, 22, 24, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	}
	--chess_pieces[48]这个扩展的棋子数组比较难以理解, 实际上用了“屏蔽位”的设计, 即1位表示红子(16), 1位表示黑子(32)。
	--因此0到15没有作用, 16到31代表红方棋子(16代表帅, 17和18代表仕, 依此类推, 直到27到31代表兵), 32到47代表黑方棋子(在红方基础上加16)。
	--棋盘数组中的每个元素的意义就明确了，0代表没有棋子, 16到31代表红方棋子, 32到47代表黑方棋子。
	--好处：它可以快速判断棋子的颜色, (Piece & 16)可以判断是否为红方棋子，(Piece & 32)可以判断是否为黑方棋子。
	self.chess_pieces = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		200,199,201,198,202,197,203,196,204,165,171,152,154,156,158,160,
		56,55,57,54,58,53,59,52,60,85,91,100,102,104,106,108
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
	local source = (msg.move.srow + 3 - 1) * 16 + msg.move.scol + 3
	local direc = (msg.move.drow + 3 - 1) * 16 + msg.move.dcol + 3
	local chessman = self.chessboard[source]
	--print("self.chessboard:")
	--tb.print_chessboard(self.chessboard)
	--print("source = "..source..",direc = "..direc)
	if source == direc then
		return
	end
	if self.chessboard[source] == -1 or self.chessboard[direc] == -1 then 
		return
	end
	--不该他走
	if ((chessman & 16)==16 and self.redrun == false) or ((chessman & 32)== 32 and self.redrun == true) then
		print("error: chessman & 16 = "..(chessman & 16).."  chessman & 32 = "..(chessman & 32))
		return
	end
	--不能移动到自己的棋子上
	if ((self.chessboard[direc] & 16) == 16 and self.redrun == true) or ((self.chessboard[direc] & 32)== 32 and self.redrun == false) then
		print("error: self.chessboard[direc]&16 ="..(self.chessboard[direc]&16).." (self.chessboard[direc]&32 =  "..(self.chessboard[direc] & 32))
		return
	end
	--首先可不可以这么走
	if true ~= tb.canmove(self.chessboard, source, direc) then
		print("can't move it")
		return 
	end
	--可以这么走发送消息
	skynet.send(self.red.agent, "lua", "send", "Table.MoveNotify", msg)
	skynet.send(self.black.agent, "lua", "send", "Table.MoveNotify", msg)
	--是否赢了
	if true == tb.checkmate(self.chessboard, direc) then
		skynet.send(self.red.agent, "lua", "send", "Table.Winner", {isred = self.redrun})
		skynet.send(self.black.agent, "lua", "send", "Table.Winner", {isred = self.redrun})
	end
	--是否将军
	
	--改变服务器棋盘 
	self.chessboard[source] = 0
	self.chessboard[direc] = chessman
	print("self.chessboard:")
	tb.print_chessboard(self.chessboard)

	
	self.redrun = not self.redrun
end

return M
