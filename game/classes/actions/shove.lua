local Vector = require "extra_libs.hump.vector"
local Timer = require "extra_libs.hump.timer"
local FadingText = require "classes.fading_text"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local Shove = {}

function Shove.applyAction(controller, di, dj)
    local pi, pj = controller:getPosition()
    local tile = controller.player.tile:getCloseTile(controller.map, di, dj)
    if not tile then return end
    tile:applyDamage(1)
    if tile.obj then
        GridHelper.pushObject(controller.map, tile.i, tile.j, di, dj, 2)
    end
end

function Shove.showAction(controller, callback, di, dj)
    local pi, pj = controller:getPosition()
    local map_view = controller.map.view
    FadingText(map_view.pos + Vector(pj + dj - 1, pi + di - 1) * map_view.cell_size, "-1", 1)
    Timer.after(1, function()
        Shove.applyAction(controller, di, dj)
        controller.player:resetAnimation()
        if callback then callback() end
    end)
end

function Shove.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(pi, pj, i, j) == 1
        end,
        finish = function(self, i, j)
            return Shove.showAction(controller, callback, i - pi, j - pj)
        end
    }
end

return Shove
