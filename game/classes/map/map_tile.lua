local Class = require "extra_libs.hump.class"

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

-- drawing starting on a tile of size size starting on x, y
function MapTile:drawOnGrid(x, y, size)
    if self.obj ~= nil then
        self.obj:drawOnGrid(x, y, size)
    end
end

return MapTile
