local Color = require "classes.color.color"
local Vector = require "common.extra_libs.hump.vector"
local Vec = require "common.extra_libs.hump.vector-light"
local Timer = require "common.extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"
local ActionInputHandler = require "classes.actions.action_input_handler"

local ShootForward = {}

function ShootForward.showAction(controller, callback, di, dj)
    local pi, pj = controller:getPosition()
    local map_view = controller.map.view
    GridHelper.applyCallbackOnDirection(pi, pj, di, dj, controller.map, function(tile, i, j)
        if tile == nil then return false end
        FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-1", 1)
        if tile:blocked() then return false end
        return true
    end)
    Timer.after(1, function()
        ShootForward.applyAction(controller, di, dj)
        controller.player:resetAnimation()
        if callback then callback() end
    end)
end

function ShootForward.applyAction(controller, di, dj)
    local pi, pj = controller:getPosition()
    GridHelper.applyCallbackOnDirection(pi, pj, di, dj, controller.map, function(tile)
        if tile ~= nil then tile:applyDamage(1) end
        return tile ~= nil and not tile:blocked()
    end)
end

function ShootForward.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(pi, pj, i, j) == 1
        end,
        finish = function(self, i, j)
            ShootForward.showAction(controller, callback, i - pi, j - pj)
        end,
        hover_color = function(self, mi, mj, i, j)
            if Vec.eq(mi - pi, mj - pj, GridHelper.directionFromTiles(pi, pj, i, j)) then
                return Color.red()
            end
        end
    }
end

return ShootForward
