local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"

local MapView = Class {
    __includes = {View}
}

function MapView:init(obj, pos, cell_size)
    View.init(self, obj)
    self.pos = pos
    self.cell_size = cell_size
end

function MapView:draw()
    local m = self.obj
    local x, y, size = self.pos.x, self.pos.y, self.cell_size
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    for i = 0, m.rows do
        love.graphics.line(x, y + i * size, x + m.columns * size, y + i * size)
    end
    for j = 0, m.columns do
        love.graphics.line(x + j * size, y, x + j * size, y + m.rows * size)
    end

    for i = 1, m.rows do
        for j = 1, m.columns do
            m.grid[i][j]:drawOnGrid(x + (j - 1) * size, y + (i - 1) * size, size)
        end
    end
end

return MapView
