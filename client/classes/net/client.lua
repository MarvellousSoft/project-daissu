local Class = require "common.extra_libs.hump.class"
local sock = require "common.extra_libs.sock"

local Client = {}

local client

function Client.start(server_ip)
    assert(client == nil)
    print('Will connect to ' .. server_ip)

    client = sock.newClient(server_ip, 47111)
    client:on('connect', function()
        print('Connected to server')
    end)
    client:on('disconnect', function(code)
        print('I was disconnected. Code = ' .. tostring(code))
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

function Client.on(event, callback)
    return client:on(event, callback)
end

function Client.removeCallback(callback)
    return client:removeCallback(callback)
end

function Client.getConnectId()
    return client:getConnectId()
end

function Client.quit()
    if client ~= nil then
        client:disconnectNow()
    end
end

return Client
