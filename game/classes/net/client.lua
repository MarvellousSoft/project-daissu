local Class = require "extra_libs.hump.class"
local sock = require "extra_libs.sock"

local Client = {}

local client

function Client.start(server_ip)
    assert(client == nil)
    print('Will connect to ' .. server_ip)

    client = sock.newClient(server_ip, 47123)
    client:on('connect', function()
        print('Connected to server')
    end)
    client:connect()
end

function Client.update(dt)
    if client then
        client:update()
    end
end

function Client.send(event, data)
    assert(client ~= nil)
    client:send(event, data)
end

function Client.listenOnce(event, callback)
    assert(client ~= nil)
    local function c(...)
        client:removeCallback(c)
        callback(...)
    end
    client:on(event, c)
end

return Client
