local Class = require "extra_libs.hump.class"
local MapTile = require "classes.map.map_tile"

local Map = Class {}

function Map:init(rows, columns)
    self.rows = rows
    self.columns = columns
    self.grid = {}
    for i = 1, rows do
        self.grid[i] = {}
        for j = 1, columns do
            self.grid[i][j] = MapTile(nil, i, j)
        end
    end
end

function Map:get(r, c)
    return self.grid[r] and self.grid[r][c]
end

return Map
