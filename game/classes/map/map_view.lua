local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"

local MapView = Class {
    __includes = {View}
}

function MapView:init(obj, pos, cell_size)
    View.init(self, obj)

    --Determine tile image and rotation for each map pos
    local ran = love.math.random
    self.tiles = {}
    for i = 1, obj.rows do
        self.tiles[i] = {}
        for j = 1, obj.columns do
            local image = ran() > .1 and IMG.maptile_regular or
                                         IMG.maptile_broken
            local sx = cell_size/image:getWidth()
            local sy = cell_size/image:getHeight()
            self.tiles[i][j] = {image = image, sx = sx, sy = sy}
        end
    end

    self.pos = pos
    self.cell_size = cell_size
end

function MapView:draw(match)
    local m, g = self:getObj(), love.graphics
    local x, y, size = self.pos.x, self.pos.y, self.cell_size
    local rows, columns = m.rows, m.columns

    --Draw grid background
    g.setColor(255, 255, 255)
    for i = 1, rows do
        for j = 1, columns do
            local tile = self.tiles[i][j]
            g.rectangle("fill",x + (j-1)*size,y + (i-1)*size, size, size)
            g.draw(tile.image, x + (j-1)*size, y + (i-1)*size, nil,
                   tile.sx, tile.sy)
        end
    end

    --Draw lines dividing grid
    love.graphics.setColor(0,0,0,150)
    love.graphics.setLineWidth(2)
    for i = 1, m.rows-1 do
        g.line(x, y + i * size, x + m.columns * size, y + i * size)
    end
    for j = 1, m.columns-1 do
        g.line(x + j * size, y, x + j * size, y + m.rows * size)
    end
    --Draw border lines
    love.graphics.setColor(0,0,0,210)
    love.graphics.setLineWidth(3)
    g.line(x, y, x + m.columns * size, y)
    g.line(x, y + m.rows * size, x + m.columns * size, y + m.columns * size)
    g.line(x, y, x, y + m.rows * size)
    g.line(x + m.columns * size, y, x + m.columns * size, y + m.rows * size)

    for i = 1, rows do
        for j = 1, columns do
            m.grid[i][j]:drawOnGrid(match, x + (j - 1) * size, y + (i - 1) * size, size)
        end
    end
end

function MapView:getTileOnPosition(pos)
    local i = math.floor((pos.y - self.pos.y) / self.cell_size) + 1
    local j = math.floor((pos.x - self.pos.x) / self.cell_size) + 1
    if i < 1 or i > self:getObj().rows or j < 1 or j > self:getObj().columns then
        return nil, nil
    else
        return i, j
    end
end

return MapView
