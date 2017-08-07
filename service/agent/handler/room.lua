local skynet = require "skynet"
local env = require "env"
local player = require "player"

local M = {}

function M.room_list()
	print("room_list")
	local list = skynet.call("hall", "lua", "list")
	print("room_list",list)
	if list then
		env.send_msg("Room.RoomListRsp", {list = list})
	end
end

function M.enter_room(msg)
	local info = skynet.call("hall", "lua", "info", msg.room_id)
	if not info then
		env.send_msg("Room.EnterRsp", {err_no = 1})
		return	
	end

	local player_info = {
		id = player.id, 
		agent = player.agent, 
		name=player.name}
	skynet.call(info.service, "lua", "enter", player_info)

	env.room = info.service
	env.send_msg("Room.EnterRsp", {err_no = 0})
end

function M.room_msg(msg)
	if not env.room then
		return
	end
	--这里到过吗
	print("room_msg Room.LeaveReq",msg)
	local resp = skynet.call(env.room, "lua", "client", msg)
	if resp then
		env.send_msg(resp.name, resp.msg)
	end
end

function M.register()
	env.dispatcher:register("Room.RoomListReq", M.room_list)
	env.dispatcher:register("Room.EnterReq", M.enter_room)
	env.dispatcher:register("Room.LeaveReq", M.room_msg)
end

return M
