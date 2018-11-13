local Class = require "extra_libs.hump.class"
local Player = require "classes.map.player"
local Client = require "classes.net.client"

--[[
    A Controller is a class that handles the actions of a player. It keeps a Player object and moves it around the map.
]]

local Controller = Class {}

-- Start controller with a player on map on position pos
function Controller:init(map, color, i, j, source)
    self.map = map
    self.source = source
    self.player = Player(color)
    map:get(i, j):setObj(self.player)
end

function Controller:getPosition()
    return self.player.tile.i, self.player.tile.j
end

function Controller:waitForInput(match, input_handler)
    if self.source == 'local' then
        local old_func = input_handler.finish
        input_handler.finish = function(self, ...)
            Client.send('action input', {...})
            old_func(self, ...)
        end
        match.action_input_handler = input_handler
    elseif self.source == 'remote' then
        Client.listenOnce('action input', function(data)
            input_handler:finish(unpack(data))
        end)
    end
end

return Controller
