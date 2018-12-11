local Class       = require "common.extra_libs.hump.class"
local Color       = require "classes.color.color"
local Vector      = require "common.extra_libs.hump.vector"
local View        = require "classes.primitives.view"
local Element     = require "classes.primitives.element"
local DieSlotView = require "classes.die.die_slot_view"
local DieHelper   = require "classes.die.helper"
local Gamestate   = require "common.extra_libs.hump.gamestate"

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

    self.color = color

    --Bg image
    self.image = IMG.turn_slot
    self.iw = self.w/self.image:getWidth()
    self.ih = self.h/self.image:getHeight()

    --Starting player image
    self.starting_player_image = IMG.starting_player

    --Current slot image
    self.current_action_image = IMG.current_action

    --Transparency for this object
    self.alpha = 255

end

function TurnSlotsView:draw(draw_starting_player, position)
    --Draw turn slots background
    Color.setWithAlpha(Color.black(), self.alpha)
    local off = 8
    love.graphics.draw(self.image, self.pos.x+off, self.pos.y+off, nil,
                       self.iw, self.ih)
    Color.setWithAlpha(self.color, self.alpha)
    love.graphics.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.iw, self.ih)

    --Draw each slot
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:draw()
    end

    --Draw starting player icon, if needed
    if draw_starting_player then
        Color.setWithAlpha(self.color, self.alpha)
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
    --Set this turn slot alpha
    self.alpha = value
    --Set all die slots alpha
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:setAlpha(value)
    end
end

function TurnSlotsView:setVisible()
    local d = .5
    local offset = 20
    --Set turn slot visible
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 255}, 'out-quad')
    self.pos.y = self.pos.y - offset
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.pos.y+offset}, 'out-quad')
    --Set all die slots visible
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:setVisible(d, offset)
    end
end

function TurnSlotsView:setInvisible()
    local d = .3
    local offset = 30
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", d, self,
                  {alpha = 0}, 'in-quad')
    self:removeTimer('change_offset', MAIN_TIMER)
    self:addTimer('change_offset', MAIN_TIMER, "tween", d, self.pos,
                  {y = self.pos.y-offset}, 'in-quad')
    --Set all die slots invisible
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:setInvisible(d, offset)
    end
end

function TurnSlotsView:mousepressed(x, y, but)
    for i, die in ipairs(self:getDice()) do
        local die_view = die.view
        if die_view:collidesPoint(x, y) and
           die_view:getObj():getCurrent() ~= 'none' and
           (but == 3 or love.keyboard.isDown('lshift', 'rshift'))
        then
            Gamestate.push(GS.DIE_DESC, die_view)
        end
    end
end

return TurnSlotsView
