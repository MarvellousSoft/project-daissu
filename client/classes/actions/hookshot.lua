local Color = require "classes.color.color"
local Vector = require "common.extra_libs.hump.vector"
local Vec = require "common.extra_libs.hump.vector-light"
local Timer = require "common.extra_libs.hump.timer"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"
local FadingText = require "classes.fading_text"

local Hookshot = {}

local function whatIsPulledWhere(map, player, di, dj)
    local pi, pj = player.tile:getPosition()
    local tile, ti, tj = GridHelper.firstBlockedPos(map, pi, pj, di, dj)
    if tile ~= nil and tile:blocked() and tile.obj.tile_type ~= 'Player' then
        ti, tj = ti - di, tj - dj
        tile = tile:getCloseTile(map, -di, -dj)
    end
    if tile and tile:blocked() then
        return tile.obj, pi + di, pj + dj
    else
        return player, ti, tj
    end
end

function Hookshot.showAction(controller, callback, di, dj)
    local obj, ni, nj = whatIsPulledWhere(controller.map, controller.player.model, di, dj)
    if obj ~= controller.player.model then
        local map_view = controller.map.view
        FadingText(map_view.pos + Vector(nj - 1, ni - 1) * map_view.cell_size, "-1", 1)
    end
    Timer.tween(0.5, obj.view, {dx = nj - obj.tile.j, dy = ni - obj.tile.i}, 'in-out-quad', function()
        obj.view:resetAnimation()
        if callback then callback() end
    end)
end

function Hookshot.applyAction(map, player, di, dj)
    local obj, ni, nj = whatIsPulledWhere(map, player, di, dj)
    GridHelper.moveObject(map, obj.tile.i, obj.tile.j, ni, nj)
    if obj ~= player then
        obj.tile:applyDamage(1)
    end
end

function Hookshot.getInputHandler(controller)
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
        processInput = function(self, i, j)
            return GridHelper.directionFromTiles(pi, pj, i, j)
        end,
        hover_color = function(self, mi, mj, i, j)
            local obj, ti, tj = whatIsPulledWhere(controller.map, controller.player.model, Vec.sub(mi, mj, pi, pj))
            if Vec.eq(ti, tj, i, j) then
                return Color.green()
            elseif Vec.eq(i, j, obj.tile.i, obj.tile.j) then
                return Color.yellow()
            end
        end
    }
end

return Hookshot
