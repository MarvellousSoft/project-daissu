local Vector = require "extra_libs.hump.vector"
local Timer = require "extra_libs.hump.timer"
local FadingText = require "classes.fading_text"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local RunAndHit = {}

function RunAndHit.applyAction(controller, di, dj)
    local c = controller
    local tile = c.map:get(c.i + di, c.j + dj)
    if tile and not tile:blocked() then
        GridHelper.movePlayer(controller, c.i + di, c.j + dj)
        tile = c.map:get(c.i + di, c.j + dj)
        if tile then tile:applyDamage(3) end
    end
end

function RunAndHit.showAction(controller, callback, di, dj)
    local c = controller
    local map_view = c.map.view
    Timer.tween(0.5, c.player, {dx = dj, dy = di}, 'in-out-quad', function()
        FadingText(map_view.pos + Vector(c.j + 2 * dj - 1, c.i + 2 * di - 1) * map_view.cell_size, "-3", 0.5)
        Timer.after(0.5, function()
            RunAndHit.applyAction(controller, di, dj)
            c.player:resetAnimation()
            if callback then callback() end
        end)
    end)
end

function RunAndHit.getInputHandler(controller, callback)
    local c = controller
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(c.i, c.j, i, j) == 1
        end,
        finish = function(self, i, j)
            return RunAndHit.showAction(controller, callback, i - c.i, j - c.j)
        end
    }
end

return RunAndHit
