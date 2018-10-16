local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Element = require "classes.primitives.element"
local Font = require "font"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"

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

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

local ShootForward = {}

function ShootForward.showAction(controller, callback, di, dj)
    local c = controller
    local i, j = c.i + di, c.j + dj
    local tile = c.map:get(i, j)
    local map_view = c.map.view
    while tile do
        if tile:blocked() then break end
        FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-1", 1)
        i, j = i + di, j + dj
        tile = c.map:get(i, j)
    end
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
    local i, j = c.i + di, c.j + dj
    local tile = c.map:get(i, j)
    while tile do
        tile:applyDamage(1)
        if tile:blocked() then break end
        i, j = i + di, j + dj
        tile = c.map:get(i, j)
    end
end

function ShootForward.getInputHandler(controller, callback)
    local c = controller
    return {
        accept = function(i, j)
            return (i ~= c.i or j ~= c.j) and (i == c.i or j == c.j)
        end,
        finish = function(i, j)
            local di, dj = Util.sign(i - c.i), Util.sign(j - c.j)
            ShootForward.showAction(c, callback, di, dj)
        end
    }
end

return ShootForward
