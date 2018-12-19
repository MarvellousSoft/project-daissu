local Class = require "common.extra_libs.hump.class"

--[[
    A MapTile is a tile, it may keep an object. In the future, it may also store stuff as ground type, etc.
]]
local MapTile = Class {}

function MapTile:init(i, j)
    self.i, self.j = i, j
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

function MapTile:getPosition()
    return self.i, self.j
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

return MapTile
