local Class = require "extra_libs.hump.class"
local sock = require "extra_libs.sock"
-- only used to get the IP
local socket = require "socket"

local Server = {}

local ip
local server

function Server.start()
    assert(server == nil)

    -- https://stackoverflow.com/a/8979647
    -- Couldn't find a better way to get the IP
    local tmp_socket = socket.udp()
    temp_socket:setpeername("74.125.115.104",80)
    ip = temp_socket:getsockname()

    -- weird port to avoid collisions
    server = sock.createServer("*", 47123)
    print("Connect to", ip)
end

function Server.update(dt)
    if server then
        server:update()
    end
end

return Server
