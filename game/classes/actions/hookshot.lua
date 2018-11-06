local Color = require "classes.color.color"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local Hookshot = {}

local function whatIsPulledWhere(controller, di, dj)
    local pi, pj = controller:getPosition()
    local tile, ti, tj = GridHelper.firstBlockedPos(controller.map, pi, pj, di, dj)
    if tile ~= nil and tile:blocked() and tile.obj.type ~= 'Player' then
        ti, tj = ti - di, tj - dj
        tile = tile:getCloseTile(controller.map, -di, -dj)
    end
    if tile and tile:blocked() then
        return tile.obj, pi + di, pj + dj
    else
        return controller.player, ti, tj
    end
end

function Hookshot.showAction(controller, callback, di, dj)
    local obj, ni, nj = whatIsPulledWhere(controller, di, dj)
    Timer.tween(0.5, obj, {dx = nj - obj.tile.j, dy = ni - obj.tile.i}, 'in-out-quad', function()
        Hookshot.applyAction(controller, di, dj)
        obj:resetAnimation()
        if callback then callback() end
    end)
end

function Hookshot.applyAction(controller, di, dj)
    local obj, ni, nj = whatIsPulledWhere(controller, di, dj)
    GridHelper.moveObject(controller.map, obj.tile.i, obj.tile.j, ni, nj)
end

function Hookshot.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            local di, dj = Vec.sub(i, j, pi, pj)
            if not GridHelper.isDirection(di, dj) then return false end
            local tile, ti, tj = GridHelper.firstBlockedPos(controller.map, pi, pj, di, dj)
            if (tile == nil and Vec.eq(ti, tj, pi, pj)) or (tile ~= nil and Vec.eq(ti, tj, pi + di, pj + dj)) then
                return false
            end
            return true
        end,
        finish = function(self, i, j)
            Hookshot.showAction(controller, callback, GridHelper.directionFromTiles(pi, pj, i, j))
        end,
        hover_color = function(self, mi, mj, i, j)
            local obj, ti, tj = whatIsPulledWhere(controller, Vec.sub(mi, mj, pi, pj))
            if Vec.eq(ti, tj, i, j) then
                return Color.green()
            elseif Vec.eq(i, j, obj.tile.i, obj.tile.j) then
                return Color.yellow()
            end
        end
    }
end

return Hookshot
