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

-- This is VERY ugly. I'm doing an HTTP request by hand, since I need it
-- asynchronous and don't want to use other libraries
Server.external_ip = nil
local conn = socket.connect('myexternalip.com', 80)
conn:send('GET /raw HTTP/1.1\r\nHost: myexternalip.com\r\n\r\n')
local nx_line = false

function Server.update(dt)
    if conn ~= nil and Server.external_ip == nil then
        conn:settimeout(0)
        local rcv, status = conn:receive()
        while status ~= 'timeout' do
            if nx_line then
                conn = nil
                Server.external_ip = rcv
                break
            elseif rcv == '' then
                nx_line = true
            end
            rcv, status = conn:receive()
        end
    end
    if server then
        server:update()
    end
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
