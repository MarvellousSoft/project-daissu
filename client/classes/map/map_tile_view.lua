local Class  = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local Color  = require "classes.color.color"
local View   = require "classes.primitives.view"

local MapTileView = Class {
    __includes = View
}

-- drawing starting on a tile of size size starting on x, y
function MapTileView:drawOnGrid(match, x, y, size)
    local i, j = self.model.i, self.model.j
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
    if self.model.obj ~= nil then
        self.model.obj:drawOnGrid(x, y, size)
    end
end

return MapTileView
