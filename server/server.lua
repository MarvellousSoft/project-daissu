local sock = require "common.extra_libs.sock"
local validateType = require "type_validator"

local Server = {}

local server

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

function Server.checkSchema(client, schema, data)
    if not validateType(schema, data) then
        -- document error numbers
        client:disconnect(1)
        return false
    end
    return true
end

return Server

