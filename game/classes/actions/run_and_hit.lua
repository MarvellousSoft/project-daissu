local Vector = require "extra_libs.hump.vector"
local Timer = require "extra_libs.hump.timer"
local FadingText = require "classes.fading_text"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local RunAndHit = {}

function RunAndHit.applyAction(controller, di, dj)
    local pi, pj = controller:getPosition()
    local tile = controller.map:get(pi + di, pj + dj)
    if tile and not tile:blocked() then
        GridHelper.moveObject(controller.map, pi, pj, pi + di, pj + dj)
        tile = controller.map:get(pi + 2 * di, pj + 2 * dj)
        if tile then tile:applyDamage(3) end
    end
end

function RunAndHit.showAction(controller, callback, di, dj)
    local pi, pj = controller:getPosition()
    local map_view = controller.map.view
    Timer.tween(0.5, controller.player, {dx = dj, dy = di}, 'in-out-quad', function()
        FadingText(map_view.pos + Vector(pj + 2 * dj - 1, pi + 2 * di - 1) * map_view.cell_size, "-3", 0.5)
        Timer.after(0.5, function()
            RunAndHit.applyAction(controller, di, dj)
            controller.player:resetAnimation()
            if callback then callback() end
        end)
    end)
end

function RunAndHit.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(pi, pj, i, j) == 1
        end,
        finish = function(self, i, j)
            return RunAndHit.showAction(controller, callback, i - pi, j - pj)
        end
    }
end

return RunAndHit
