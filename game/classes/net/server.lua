local Class = require "extra_libs.hump.class"
local sock = require "extra_libs.sock"
-- only used to get the IP
local socket = require "socket"

local Server = {}

local ip
local server

local client_list = {}

function Server.start()
    assert(server == nil)


    -- weird port to avoid collisions
    server = sock.newServer("*", 47123)

    server:on('connect', function(data, client)
        print('Client connected --', client)
        table.insert(client_list, client)
    end)

    server:on('disconnect', function(data, client)
        print('Client disconnected --', client)
        for i, cl in ipairs(client_list) do
            if cl == client then
                table.remove(client_list, i)
                return
            end
        end
    end)

    server:on('action input', function(data, client)
        for i, c in ipairs(client_list) do
            if c ~= client then
                c:send('action input', data)
            end
        end
    end)

    local actions, count = {}, 0
    server:on('actions locked', function(data, client)
        count = count + 1
        actions[data.i] = data.actions
        if count == #client_list then
            for i, c in ipairs(client_list) do
                c:send('turn ready', actions)
            end
            count = 0
            actions = {}
        end
    end)
end

function Server.update(dt)
    if server then
        server:update()
    end
end

function Server.get_ip()
    -- https://stackoverflow.com/a/8979647
    -- Couldn't find a better way to get the IP
    local temp_socket = socket.udp()
    temp_socket:setpeername("74.125.115.104",80)
    return temp_socket:getsockname()
end

function Server.on(event, callback)
    assert(server ~= nil)
    server:on(event, callback)
end

function Server.removeCallback(callback)
    assert(server ~= nil)
    server:removeCallback(callback)
end

function Server.clientIterator()
    assert(server ~= nil)
    return ipairs(client_list)
end

return Server
