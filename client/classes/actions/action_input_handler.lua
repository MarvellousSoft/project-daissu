local Color = require "classes.color.color"
local Class = require "common.extra_libs.hump.class"

local ActionInputHandler = Class {
    init = function(self, functions)
        if functions.accept then self.accept = functions.accept end
        if functions.processInput then self.processInput = functions.processInput end
        if functions.hover_color then self.hover_color = functions.hover_color end
    end,
    accept = function(self, i, j)
        return false
    end,
    processInput = function(self, ...)
        return ...
    end,
    --[[
    Mouse is currently at tile mi, mj (an accepted tile)
    Return the color that tile i, j should be drawn on screen
    ]]
    hover_color = function(self, mi, mj, i, j)
        assert(self:accept(mi, mj))
        if mi == i and mj == j then
            return Color.green()
        end
    end,
}

return ActionInputHandler
