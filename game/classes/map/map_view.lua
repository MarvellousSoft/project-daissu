local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"

local MapView = Class {
    __includes = {View}
}

-- drawing starting on x, y with cell size size
function MapView:draw(x, y, size)
    local m = self.obj
    for i = 1, m.rows do
        for j = 1, m.columns do
            m.grid[i][j].view:drawOnGrid(x + (j - 1) * size, y + (i - 1) * size, size)
        end
    end
end

return MapView
