local skynet = require "skynet"
local log = require "log"
local protopack = require "protopack"
local socket = require "socket"

local gate
local SOCKET = {}
local agents = {}

---------------------------socket数据处理----------------------------
local sock_handler = {}

sock_handler["Login.LoginReq"] = function (fd, msg)

	-- 校验用户名密码、获取token
	local token = "111"

	SOCKET.send(fd, "Login.LoginRsp", {account = msg.account, token = token})

	agents[fd] = skynet.newservice("agent")
	skynet.call(agents[fd], "lua", "start", {gate = gate,
		fd = fd, watchdog = skynet.self(), account = msg.account})
	
	log.log("verify account %s success!", msg.account)
end

------------------------ socket消息开始 -----------------------------
function SOCKET.open(fd, addr)
	log.log("New client from : %s", addr)
	skynet.call(gate, "lua", "accept", fd)
end

local function close_agent(fd)
	local a = agents[fd]
	agents[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	log.log("socket close fd=%d", fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	log.log("socket error fd = %d msg=%s", fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	log.log("socket warning fd=%d size=%d", fd, size)
end

function SOCKET.data(fd, data)
	local name, msg = protopack.unpack(data)
	print(name)
	sock_handler[name](fd, msg)
end

function SOCKET.send(fd, name, msg)
	local data = protopack.pack(name, msg)
	socket.write(fd, data)
end

------------------------ socket消息结束-----------------------------

local CMD = {}
function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")
end)
