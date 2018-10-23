local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"

local ShootForward = {}

function ShootForward.showAction(controller, callback, di, dj)
    local c = controller
    local map_view = c.map.view
    GridHelper.applyCallbackOnDirection(c.i, c.j, di, dj, c.map, function(tile, i, j)
        FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-1", 1)
        if tile:blocked() then return false end
        return true
    end)
    Timer.after(1, function()
        ShootForward.applyAction(c, di, dj)
        c.player:resetAnimation()
        if callback then callback() end
    end)
end

function ShootForward.applyAction(controller, di, dj)
    local c = controller
    GridHelper.applyCallbackOnDirection(c.i, c.j, di, dj, c.map, function(tile)
        tile:applyDamage(1)
        return not tile:blocked()
    end)
end

function ShootForward.getInputHandler(controller, callback)
    local c = controller
    return {
        accept = function(i, j)
            return GridHelper.onSameRowOrColumn(i, j, c.i, c.j)
        end,
        finish = function(i, j)
            ShootForward.showAction(c, callback, GridHelper.directionFromTiles(c.i, c.j, i, j))
        end
    }
end

return ShootForward
