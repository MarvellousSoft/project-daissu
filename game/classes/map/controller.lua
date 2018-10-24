local Class = require "extra_libs.hump.class"
local Player = require "classes.map.player"

--[[
    A Controller is a class that handles the actions of a player. It keeps a Player object and moves it around the map.
]]

local Controller = Class {}

-- Start controller with a player on map on position pos
function Controller:init(map, color, i, j)
    self.map = map
    self.player = Player(color)
    map:get(i, j):setObj(self.player)
end

function Controller:getPosition()
    return self.player.tile.i, self.player.tile.j
end

return Controller
