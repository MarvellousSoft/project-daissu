local Font = require "font"
local Color = require "classes.color.color"
local Gamestate = require "extra_libs.hump.gamestate"
local Server = require "classes.net.server"
local Client = require "classes.net.client"
local Util = require "util"

local state = {}

function state:enter(prev, host, char_type)
    if host == true then -- this is the server
        print('SERVER INIT')
        Server.start()
        local count = 0
        local function callback()
            count = count + 1
            if count == 2 then
                for i, client in Server.clientIterator() do
                    client:send('start game', i)
                end
                Server.removeCallback(callback)
            end
        end
        Server.on('connect', callback)
        Client.start('localhost')
    else
        print('CLIENT INIT')
        Client.start(host)
    end
    Client.listenOnce('start game', function(i)
        Gamestate.switch(require "gamestates.game", i, char_type)
    end)
end

function state:leave()
end


function state:update(dt)
    Util.updateTimers(dt)

    Util.updateDrawTable(dt)

    Util.destroyAll()
end

function state:draw()
    Color.set(Color.white())
    Font.set('regular', 50)
    love.graphics.print("Waiting for connection...", 300, 300)
end

--Return state functions
return state
