local Vector = require "extra_libs.hump.vector"
local Timer = require "extra_libs.hump.timer"
local FadingText = require "classes.fading_text"
local GridHelper = require "classes.map.grid_helper"

local StrongPunch = {}

function StrongPunch.applyAction(controller, i, j)
    controller.map:get(i, j):applyDamage(2)
end

function StrongPunch.showAction(controller, callback, i, j)
    local map_view = controller.map.view
    FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-2", 1)
    Timer.after(1, function()
        StrongPunch.applyAction(controller, i, j)
        controller.player:resetAnimation()
        if callback then callback() end
    end)
end

function StrongPunch.getInputHandler(controller, callback)
    local c = controller
    return {
        accept = function(i, j)
            return GridHelper.manhattanDistance(c.i, c.j, i, j) == 1
        end,
        finish = function(i, j)
            return StrongPunch.showAction(controller, callback, i, j)
        end
    }
end

return StrongPunch
