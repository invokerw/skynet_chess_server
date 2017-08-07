local skynet = require "skynet"
local Env = require "env"
local Room = require "room"
local Log = require "log"
local match = require "match"
local Tab = require "tab"
local socket = require "socket"

local CMD = {}

local function match_loop()
	print("match loop")

	for k,v in pairs(socket) do
		print (k,v)
	end
	--这个大厅的匹配 match_loop
	repeat
		local p1, p2 = match:peek()
		if p1 then
			local table = Tab.new()
			table:init(p1,p2)
			Env.room:add_table(table)
		end

		skynet.sleep(100)
	until(false)
end

function CMD.start(conf)
	Log.log("starting room %d", conf.id)
	Env.id = conf.id	
	Env.room = Room.new()
	Env.room:init()
	Env.match = match

	skynet.fork(match_loop)
	return true
end

function CMD.enter(info)
	if Env.room:enter(info) then
		return true
	else
		return false
	end
end

function CMD.leave(id)
	Env.room:leave(id)
end

function CMD.match(info)
	match:add(info)
	return 
end

function CMD.move(info, msg)
	local t = Env.room:get_table_by_player_id(info.id)

	t:move(info, msg)
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
end)
