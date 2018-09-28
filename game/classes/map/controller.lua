local Class = require "extra_libs.hump.class"
local Vec = require "extra_libs.hump.vector-light"
local Player = require "classes.map.player"

--[[
    A Controller is a class that handles the actions of a player. It keeps a Player object and moves it around the map.
]]

local Controller = Class {}

-- Start controller with a player on map on position pos
function Controller:init(map, i, j)
    self.map = map
    self.i, self.j = i, j
    self.player = Player()
    map:get(i, j):setObj(self.player)
end

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

-- Apply action on Controller's player
function Controller:applyAction(action)
    if action == 'walk' then
        local tile = self.map:get(Vec.add(self.i, self.j, unpack(dir[self.player.dir])))
        if not tile or tile:blocked() then
            print("Movement is invalid")
        else
            self.map:get(self.i, self.j):setObj(nil)
            tile:setObj(self.player)
            self.i, self.j = Vec.add(self.i, self.j, unpack(dir[self.player.dir]))
        end
    elseif action == 'clock' then
        self.player:rotate(1)
    elseif action == 'counter' then
        self.player:rotate(-1)
    else
        error("Unknown action")
    end
end

return Controller
