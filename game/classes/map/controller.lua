local Class = require "extra_libs.hump.class"
local Vec = require "extra_libs.hump.vector-light"
local Player = require "classes.map.player"
local Timer = require "extra_libs.hump.timer"

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

function Controller:showAction(action)
    if action == 'walk' then
        local tile = self.map:get(Vec.add(self.i, self.j, unpack(dir[self.player.dir])))
        if tile and not tile:blocked() then
            Timer.tween(1, self.player, {dx = dir[self.player.dir][2], dy = dir[self.player.dir][1]}, 'in-out-quad')
        end
    elseif action == 'clock' then
        Timer.tween(1, self.player, {d_dir = 1}, 'in-out-quad')
    elseif action == 'counter' then
        Timer.tween(1, self.player, {d_dir = -1}, 'in-out-quad')
    end
    Timer.after(1, function()
        self.player:resetAnimation()
        self:applyAction(action)
    end)
end

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
