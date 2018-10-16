local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Class     = require "extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"

local funcs = {}

--CLASS DEFINITION--

local DieSlotView = Class{
    __includes={DRAWABLE, VIEW},
    margin = 10
}

function DieSlotView:init(die_slot, pos)
    DRAWABLE.init(self, pos.x, pos.y)
    VIEW.init(self, die_slot)

    --Graphic variable
    local w, h = DieHelper.getDieDimensions()
    self.w = w + 2 * DieSlotView.margin
    self.h = h + 2 * DieSlotView.margin
    self.line_width = 5

    self.free_image = IMG.die_slot_free
    self.has_dice_over_image = IMG.die_slot_over --If player is dragging a dice over this object
    self.occupied_image = IMG.die_slot_occupied

end

--CLASS FUNCTIONS--
function DieSlotView:draw()
    local dieslot = self:getObj()
    local g = love.graphics

    --Get proper image
    local image
    if dieslot.die then
        image = self.occupied_image
    else
        image = self.free_image
    end

    --Draw die slot
    Color.set(Color.white())
    local sw = self.w/image:getWidth()
    local sh = self.h/image:getHeight()
    g.draw(image, self.pos.x, self.pos.y, nil, sw, sh)
end

--UTILITY FUNCTIONS--

--Return width and height of this slot
function DieSlotView.getSize()
    local w, h = DieHelper.getDieDimensions()
    w = w + 2 * DieSlotView.margin
    h = h + 2 * DieSlotView.margin
    return w, h
end

return DieSlotView
