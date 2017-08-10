local M = {}

M.__index = M
function M.print_chessboard(chessboard)
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

--将军
function M.check(chessboard, source, direc, redrun)
	if true then
	end
end

--赢了
function M.checkmate(chessboard, direc)
	if chessboard[direc] == 16 or chessboard[direc] == 32 then
		return true
	end
	return false
end

--可以这么走吗
function M.canmove(chessboard, source, direc)
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
		if chessboard[source + horse_leg[x]] ~= 0 then
			return false
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
		if chessboard[source + elephant_leg[x]] ~= 0 then
			return false
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

return M
