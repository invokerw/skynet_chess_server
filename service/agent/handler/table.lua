local skynet = require "skynet"
local env = require "env"
local player = require "player"

local M = {}

function M.match()
	local info = {
		id = player.id,
		agent = skynet.self(),
		name = player.name
	}
	local resp = skynet.call(env.room, "lua","match", info)
	print("log : match ret ",resp)
	if resp then
		env.send_msg(resp.name, resp.msg)
	end
end

function M.move(msg)
	local info = {
		id = player.id,
		agent = skynet.self(),
		name = player.name
	}
	local resp = skynet.call(env.room, "lua","move", info, msg)
end

function M.register()
	env.dispatcher:register("Table.MatchReq", M.match)
	env.dispatcher:register("Table.MoveReq", M.move)

end

return M
