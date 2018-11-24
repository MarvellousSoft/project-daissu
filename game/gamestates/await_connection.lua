local Font = require "font"
local Color = require "classes.color.color"
local Gamestate = require "extra_libs.hump.gamestate"
local Client = require "classes.net.client"
local Util = require "util"

local state = {}

function state:enter(prev, host, char_type)
    print('CLIENT INIT')
    Client.start(host)
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
