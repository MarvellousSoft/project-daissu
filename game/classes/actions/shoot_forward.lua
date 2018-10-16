local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Element = require "classes.primitives.element"
local Font = require "font"
local Timer = require "extra_libs.hump.timer"

local ShootForward = {}

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

function ShootForward.showAction(controller, callback)
    local c = controller
    local i, j = Vec.add(c.i, c.j, unpack(dir[c.player.dir]))
    local tile = c.map:get(i, j)
    local map_view = c.map.view
    while tile do
        if tile:blocked() then break end
        FadingText(map_view.pos + Vector(j - 1, i - 1) * map_view.cell_size, "-1", 1)
        i, j = Vec.add(i, j, unpack(dir[c.player.dir]))
        tile = c.map:get(i, j)
    end
    if callback then Timer.after(1, callback) end
end

function ShootForward.applyAction(controller)
    local c = controller
    local i, j = Vec.add(c.i, c.j, unpack(dir[c.player.dir]))
    local tile = c.map:get(i, j)
    while tile do
        tile:applyDamage(1)
        if tile:blocked() then break end
        i, j = Vec.add(i, j, unpack(dir[c.player.dir]))
        tile = c.map:get(i, j)
    end
end

return ShootForward
