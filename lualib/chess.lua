local function get_type(n)
	if n > 10 then
		return n - 10
	end

	return n
end

local function get_cm(board, row, col)
	if row < 1 or row > 10 then
		return nil
	end

	if col < 1 or col > 9 then
		return nil
	end

	local index = (row - 1) * 10 + col

	return board[index]
end

local function get_color(cm)
	if cm == 0 then
		return 0
	end

	if cm > 10 then
		return 1
	end

	return -1
end

-- 九宫格检查
local function in_hall_check(cm, row, col)
	if col < 4 or col > 6 then
		return false
	end

	-- 红棋
	if cm < 10 and row < 8 then
		return false
	end

	-- 黑棋
	if cm > 10 and row > 3 then
		return false
	end

	return true
end

-- 过河检查
local function crossed_river(cm, row)
	if cm < 10 and row < 6 then
		return true
	end

	if cm > 10 and row > 5 then
		return true
	end

	return false
end

-- 获取两点之间的阻挡个数,需要是直线
local function get_bt_count(board, src_row, src_col, dest_row, dest_col)
	local drow = dest_row - src_row
	local dcol = dest_col - src_col

	-- 只能走直线
	if drow * dcol ~= 0 then
		return false
	end

	local count = 0
	local rstep = 0
	local cstep = 0
	if drow == 0 then
		cstep = dcol > 0 and 1 or -1
	else
		rstep = drow > 0 and 1 or -1
	end

	local r = src_row
	local c = src_col

	repeat
		r = r + rstep
		c = c + cstep

		if r == dest_row and c == dest_col then
			break
		end

		if get_cm(board, r, c ) ~= 0 then
			count = count + 1
		end
	until(false)

	return count
end

local M = {}

-- 每种子力的类型编号
local TYPE ={
	KING = 1,	-- 帅
	ADVISOR = 2,-- 士
	BISHOP = 3,	-- 象
	KNIGHT = 4,	-- 马
	ROOK = 5,	-- 车
	CANNON = 6,	-- 炮
	PAWN = 7	-- 兵
}

function M.new()
	local data = {
		red_turn = true,
		finish = false
	}

	-- 10行9列的棋盘
	data.board = {
		{5, 4, 3, 2, 1, 2, 3, 4, 5},
		{0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 6, 0, 0, 0, 0, 0, 6, 0},
		{7, 0, 7, 0, 7, 0, 7, 0, 7},
		{0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0},
		{7, 0, 7, 0, 7, 0, 7, 0, 7},
		{0, 6, 0, 0, 0, 0, 0, 6, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0},
		{5, 4, 3, 2, 1, 2, 3, 4, 5},
	}

	-- 红方棋子值加10
	for i=46,90 do
		if data.board[i] > 0 then
			data.board[i] = data.board[i] + 10
		end
	end

	return data
end

function M.can_move(data, is_red, src_row, src_col, dest_row, dest_col)
	-- 不是自己的回合
	if data.red_turn ~= is_red then
		return false
	end

	-- 源是否在棋盘内
	local src_cm = get_cm(data.board, src_row, src_col)
	if src_cm == nil or src_cm == 0 then
		return false
	end

	-- 目标是否在棋盘内, 目标有已方子
	local dest_cm = get_cm(data.board, dest_row, dest_col)
	if dest_cm == nil or get_color(src_cm) == get_color(dest_cm) then
		return false
	end

	local true_type = get_type(src_cm)
	local drow = dest_row - src_row
	local dcol = dest_col - src_col

	-- 将、帅
	if true_type == TYPE.KING then
		-- 对面笑
		if get_type(dest_cm) == TYPE.KING then
			if src_col ~= dest_col then
				return false
			end

			-- 中间不能有子
			local step = src_row > dest_row and -1 or 1
			for i=src_row,dest_row,step do
				if get_cm(i,src_col) ~= 0 then
					return false
				end
			end

			return true
		end

		-- 九宫格
		if not in_hall_check(src_cm, dest_row, dest_col) then
			return false
		end

		-- 只能直着走一步
		if math.abs(drow + dcol) ~= 1 or drow * dcol ~= 0 then
			return false
		end

		return true
	end

	-- 士
	if true_type == TYPE.ADVISOR then
		-- 九宫格
		if not in_hall_check(src_cm, dest_row, dest_col) then
			return false
		end

		-- 只能斜着走一格
		if math.abs(drow * dcol) ~= 1 then
			return false
		end

		return true
	end

	-- 象
	if true_type == TYPE.ADVISOR then
		-- 不能过河
		if crossed_river(src_cm, dest_row, dest_col) then
			return false
		end

		-- 飞田
		if math.abs(drow) ~= 2 or math.abs(dcol ~= 2) then
			return false
		end

		-- 别腿检查
		if get_cm(data.board, src_row + drow/2, src_col + dcol/2) ~= 0 then
			return false
		end

		return true
	end

	-- 马
	if true_type == TYPE.KNIGHT then
		-- 走日
		if math.abs(drow * dcol) ~= 2 then
			return false
		end

		local r = src_row
		local c = src_col
		if math.abs(drow) == 2 then
			r = r + drow/2
		else
			c = c + dcol/2
		end
		-- 别腿检查
		if get_cm(data.board, r, c) ~= 0 then
			return false
		end
	end

	-- 车
	if true_type == TYPE.ROOK then
		local count = get_bt_count(data.board, src_row, src_col, dest_row, dest_col)
		if not count or count > 0 then
			return false
		end

		return true
	end

	-- 炮
	if true_type == TYPE.CANNON then
		local count = get_bt_count(data.board, src_row, src_col, dest_row, dest_col)
		if not count then
			return false
		end

		-- 炮打隔山
		if dest_cm > 0  and count ~= 1 then
			return false
		end

		-- 走直线
		if dest_cm == 0 and count ~= 0 then
			return false
		end

		return true
	end

	-- 兵、卒
	if true_type == TYPE.PAWN then
		-- 走直线
		if drow ~= 0 and dcol ~= 0 then
			return false
		end

		-- 走一步
		if math.abs(drow + dcol) ~= 1 then
			return false
		end

		-- 没过河，不能左右走
		if not crossed_river(src_cm, src_row) and dcol ~= 0 then
			return false
		end

		-- 不能倒退
		if src_cm < 10 and drow > 0 then
			return false
		end

		if src_cm > 10 and drow < 0 then
			return false
		end

		return true
	end
end

function M.move(data, src_row, src_col, dest_row, dest_col)
	local src = M.get_index(src_row, src_col)
	local dest = M.get_index(dest_row, dest_col)

	if data.board[dest] == M.TYPE.KING then
		data.finish = true
		return true
	end

	data.board[dest] = data.board[src]
	data.board[src] = 0

	data.red_turn = not data.red_true

	return false
end

return M
