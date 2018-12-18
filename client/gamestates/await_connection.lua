local Font = require "font"
local Color = require "classes.color.color"
local Gamestate = require "common.extra_libs.hump.gamestate"
local Client = require "classes.net.client"
local Util = require "steaming_util"

local state = {}

function state:enter(prev, options, host, char_type)
    Client.start(host)
    Client.listenOnce('connect', function()
        Gamestate.switch(require "gamestates.wait_room", options, char_type)
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
