local Class       = require "common.extra_libs.hump.class"
local Vector      = require "common.extra_libs.hump.vector"
local View        = require "classes.primitives.view"
local Element     = require "classes.primitives.element"
local DieSlotView = require "classes.die.die_slot_view"
local DieHelper   = require "classes.die.helper"

local TurnSlotsView = Class {
    __includes = {View, Element}
}

function TurnSlotsView:init(obj, pos, w, h, color, player_num)
    Element.init(self)
    View.init(self, obj)
    local slots_n = #obj.slots
    local d_w, d_h = DieHelper.getDimensions()

    -- Accounting for margin in DieSlots
    d_w = d_w + 2*DieHelper.getDieSlotMargin()
    d_h = d_h + 2*DieHelper.getDieSlotMargin() + DieHelper.getUnderside()

    local margin = 10
    for i, slot in ipairs(obj.slots) do
        local view = DieSlotView(slot, Vector(margin + pos.x + (i - 1) * (w - 2*margin - d_w) / (slots_n - 1), pos.y + (h - d_h)/2))
        view:setSubtype("die_slot_view")
    end

    self.pos = pos
    self.w, self.h = w, h

    --Bg image
    self.image = IMG["turn_slots_"..color]
    self.iw = self.w/self.image:getWidth()
    self.ih = self.h/self.image:getHeight()

    --Starting player image
    self.starting_player_image = IMG["starting_player_"..color]

    --Current slot image
    self.current_action_image = IMG["current_action_"..color]

    --Transparency for this object
    self.alpha = 255

end

function TurnSlotsView:draw(draw_starting_player, position)
    --Draw turn slots background
    love.graphics.setColor(0, 0, 0, self.alpha)
    local off = 8
    love.graphics.draw(self.image, self.pos.x+off, self.pos.y+off, nil,
                       self.iw, self.ih)
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.iw, self.ih)

    --Draw each slot
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:draw(self.alpha)
    end

    --Draw starting player icon, if needed
    if draw_starting_player then
        love.graphics.setColor(255, 255, 255, self.alpha)
        local image = self.starting_player_image
        local x, sx
        local gap_x, gap_y = 10, 15
        if position == 'left' then
            x = self.pos.x + gap_x
            sx = 1
        elseif position == 'right' then
            x = self.pos.x + self.w - gap_x
            sx = -1
        else
            error("Not a valid position: "..position)
        end
        love.graphics.draw(image, x, self.pos.y - image:getHeight() - gap_y, nil, sx, 1)
    end
end

--Given an index, draw an arrow above given slot
function TurnSlotsView:drawCurrentAction(index, alpha)
    local scale = alpha and 1 or 1.5
    alpha = alpha or 255
    local s_v = self:getObj().slots[index].view
    local image = self.current_action_image
    local x = s_v.pos.x + s_v.w/2 - image:getWidth()*scale/2
    local gap, magnitude, max_offset = 5, 7, 5
    local offset = math.sin(magnitude*love.timer.getTime())*max_offset
    local y = s_v.pos.y - gap - image:getHeight()*scale - offset
    love.graphics.setColor(255,255,255, alpha)
    love.graphics.draw(image, x, y, nil, scale)
end

--Given an index, draw an arrow above given slot to represent next action to be played
function TurnSlotsView:drawNextAction(index)
    self:drawCurrentAction(index, 150)
end


--Return all dice in its slots
function TurnSlotsView:getDice()
    local t = {}
    for i, slot in ipairs(self:getObj().slots) do
        if slot:getDie() then
            table.insert(t,slot:getDie())
        end
    end
    return t
end

function TurnSlotsView:setAlpha(value)
    self.alpha = value
end

function TurnSlotsView:setVisible()
    self:removeTimer('change_visibility');
    self:addTimer('change_visibility', MAIN_TIMER, "tween", 0.5, self,
                  {alpha = 255}, 'out-quad')
    local offset = 20
    self.pos.y = self.pos.y - offset
    self:removeTimer('change_offset');
    self:addTimer('change_offset', MAIN_TIMER, "tween", 0.5, self.pos,
                  {y = self.pos.y+offset}, 'out-quad')
end

function TurnSlotsView:setInvisible()
    self:removeTimer('change_visibility');
    self:addTimer('change_visibility', MAIN_TIMER, "tween", 0.3, self,
                  {alpha = 0}, 'in-quad')
  local offset = 30
  self:removeTimer('change_offset');
  self:addTimer('change_offset', MAIN_TIMER, "tween", 0.3, self.pos,
                {y = self.pos.y-offset}, 'in-quad')
end

return TurnSlotsView
