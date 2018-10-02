local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Class     = require "extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"

local funcs = {}

--CLASS DEFINITION--

local DieSlotView = Class{
    __includes={DRAWABLE, VIEW}
}

function DieSlotView:init(die_slot, x, y)
    DRAWABLE.init(self, x, y)
    VIEW.init(self, die_slot)

    --Graphic variable
    local w, h = DieHelper.getDieDimensions()
    self.margin = 3 --How much larger the slot is from a regular die
    self.w = w + 2*self.margin
    self.h = h + 2*self.margin
    self.line_width = 5

    self.free_color = Color.white()
    self.has_dice_over_color = Color.blue() --If player is dragging a dice over this object
    self.occupied_color = Color.green()
end

--CLASS FUNCTIONS--
function DieSlotView:draw()
    local dieslot = self:getObj()
    local g = love.graphics

    --Get proper color
    if dieslot.die then
        color = self.occupied_color
    else
        color = self.free_color
    end
    Color.set(color)

    --Draw die slot
    g.setLineWidth(self.line_width)
    g.rectangle("line", self.pos.x, self.pos.y, self.w, self.h, 5, 5)
end

return DieSlotView
