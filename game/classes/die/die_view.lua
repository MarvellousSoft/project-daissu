local Class     = require "extra_libs.hump.class"
local Vector    = require "extra_libs.hump.vector"
local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Color     = require "classes.color.color"
local Action    = require "classes.action"
local DieHelper = require "classes.die.helper"
local Font      = require "font"
local Util      = require "util"

local funcs = {}

--CLASS DEFINITION--

local DieView = Class{
    __includes = {DRAWABLE, VIEW}
}

function DieView:init(die, x, y, color)
    DRAWABLE.init(self, x, y, color, nil,nil,nil)
    VIEW.init(self,die)

    self.w, self.h = DieHelper.getDieDimensions()

    --Color for die border
    self.color_border = Color.new(self.color.r*1.2,self.color.g*1.2,self.color.b*1.2)

    --Loads up icon for every side
    self.side_images = {}
    for i,side in ipairs(die:getSides()) do
        self.side_images[i] = Action.actionImage(side)
    end

    self.previous_pos = Vector(x,y)
    self.picked = false --If player is dragging this object
end

--CLASS FUNCTIONS--

function DieView:draw()
    local die = self:getObj()

    local g = love.graphics
    --Draw die bg
    Color.set(self.color)
    g.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h, 5, 5)
    g.setLineWidth(4)
    Color.set(self.color_border)
    g.rectangle("line", self.pos.x, self.pos.y, self.w, self.h, 5, 5)

    --Draw die text
    Color.set(Color.white())
    local icon = self.side_images[die:getCurrentNum()]
    g.draw(icon, self.pos.x, self.pos.y, nil, self.w/icon:getWidth(),self.h/icon:getHeight())
end

--Mouse functions

function DieView:mousepressed(x, y, button)
    if self:collidesPoint(x,y) then
        self.picked = true
        self:setDrawTable("L2upper") --Make it draw above other dice
        self.previous_pos.x = self.pos.x
        self.previous_pos.y = self.pos.y
    end
end

function DieView:mousereleased(x, y, button)
    if self.picked then
        self:setDrawTable("L2") --Return it to normal draw layer
        local slots = Util.findSubtype("die_slot_view")
        local should_return = true
        if slots then
            for slot_view in pairs(slots) do
                if self:collidesRect(slot_view.pos.x,slot_view.pos.y,slot_view.w,slot_view.h) then
                    --Leave previous slot, if any
                    local my_slot = self.obj.slot
                    if my_slot then my_slot:removeDie() end

                    local target_slot = slot_view:getObj()

                    --Check for previous die in this new slot and remove it
                    if target_slot:getDie() then
                        local prev_die = target_slot:getDie()
                        target_slot:removeDie()
                        --If self die was already in slot, put this die in its slot
                        local prev_view = prev_die.view
                        if my_slot then
                            my_slot:putDie(prev_die)
                        else
                            --Else just put the die on self die previous position
                            prev_view.pos.x = self.previous_pos.x
                            prev_view.pos.y = self.previous_pos.y
                        end
                    end

                    --Occupy current slot
                    target_slot:putDie(self:getObj())

                    should_return = false
                end
            end
        end
        if should_return then
            --Return to previous position
            self.pos.x = self.previous_pos.x
            self.pos.y = self.previous_pos.y
        end
        self.picked = false
    end
end

function DieView:mousemoved(x, y, dx, dy)
    if self.picked then
        self.pos.x = self.pos.x + dx
        self.pos.y = self.pos.y + dy
    end
end

--Collision functions

--Checks if given point(x,y) collides with this view
function DieView:collidesPoint(x,y)
    local s = self
    return x >= s.pos.x and x <= s.pos.x + s.w and
           y >= s.pos.y and y <= s.pos.y + s.h
end

--Checks if given rect(x,y,w,h) collides with this view
function DieView:collidesRect(x,y,w,h)
    local s = self
    return not ((s.pos.x + s.w < x) or
                (x + w < s.pos.x) or
                (s.pos.y + self.h < y) or
                (y + h < s.pos.y))
end

--UTILITY FUNCTIONS--

return DieView
