local Class     = require "common.extra_libs.hump.class"
local Vector    = require "common.extra_libs.hump.vector"
local DRAWABLE  = require "classes.primitives.drawable"
local VIEW      = require "classes.primitives.view"
local Color     = require "classes.color.color"
local Actions   = require "classes.actions"
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
    self.color_darker = Color.new(self.color.r*.8,self.color.g*.8,self.color.b*.8)
    self.color_border = Color.new(self.color.r*.2,self.color.g*.2,self.color.b*.2)

    --Loads up icon for every side
    self.side_images = {}
    for i,side in ipairs(die:getSides()) do
        self.side_images[i] = Actions.actionImage(side)
    end

    self.previous_pos = Vector(x,y)
    self.picked = false --If player is dragging this object

    self.rolling = false --If die is rolling
    self.rolling_face = 1 --What face to show while rolling
    self.rolling_face_change_speed = .1 --Speed to change face while rolling
    self.change_side = false

    self.moving = false --If this die is currently moving
    self.move_speed = 1000 --How fast this die move when tweening position
end

function DieView:update(dt)

end

--CLASS FUNCTIONS--

function DieView:draw()
    local die = self:getObj()

    local g = love.graphics
    --Draw die bg
    local x, y = self.pos.x  - self.w*(self.sx-1)/2, self.pos.y  - self.h*(self.sy-1)/2
    local w, h = self.w * self.sx, self.h * self.sy
    g.setLineWidth(3)
    Color.set(self.color_darker)
    g.rectangle("fill", x, y + h/6, w, h, 5, 5)
    Color.set(self.color_border)
    g.rectangle("line", x, y + h/6, w, h, 5, 5)
    Color.set(self.color)
    g.rectangle("fill", x, y, w, h, 5, 5)
    Color.set(self.color_border)
    g.rectangle("line", x, y, w, h, 5, 5)

    --Draw die icon
    local icon = self.side_images[self.rolling and self.rolling_face or die:getCurrentNum()]
    icon:setFilter("linear")
    
    local x, y = self.pos.x - self.w*(self.sx-1)/2, self.pos.y - self.h*(self.sy-1)/2
    local margin = 0
    local sx = (self.w-2*margin)/icon:getWidth()*self.sx
    local sy = (self.h-2*margin)/icon:getHeight()*self.sy
    local off = 2
    Color.set(Color.black())
    g.draw(icon, x + margin + off, y + margin + off, nil, sx, sy)
    Color.set(Color.white())
    g.draw(icon, x + margin, y + margin, nil, sx, sy)
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
    local match = Util.findId("match")
    local die = self:getObj()
    if self.moving or
       match.state == "playing turn" or
       match:getLocalId() ~= die:getPlayer() then
           return
    end
    local collided = self:collidesPoint(x,y)
    if button == 1 and collided then
        self.picked = true
        self:setDrawTable("L2upper") --Make it draw above other dice
        self.previous_pos.x = self.pos.x
        self.previous_pos.y = self.pos.y
    elseif button == 2 and collided and not self.picked then
        local player = die:getPlayer()
        local match = Util.findId("match")
        --This die was in a slot
        if die.slot then
            local slot
            --From turn slot go to dice area slot
            if die.slot.type == "turn" then
                slot = match:getAvailableDiceAreaSlot()
            --From dice area slot go to turn slot
            elseif die.slot.type == "dice_area" then
                slot = match:getAvailableTurnSlot(player)
            end
            if slot then
                die.slot:removeDie()
                slot:putDie(die)
            end
        --This die was was not in a slot -> go to first available dice area slot
        else
            local slot = match:getAvailableDiceAreaSlot()
            if slot then
                slot:putDie(die)
            end
        end
    end

end

function DieView:mousereleased(x, y, button, player_area)
    local match = Util.findId("match")
    local die = self:getObj()
    if self.moving or
       match.state == "playing turn" or
       match:getLocalId() ~= die:getPlayer() then
           return
    end
    if self.picked and button == 1 then
        self:setDrawTable("L2") --Return it to normal draw layer
        local should_return = true
        for slot_view in player_area:allSlots() do
            if self:collidesRect(slot_view.pos.x,slot_view.pos.y,slot_view.w,slot_view.h) then
                --Leave previous slot, if any
                local my_slot = die.slot
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
                        --Else just put the die on self die previous position, using tween
                        --Create animation that moves die to this slot
                        prev_view.is_moving = true
                        local tpos = Vector(0,0)
                        tpos.x = self.previous_pos.x
                        tpos.y = self.previous_pos.y
                        local d = prev_view.pos:dist(tpos)/prev_view.move_speed
                        prev_view:removeTimer("moving")
                        prev_view:addTimer("moving", MAIN_TIMER, "tween", d, prev_view.pos,
                                            {x = tpos.x, y = tpos.y}, 'out-quad',
                                            function ()
                                                prev_view.is_moving = false
                                            end
                        )
                    end
                end

                --Occupy current slot
                target_slot:putDie(die)

                should_return = false
            end
        end
        if should_return then
            --Return to previous position, using tween
            self.is_moving = true
            local tpos = Vector(0,0)
            tpos.x = self.previous_pos.x
            tpos.y = self.previous_pos.y
            local d = self.pos:dist(tpos)/self.move_speed
            self:removeTimer("moving")
            self:addTimer("moving", MAIN_TIMER, "tween", d, self.pos,
                             {x = tpos.x, y = tpos.y}, 'out-quad',
                             function ()
                                 self.is_moving = false
                             end
            )
        end
        self.picked = false
    end
end

function DieView:mousemoved(x, y, dx, dy)
    local match = Util.findId("match")
    local die = self:getObj()
    if self.moving or
       match.state == "playing turn" or
       match:getLocalId() ~= die:getPlayer() then
           return
    end
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
