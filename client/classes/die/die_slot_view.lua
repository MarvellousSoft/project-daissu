local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Class     = require "common.extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"
local Util      = require "util"
local Vector    = require "common.extra_libs.hump.vector"

local funcs = {}

--CLASS DEFINITION--

local DieSlotView = Class{
    __includes={DRAWABLE, VIEW},
    margin = DieHelper.getDieSlotMargin()
}

function DieSlotView:init(die_slot, pos)
    DRAWABLE.init(self, pos.x, pos.y)
    VIEW.init(self, die_slot)

    --Graphic variable
    local w, h = DieHelper.getDimensions()
    self.w = w + 2 * DieSlotView.margin
    self.h = h + 2 * DieSlotView.margin + DieHelper.getUnderside()
    self.line_width = 5

    --Images
    self.free_image = IMG.die_slot_free
    self.has_dice_over_image = IMG.die_slot_over --If player is dragging a dice over this object
    self.occupied_image = IMG.die_slot_occupied
    self.wrong_image = IMG.die_slot_wrong --If player cant put his die on this slot

    self.alpha = 255
end

function DieSlotView:centerDie(snap)
    local die = self:getObj().die
    assert(die ~= nil)
    die.view:slideTo(self.pos + Vector(self.margin, self.margin), snap)
end

--CLASS FUNCTIONS--

function DieSlotView:draw()
    local dieslot = self:getObj()
    local g = love.graphics

    local dice = Util.findSubtype("die_view")
    local has_die_over = false
    local die_player_number = false
    --for die_view in pairs(dice) do
    --    if die_view:getObj() ~= dieslot:getDie() and
    --       not die_view.is_moving and
    --       self.pos.x <= die_view.pos.x + die_view.w and
    --       self.pos.x + self.w >= die_view.pos.x and
    --       self.pos.y <= die_view.pos.y + die_view.h and
    --       self.pos.y + self.h >= die_view.pos.y then
    --           has_die_over = true
    --           die_player_number = die_view:getObj():getPlayer()
    --    end
    --end

    --Get proper image
    local image
    if has_die_over then
        if die_player_number == dieslot:getPlayer() then
            image = self.has_dice_over_image
        else
            image = self.wrong_image
        end
    elseif dieslot.die then
        image = self.occupied_image
    else
        image = self.free_image
    end

    --Draw die slot
    Color.setWithAlpha(Color.white(), self.alpha)
    local sw = self.w/image:getWidth()
    local sh = self.h/image:getHeight()
    g.draw(image, self.pos.x, self.pos.y, nil, sw, sh)
end

function DieSlotView:setAlpha(value)
    self.alpha = value
end

function DieSlotView:setVisible(d, offset)
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 255}, 'out-quad')
    self.pos.y = self.pos.y - offset
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.pos.y+offset}, 'out-quad')
end

function DieSlotView:setInvisible(d, offset)
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 0}, 'in-quad')
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.pos.y-offset}, 'in-quad')
end


--UTILITY FUNCTIONS--

--Return width and height of this slot
function DieSlotView.getSize()
    local w, h = DieHelper.getDimensions()
    w = w + 2 * DieSlotView.margin
    h = h + 2 * DieSlotView.margin
    return w, h
end

return DieSlotView
