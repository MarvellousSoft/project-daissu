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

    self.sx, self.sy = 1, 1

    --Color for die border
    self.color_border = Color.new(self.color.r*1.2,self.color.g*1.2,self.color.b*1.2)

    --Loads up icon for every side
    self.side_images = {}
    for i,side in ipairs(die:getSides()) do
        self.side_images[i] = Action.actionImage(side)
    end

    self.previous_pos = Vector(x,y)
    self.picked = false --If player is dragging this object

    self.rolling = false --If die is rolling
    self.rolling_face = 1 --What face to show while rolling
    self.rolling_face_change_speed = .1 --Speed to change face while rolling
    self.change_side = false
end

--CLASS FUNCTIONS--

function DieView:draw()
    local die = self:getObj()

    local g = love.graphics
    --Draw die bg
    Color.set(self.color)
    g.rectangle("fill", self.pos.x  - self.w*(self.sx-1)/2, self.pos.y  - self.h*(self.sy-1)/2,
                        self.w * self.sx, self.h * self.sy, 5, 5)
    g.setLineWidth(4)
    Color.set(self.color_border)
    g.rectangle("line", self.pos.x  - self.w*(self.sx-1)/2, self.pos.y  - self.h*(self.sy-1)/2,
                        self.w * self.sx, self.h * self.sy, 5, 5)

    --Draw die text
    Color.set(Color.white())
    local icon = self.side_images[self.rolling and self.rolling_face or die:getCurrentNum()]
    g.draw(icon, self.pos.x - self.w*(self.sx-1)/2, self.pos.y - self.h*(self.sy-1)/2, nil,
                 self.w/icon:getWidth()*self.sx, self.h/icon:getHeight()*self.sy)
end

function DieView:rollAnimation()
    if self.rolling then return end
    self.rolling = true
    local imgs = {}
    for i, img in ipairs(self.side_images) do imgs[img] = i end

    -- Only different images
    local diff_imgs = {}
    local face_i = 1
    for img, i in pairs(imgs) do
        table.insert(diff_imgs, i)
        if self.side_images[i] == self.side_images[self.obj:getCurrentNum()] then
            face_i = #diff_imgs
        end
    end

    self.rolling_face = diff_imgs[face_i]
    local function change_side()
        local i = love.math.random(#diff_imgs - 1)
        if i >= face_i then i = i + 1 end
        face_i = i
        self.rolling_face = diff_imgs[i]
    end

    local duration = love.math.random() * .2 + .6 --Range between [.6,.8]
    self:addTimer(nil, MAIN_TIMER, "tween", duration, self, {sx = 1.9, sy = 1.9}, "out-quad",
        function()
            --Make it go back
            self:addTimer(nil, MAIN_TIMER, "tween", duration-.1, self, {sx = 1, sy = 1}, "in-bounce",
                function()
                    self.rolling = false
                end
            )
            MAIN_TIMER:script(function(wait)
                wait(.36 * (duration - .1))
                local cur = .36 * (duration - .1)
                while cur <= (duration - .1) do
                    change_side()
                    local d = love.math.random() * .04 + .1
                    wait(d)
                    cur = cur + d
                end
            end)
        end
    )

end

--Mouse functions

function DieView:mousepressed(x, y, button)
    local collided = self:collidesPoint(x,y)
    if button == 1 and collided then
        self.picked = true
        self:setDrawTable("L2upper") --Make it draw above other dice
        self.previous_pos.x = self.pos.x
        self.previous_pos.y = self.pos.y
    elseif button == 2 and collided then
        local player = self:getObj():getPlayer()
        local match = Util.findId("match")
        --This die was in a slot
        if self:getObj().slot then
            local slot
            --From turn slot go to dice area slot
            if self:getObj().slot.type == "turn" then
                slot = match:getAvailableDiceAreaSlot(player)
            --From dice area slot go to turn slot
            elseif self:getObj().slot.type == "dice_area" then
                slot = match:getAvailableTurnSlot(player)
            end
            if slot then
                self:getObj().slot:removeDie()
                slot:putDie(self:getObj())
            end
        --This die was was not in a slot -> go to first available dice area slot
        else
            local slot = match:getAvailableDiceAreaSlot(player)
            if slot then
                slot:putDie(self:getObj())
            end
        end
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
