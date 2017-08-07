local skynet = require "skynet"
require "skynet.manager"
local bsonlib = require "bson" 

local host = "127.0.0.1"
local db_client
local db_name = "poker"
local db

local CMD = {}

function CMD.init()
	db_client = mongo.client({host = host})
	db_client:getDB(db_name)
	db = db_client[db_name]
end

function CMD.findOne(cname, selector, field_selector)
	return db[cname]:findOne(selector, field_selector)
end

function CMD.find(cname, selector, field_selector)
	return db[cname]:find(selector, field_selector)
end

function CMD.update(cname, ...)
	local collection = db[cname]
	collection:update(...)
	local r = db:runCommand("getLastError")
	if r.err ~= bsonlib.null then
		return false, r.err
	end

	if r.n <= 0 then
		skynet.error("mongodb update "..cname.." failed")
	end

	return ok, r.err
end

local ops = {'insert', 'batch_insert', 'delete'}
for _, v in ipairs(ops) do
    CMD[v] = function(self, cname, ...)
        local c = db[cname]
        c[v](c, ...)
        local r = db:runCommand('getLastError')
        local ok = r and r.ok == 1 and r.err == Bson.null
        if not ok then
            skynet.error(v.." failed: ", r.err, tname, ...)
        end
        return ok, r.err
    end
end

skynet.start(function()
	skynet.dispatch("lua", function (session, addr, command, ...)
		local f = CMD[command]
		if not f then
			
		end

		local ok, ret = pcall(f, ...)
		if ok then
			skynet.ret(skynet.pcak(ret))
		end
	end)

	skynet.register("mongodb")
end)
