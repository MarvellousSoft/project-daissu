local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"

local MapTileView = Class {
    __includes = {View}
}

-- drawing starting on a tile of size size starting on x, y
function MapTileView:drawOnGrid(x, y, size)
    local t = self.obj
    if t.obj ~= nil then
        t.obj.view:drawOnGrid(x, y, size)
    end
end

return MapTileView
