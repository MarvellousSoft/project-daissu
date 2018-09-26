local Class = require "extra_libs.hump.class"

local MapTile = Class {}

function MapTile:init(obj)
    self:setObj(obj)
end

function MapTile:setObj(obj)
    self.obj = obj
end

-- drawing starting on a tile of size size starting on x, y
function MapTile:drawOnGrid(x, y, size)
    if self.obj ~= nil then
        self.obj:drawOnGrid(x, y, size)
    end
end

return MapTile
