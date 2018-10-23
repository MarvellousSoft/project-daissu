local Color = require "classes.color.color"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"
local ActionInputHandler = require "classes.actions.action_input_handler"

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
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(c.i, c.j, i, j) == 1
        end,
        finish = function(self, i, j)
            ShootForward.showAction(c, callback, i - c.i, j - c.j)
        end,
        hover_color = function(self, mi, mj, i, j)
            if Vec.eq(mi - c.i, mj - c.j, GridHelper.directionFromTiles(c.i, c.j, i, j)) then
                return Color.red()
            end
        end
    }
end

return ShootForward
