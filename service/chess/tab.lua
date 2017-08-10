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
--[[
local function print_chessboard(chessboard)
	local s = ""
	for i=1,#chessboard do
		s = s..chessboard[i].." "
		if i%16 == 0 then
			print(s)
			s = ""
		end
	end
end
local horse     = {-33,-31,-18,-14, 14,18,31,33}
local horse_leg = { -16, -16, -1, 1,-1, 1, 16, 16}
local elephant     = {-34,-30,30,34}
local elephant_leg = {-17,-15, 15,17}
local scholar = {-17,-15,15,17}
local king = {-16,-1,1,16}
local in_palace = {
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
				--     楚河            汉界
	-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0, -1, -1, -1, -1, 
	-1, -1, -1,  0,  0,  0,  1,  1,  1,  0,  0,  0,	-1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
}
--chess_pieces[48]这个扩展的棋子数组比较难以理解, 实际上用了“屏蔽位”的设计, 即1位表示红子(16), 1位表示黑子(32)。
--因此0到15没有作用, 16到31代表红方棋子(16代表帅, 17和18代表仕, 依此类推, 直到27到31代表兵), 32到47代表黑方棋子(在红方基础上加16)。
--棋盘数组中的每个元素的意义就明确了，0代表没有棋子, 16到31代表红方棋子, 32到47代表黑方棋子。
--好处：它可以快速判断棋子的颜色, (Piece & 16)可以判断是否为红方棋子，(Piece & 32)可以判断是否为黑方棋子。
local chess_pieces = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	200,199,201,198,202,197,203,196,204,165,171,152,154,156,158,160,
	56,55,57,54,58,53,59,52,60,85,91,100,102,104,106,108
}

--将军
local function check(chessboard, source, direc, redrun)
	if true then
	end
end

--赢了
local function checkmate(chessboard, direc)
	if chessboard[direc] == 16 or chessboard[direc] == 32 then
		return true
	end
	return false
end
--可以这么走吗
local function canmove(chessboard, source, direc)
	local chessman = chessboard[source]
	--如果是车
	if  chessman == 23 or chessman == 24 or chessman == 39 or chessman == 40 then
		local big = source
		local small = direc
		if source < direc then
			big = direc
			small = source
		end
		--竖着走的
		if (big - small)%16 == 0 then
			if big - small > 16 then 
				for i=small+16,big-16,16 do
					if chessboard[i] ~= 0 then
						return false
					end
				end
			end
		else 
			if big - small > 1 then
				for i=small+1,big-1 do
					if chessboard[i] ~= 0 then
						return false
					end
				end
			end
		end
	--如果是炮
	elseif chessman == 25 or chessman == 26 or chessman == 41 or chessman == 42 then
		local big = source
		local small = direc
		if source < direc then
			big = direc
			small = source
		end
		--是否是吃子 
		local eat = false 
		--竖着走的
		if (big - small)%16 ==0 then
			if big - small > 16 then
				for i=small+16,big-16,16 do
					if chessboard[i] ~= 0 then
						eat = true
					end
				end
			end
		else 
			if big - small > 1 then 
				for i=small+1,big-1 do
					if chessboard[i] ~= 0 then
						eat = true
					end
				end
			end
		end

		if eat == true then 
			if chessboard[direc] == 0 then
				return false
			end
		else
			if chessboard[direc] ~= 0 then
				return false
			end
		end
	--如果是卒
	elseif (chessman >= 27 and chessman <= 31) or (chessman >= 43 and chessman <= 47) then
		--红
		if chessman >= 27 and chessman <= 31 then 
			--没有过河
			if source > 16 * 8 then
				--不是向前走
				if source - 16 ~= direc then
					return false
				end
			--如果过河了
			else
				--不是向前、左、右走
				if source - 16 ~= direc and source - 1 ~= direc and source + 1 ~= direc then
					return false
				end
			end
		elseif chessman >= 43 and chessman <= 47 then
			--没有过河
			if source <= 16 * 8 then
				--不是向前走
				if source + 16 ~= direc then
					return false
				end
			else
				--不是向前、左、右走
				if source + 16 ~= direc and source - 1 ~= direc and source + 1 ~= direc then
					return false
				end
			end
		else 
			return false
		end
	--如果是马
	elseif chessman == 21 or chessman == 22 or chessman == 37 or chessman == 38 then
		--找到他跳的位置
		local x = 0
		for i=1,#horse do
			if source + horse[i] == direc then
				x = i
				break
			end
		end
		if x == 0 then
			return false
		end
		--是否绊了马腿
		if chessboard[source + horse_leg[x]] --~= 0 then
--[[			return false
		end
	--如果是象
	elseif chessman == 19 or chessman == 20 or chessman == 35 or chessman == 36 then
		--找到他跳的位置
		local x = 0
		for i=1,#elephant do
			if source + elephant[i] == direc then
				x = i
				break
			end
		end
		if x == 0 then
			return false
		end
		--是否绊了象腿
		if chessboard[source + elephant_leg[x]] --~= 0 then
--[[			return false
		end
	--如果是士
	elseif chessman == 17 or chessman == 18 or chessman == 33 or chessman == 34 then
		if in_palace[source] == 0 or in_palace[direc] == 0 then
			return false
		end
		local x = 0
		for i=1,#scholar do
			if source + scholar[i] == direc then
				x = i
				break
			end
		end
		if x == 0 then
			return false
		end
	--如果是将
	elseif chessman == 16 or chessman == 32 then
		if in_palace[source] == 0 or in_palace[direc] == 0 then
			return false
		end
		local x = 0
		for i=1,#king do
			if source + king[i] == direc then
				x = i
				break
			end
		end
		if x == 0 then
			return false
		end
	end
	return true
end
--]]
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
		print("is red:"..self.redrun..", Win")
		
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
