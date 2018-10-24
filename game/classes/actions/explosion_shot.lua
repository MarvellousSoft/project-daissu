local Color = require "classes.color.color"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"
local ActionInputHandler = require "classes.actions.action_input_handler"

local ExplosionShot = {}

function ExplosionShot.showAction(controller, callback, di, dj)
    local pi, pj = controller:getPosition()
    local map_view = controller.map.view
    local _, ti, tj = GridHelper.firstBlockedPos(controller.map, pi, pj, di, dj)
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            tile = controller.map:get(ti + di, tj + dj)
            if tile then
                local damage = (di == 0 and dj == 0) and 2 or 1
                FadingText(map_view.pos + Vector(tj + dj - 1, ti + di - 1) * map_view.cell_size,
                           "-"..damage, 1)
            end
        end
    end
    Timer.after(1, function()
        ExplosionShot.applyAction(controller, di, dj)
        controller.player:resetAnimation()
        if callback then callback() end
    end)
end

function ExplosionShot.applyAction(controller, di, dj)
    local pi, pj = controller:getPosition()
    local _, ti, tj = GridHelper.firstBlockedPos(controller.map, pi, pj, di, dj)
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            tile = controller.map:get(ti + di, tj + dj)
            if tile then
                local damage = (di == 0 and dj == 0) and 2 or 1
                tile:applyDamage(damage)
            end
        end
    end
end

function ExplosionShot.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(pi, pj, i, j) == 1
        end,
        finish = function(self, i, j)
            ExplosionShot.showAction(controller, callback, i - pi, j - pj)
        end,
        hover_color = function(self, mi, mj, i, j)
            local _, ti, tj = GridHelper.firstBlockedPos(controller.map, pi, pj, mi - pi, mj - pj)
            if i == ti and j == tj then
                return Color.red()
            elseif GridHelper.maximumAxisDistance(i, j, ti, tj) == 1 then
                return Color.orange()
            end
        end
    }
end

return ExplosionShot
