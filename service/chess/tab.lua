local skynet = require "skynet"
local env = require "env"
local protopack = require "protopack"
local M = {}

M.__index = M

function M.new()
	local o = {
		id = env.room:get_tab_id()
	}
	setmetatable(o, M)
	return o
end

local function print_chessboard(chessboard)
	local s = ""
	for i=1,90 do
		s = s..chessboard[i].." "
		if i%10 == 0 then
			print(s)
			s = ""
		end
	end
end
local horse     = {-19,-17,-11,-7, 7,11,17,19}
local horse_leg = { -9, -9, -1, 1,-1, 1, 9, 9}
local elephant     = {-20,-16,16,20}
local elephant_leg = {-10, -8, 8,10}
local in_palace = {
	0,  0,  0,  1,  1,  1,  0,  0,  0,
	0,  0,  0,  1,  1,  1,  0,  0,  0,
	0,  0,  0,  1,  1,  1,  0,  0,  0,
	0,  0,  0,  0,  0,  0,  0,  0,  0,
	0,  0,  0,  0,  0,  0,  0,  0,  0,
	--     楚河            汉界
	0,  0,  0,  0,  0,  0,  0,  0,  0,
	0,  0,  0,  0,  0,  0,  0,  0,  0,
	0,  0,  0,  1,  1,  1,  0,  0,  0,
	0,  0,  0,  1,  1,  1,  0,  0,  0,
	0,  0,  0,  1,  1,  1,  0,  0,  0,	
}
--chess_pieces[48]这个扩展的棋子数组比较难以理解，实际上用了“屏蔽位”的设计，即1位表示红子(16)，1位表示黑子(32)。
--因此0到15没有作用，16到31代表红方棋子(16代表帅，17和18代表仕，依此类推，直到27到31代表兵)，32到47代表黑方棋子(在红方基础上加16)。
--棋盘数组中的每个元素的意义就明确了，0代表没有棋子，16到31代表红方棋子，32到47代表黑方棋子。
--好处：它可以快速判断棋子的颜色，(Piece & 16)可以判断是否为红方棋子，(Piece & 32)可以判断是否为黑方棋子。
local chess_pieces = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	86,85,87,84,88,83,89,82,90,65,71,55,57,59,61,63,
	5,4,6,3,7,2,8,1,9,20,26,28,30,32,34,36
}


function M:init(p1, p2)
	self.red = p1
	self.black = p2
	self.status = "wait"
	self.redrun = true
	--加上棋盘数据
	--十几的棋子是红方
	self.chessboard = {
		39, 37, 35, 33, 32, 34, 36, 38, 40,
		 0,  0,  0,  0,  0,  0,  0,  0,  0,
		 0, 41,  0,  0,  0,  0,  0, 42,  0,
		43,  0, 44,  0, 45,  0, 46,  0, 47,
		 0,  0,  0,  0,  0,  0,  0,  0,  0,
		--     楚河            汉界
		 0,  0,  0,  0,  0,  0,  0,  0,  0,
		27,  0, 28,  0, 29,  0, 30,  0, 31,
		 0, 25,  0,  0,  0,  0,  0, 26,  0,
		 0,  0,  0,  0,  0,  0,  0,  0,  0,
		23, 21, 19, 17, 16, 18, 20, 22, 24
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
	local source = (msg.move.srow - 1) * 9 + msg.move.scol
	local direc = (msg.move.drow - 1) * 9 + msg.move.dcol
	--不该他走
	if ((chessman & 16) and self.redrun == true) or ((chessman & 32)  and self.redrun == false) then
		return
	end
	--不能移动到自己的棋子上
	if ((self.chessboard[direc] & 16) and self.redrun == true) or ((self.chessboard[direc] & 32) and self.redrun == false) then
		return
	end
	--首先可不可以这么走

	--可以这么走发送消息
	skynet.send(self.red.agent, "lua", "send", "Table.MoveNotify", msg)
	skynet.send(self.black.agent, "lua", "send", "Table.MoveNotify", msg)
	--是否赢了
	if checkmate(self.chessboard, direc) then
		print("is red:"..self.redrun..", Win")
		
	end
	--是否将军
	
	--改变服务器棋盘 
	self.chessboard[source] = 0
	self.chessboard[direc] = chessman
	print("self.chessboard:")
	print_chessboard(self.chessboard)

	
	self.redrun = not self.redrun
end

--将军
local function check(chessboard, source, direc, redrun)
	if true then
	end
end

--赢了
local function checkmate(chessboard, direc)
	if chessboard[direc] == 11 or chessboard[direc] == 1 then
		return true
	end
	return false
end

--可以这么走吗
local function canmove(chessboard, source, direc, redrun)
	local chessman = chessboard[source]
	--如果是
	if  true then
	end
end
return M
