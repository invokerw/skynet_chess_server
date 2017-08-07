local skynet = require "skynet"

local M = {}

M.__index = M

function M.new()
	local o = {map = {}}
	setmetatable(o, M)
	return o
end

function M:register(name, f, obj)
	self.map[name] = {f = f, obj = obj}
end

function M:dispatch(name, msg)
	local handler = self.map[name]
	if not handler then
		skynet.error("can't find handler:", name)
		return
	end

	if handler.obj then
		handler.f(handler.obj, msg)
	else
		handler.f(msg)
	end
end

return M
