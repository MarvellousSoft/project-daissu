local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"

--[[
    A MapTile is a tile, it may keep an object. In the future, it may also store stuff as ground type, etc.
]]
local MapTile = Class {}

function MapTile:init(obj)
    self:setObj(obj)
end

function MapTile:setObj(obj)
    self.obj = obj
end

function MapTile:blocked()
    return self.obj ~= nil
end

function MapTile:applyDamage(dmg)
    if self.obj ~= nil and self.obj.applyDamage then
        self.obj:applyDamage(dmg)
    end
end

-- drawing starting on a tile of size size starting on x, y
function MapTile:drawOnGrid(match, i, j, x, y, size)
    if match.action_input_handler and match.action_input_handler.accept(i, j) then
        if Vec.eq(i, j, match.map_view:getTileOnPosition(Vector(love.mouse.getPosition()))) then
            love.graphics.setColor(20, 200, 50, 170)
        else
            love.graphics.setColor(20, 200, 50, 80)
        end
        love.graphics.rectangle('fill', x, y, size, size)
    end
    if self.obj ~= nil then
        self.obj:drawOnGrid(x, y, size)
    end
end

return MapTile
