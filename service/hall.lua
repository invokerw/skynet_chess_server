local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

local halls = {}
-- id
-- game = "chess"
-- service


local function create(id, game)
	local conf = {id = id}
	local s = skynet.newservice(game)
	skynet.call(s, "lua", "start", conf)
	return s
end

local CMD = {}

function CMD.start()
	log.log("starting hall... ")
	-- 开了三个大厅
	for i=1,3 do
		table.insert(halls, {id = i, game = "chess", service = create(i, "chess")})
	end
end

function CMD.list()
	return halls
end

function CMD.info(hall_id)
	local info = halls[hall_id]
	if not info then
		return false
	end

	return info
end

skynet.start(function ()
	skynet.dispatch("lua", function (_, _, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			skynet.ret(skynet.pack(nil, "cant find handle of "..cmd))
		end
	end)
	skynet.register("hall")
end)
