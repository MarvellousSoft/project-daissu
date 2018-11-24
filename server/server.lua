local sock = require "common.extra_libs.sock"

local Server = {}

local server

local client_list = {}

function Server.init()
    assert(server == nil)

    server = sock.newServer("0.0.0.0", 47111)
    print('Starting server at port 47111') io.flush()
end

function Server.update()
    server:update()
end

function Server.on(event, callback)
    return server:on(event, callback)
end

function Server.removeCallback(callback)
    server:removeCallback(callback)
end

function Server.clientIterator()
    return ipairs(client_list)
end

return Server

