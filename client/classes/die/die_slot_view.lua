local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Class     = require "common.extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"
local Vector    = require "common.extra_libs.hump.vector"
local Actions   = require "classes.actions"
local UI        = require("assets").images.UI

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
    self.ori_y = self.pos.y
    self.line_width = 5

    self.has_die_over = false

    --Action associated with this slot
    self.action_image = nil
    self.action_color = nil
    self.action_alpha = 0

    --Images
    self.free_image = UI.die_slot_free
    self.has_dice_over_image = UI.die_slot_over --If player is dragging a dice over this object
    self.occupied_image = UI.die_slot_occupied
    self.wrong_image = UI.die_slot_wrong --If player cant put his die on this slot

    self.alpha = 255
end

function DieSlotView:centerDie(snap)
    local die = self:getModel().die
    assert(die ~= nil)
    die.view:slideTo(self.pos + Vector(self.margin, self.margin), snap)
end

--CLASS FUNCTIONS--

function DieSlotView:draw()
    local dieslot = self:getModel()
    local g = love.graphics

    --Get proper image
    local image
    if self.has_die_over then
        image = self.has_dice_over_image
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

    --Draw correspondent action, if any
    if self.action_image then
        local margin = 3
        local sw = (self.w-2*margin)/self.action_image:getWidth()
        local sh = (self.h-2*margin)/self.action_image:getHeight()
        local off = 2
        Color.setWithAlpha(Color.black(),self.action_alpha)
        g.draw(self.action_image, self.pos.x + margin + off, self.pos.y + margin + off, nil, sw, sh)
        Color.setWithAlpha(self.action_color, self.action_alpha)
        g.draw(self.action_image, self.pos.x + margin, self.pos.y + margin, nil, sw, sh)
    end
end

function DieSlotView:setAlpha(value)
    self.alpha = value
end

function DieSlotView:setAction(action, color)
    if action then
        self.action_image = Actions.actionImage(action)
        self.action_color = color
        self:removeTimer('change_action_visibility', MAIN_TIMER)
        self:addTimer('change_action_visibility', MAIN_TIMER, "tween", 1, self,
                      {action_alpha = 255}, 'out-quad')
    else
        self:removeTimer('change_action_visibility', MAIN_TIMER)
        self:addTimer('change_action_visibility', MAIN_TIMER, "tween", 1, self,
                      {action_alpha = 0}, 'out-quad',
                      function()
                          self.action_image = nil
                      end)
    end
end

function DieSlotView:setVisible(d, offset)
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 255}, 'out-quad')
    self.pos.y = self.ori_y - offset
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.ori_y}, 'out-quad')
end

function DieSlotView:setInvisible(d, offset)
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 0}, 'in-quad')
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.ori_y-offset}, 'in-quad')
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
