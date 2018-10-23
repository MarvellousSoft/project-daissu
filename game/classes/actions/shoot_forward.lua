local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Element = require "classes.primitives.element"
local Font = require "font"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"

local FadingText = Class {
    __includes = {Element}
}

function FadingText:draw()
    Font.set('regular', 20)
    love.graphics.setColor(200, 20, 20, self.alpha)
    love.graphics.print(self.text, self.pos.x, self.pos.y)
end

function FadingText:init(pos, text, time)
    self.pos = pos
    self.text = text
    self.alpha = 255
    Timer.tween(time, self, {alpha = 0}, 'in-linear', function() self:kill() end)
    self:register('L1')
end

local ShootForward = {}

function ShootForward.showAction(controller, callback, di, dj)
    local c = controller
    local map_view = c.map.view
    GridHelper.applyCallbackOnDirection(c.i, c.j, di, dj, c.map, function(tile, i, j)
        if tile:blocked() then return false end
        FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-1", 1)
        return true
    end)
    if callback then
        Timer.after(1, function()
            ShootForward.applyAction(c, di, dj)
            c.player:resetAnimation()
            if callback then callback() end
        end)
    end
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
