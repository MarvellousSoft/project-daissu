local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"
local ActionInputHandler = require "classes.actions.action_input_handler"

local ExplosionShot = {}

function ExplosionShot.showAction(controller, callback, di, dj)
    local c = controller
    local map_view = c.map.view
    GridHelper.applyCallbackOnDirection(c.i, c.j, di, dj, c.map, function(tile, i, j)
        if tile == nil or tile:blocked() then
            print(i,j,"block")
            for di = -1, 1, 1 do
                for dj = -1, 1, 1 do
                    tile = c.map:get(i+di,j+dj)
                    print(c.i+di,c.j+dj)
                    if tile then
                        local damage = (di == 0 and dj == 0) and 2 or 1
                        FadingText(map_view.pos + Vector(j + dj - 1, i + di - 1) * map_view.cell_size,
                                   "-"..damage, 1)
                    end
                end
            end
            return false
        end
        print(i,j,"notblock")
        return true
    end)
    Timer.after(1, function()
        ExplosionShot.applyAction(c, di, dj)
        c.player:resetAnimation()
        if callback then callback() end
    end)
end

function ExplosionShot.applyAction(controller, di, dj)
    local c = controller
    GridHelper.applyCallbackOnDirection(c.i, c.j, di, dj, c.map, function(tile, i, j)
        if tile == nil or tile:blocked() then
            for di = -1, 1, 1 do
                for dj = -1, 1, 1 do
                    tile = c.map:get(i+di,j+dj)
                    if tile then
                        local damage = (di == 0 and dj == 0) and 2 or 1
                        tile:applyDamage(damage)
                    end
                end
            end
            return false
        end
        return true
    end)
end

function ExplosionShot.getInputHandler(controller, callback)
    local c = controller
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(c.i, c.j, i, j) == 1
        end,
        finish = function(self, i, j)
            ExplosionShot.showAction(c, callback, i - c.i, j - c.j)
        end,
        hover_color = nil
    }
end

return ExplosionShot
