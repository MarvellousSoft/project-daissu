local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Color = require "classes.color.color"

--[[
    A MapTile is a tile, it may keep an object. In the future, it may also store stuff as ground type, etc.
]]
local MapTile = Class {}

function MapTile:init(obj, i, j)
    self.i, self.j = i, j
    self:setObj(obj)
end

function MapTile:setObj(obj)
    assert(self.obj == nil or obj == nil)
    if self.obj ~= nil then
        self.obj.tile = nil
    end
    self.obj = obj
    if obj ~= nil then
        assert(obj.tile == nil)
        obj.tile = self
    end
end

function MapTile:blocked()
    return self.obj ~= nil
end

function MapTile:applyDamage(dmg)
    if self.obj ~= nil and self.obj.applyDamage then
        self.obj:applyDamage(dmg)
    end
end

function MapTile:getCloseTile(map, di, dj)
    return map:get(self.i + di, self.j + dj)
end

-- drawing starting on a tile of size size starting on x, y
function MapTile:drawOnGrid(match, x, y, size)
    local i, j = self.i, self.j
    if match.action_input_handler then
        local mi, mj = match.map_view:getTileOnPosition(Vector(love.mouse.getPosition()))
        love.graphics.setColor(20, 200, 50, 80)
        local color = nil
        if mi and match.action_input_handler:accept(mi, mj) then
            local hover_color = match.action_input_handler:hover_color(mi, mj, i, j)
            if hover_color then
                hover_color.a = 170
                color = hover_color
            end
        end
        if color == nil and match.action_input_handler:accept(i, j) then
            color = Color.green()
            color.a = 80
        end
        if color then
            Color.set(color)
            love.graphics.rectangle('fill', x, y, size, size)
        end
    end
    if self.obj ~= nil then
        self.obj:drawOnGrid(x, y, size)
    end
end

return MapTile
