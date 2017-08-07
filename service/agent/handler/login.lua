local Env = require "env"
local Player = require "player"
local Log = require "log"
local M = {}

function M.ready()
	if Env.player then
		return
	end

	local player = Player.new()

	player:load(Env.account)

	Env.player = player

	Log.log("%s is ready", Env.account)
end

function M.register()
	Env.dispatcher:register("Login.Ready", M.ready)
end

return M
