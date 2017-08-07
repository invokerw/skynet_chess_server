local skynet = require "skynet"
local socket = require "socket"
local dispatcher = require "dispatcher"
local protopack = require "protopack"
local login = require "handler.login"
local room = require "handler.room"
local table = require "handler.table"
local env = require "env"
local player = require "player"

local CONF

env.send_msg = function (name, msg)
	local data = protopack.pack(name, msg)
	socket.write(CONF.fd, data)
end

local sock_dispatcher = dispatcher.new()
env.dispatcher = sock_dispatcher

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (data, sz)
		print("agent recv socket data",sz)
		return skynet.tostring(data,sz)
	end,
	dispatch = function (_, _, str)
		local name, msg = protopack.unpack(str)
		sock_dispatcher:dispatch(name, msg)
	end
}

local CMD = {}

function CMD.start(conf)
	CONF = conf
	env.account = conf.account
	player:load(env.account)
	login.register()
	room.register()
	table.register()
	skynet.call(conf.gate, "lua", "forward", conf.fd)
end

function CMD.disconnect()
	skynet.exit()
end

function CMD.send(name, msg)
	env.send_msg(name, msg)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
