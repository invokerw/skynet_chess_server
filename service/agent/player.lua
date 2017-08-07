local skynet = require "skynet"

local Player = {}
-- id
-- account
-- name
-- agent

Player.__index = Player

function Player.new()
	local o = {}
	setmetatable(o, Player)
	return o
end

-- 数据库加载玩家数据
function Player:load(account)
	self.id = skynet.self()
	self.account = account
	self.name = "account"..account
	self.agent = skynet.self()
end

return Player
