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

--LOCAL FUNCTIONS DLECARATIONS

local getColor

--CLASS DEFINITION--

local DieView = Class{
    __includes = {DRAWABLE, VIEW}
}

function DieView:init(die, x, y, color)
    DRAWABLE.init(self, x, y, color, nil,nil,nil)
    VIEW.init(self,die)

    self.w, self.h = DieHelper.getDimensions()
    self.sx, self.sy = 1, 1

    --Color for die border
    self:setColor(color)

    --Loads up icon for every side
    self.side_images = {}
    for i,side in ipairs(die:getSides()) do
        self.side_images[i] = Actions.actionImage(side)
    end

    self.previous_pos = Vector(x,y)
    self.picked = false --If player is dragging this object
    self.is_moving = false --If this die is moving somewhere

    self.rolling = false --If die is rolling
    self.rolling_face = 1 --What face to show while rolling
    self.rolling_face_change_speed = .1 --Speed to change face while rolling
    self.change_side = false

    self.move_speed = 80 --How fast this die move when tweening position

    self.alpha = 255
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
    Color.setWithAlpha(self.color_darker,self.alpha)
    g.rectangle("fill", x, y + h/6, w, h, 5, 5)
    Color.setWithAlpha(self.color_border,self.alpha)
    g.rectangle("line", x, y + h/6, w, h, 5, 5)
    Color.setWithAlpha(self.color,self.alpha)
    g.rectangle("fill", x, y, w, h, 5, 5)
    Color.setWithAlpha(self.color_border,self.alpha)
    g.rectangle("line", x, y, w, h, 5, 5)

    --Draw die icon
    local icon = self.side_images[self.rolling and self.rolling_face or die:getCurrentNum()]
    icon:setFilter("linear")

    local x, y = self.pos.x - self.w*(self.sx-1)/2, self.pos.y - self.h*(self.sy-1)/2
    local margin = 0
    local sx = (self.w-2*margin)/icon:getWidth()*self.sx
    local sy = (self.h-2*margin)/icon:getHeight()*self.sy
    local off = 2
    Color.setWithAlpha(Color.black(),self.alpha)
    g.draw(icon, x + margin + off, y + margin + off, nil, sx, sy)
    Color.setWithAlpha(Color.white(),self.alpha)
    g.draw(icon, x + margin, y + margin, nil, sx, sy)
end

function DieView:setColor(color)
  self.color = Color.new(color.r,color.g,color.b)
  self.color_darker = Color.new(color.r*.8,color.g*.8,color.b*.8)
  self.color_border = Color.new(color.r*.2,color.g*.2,color.b*.2)
end

--Animation for the die to fade in
function DieView:enter()
    self.alpha = 0
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", 0.3, self,
                  {alpha = 255}, 'out-quad')
end

--Animation for the die to fade out and destroy itself
function DieView:leave()
    local dur = .3
    self:removeTimer('change_position', MAIN_TIMER)
    self:addTimer('change_position', MAIN_TIMER, "tween", dur, self.pos,
                  {y = self.pos.y -10}, 'in-quad')
    self:removeTimer('change_visibility', MAIN_TIMER)
    self:addTimer('change_visibility', MAIN_TIMER, "tween", dur, self,
                  {alpha = 0}, 'in-quad',
                  function()
                    self:kill()
                  end)
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

function DieView:handlePick(player_area)
    self:removeTimer('growing', MAIN_TIMER)
    self.sx, self.sy = 1, 1
    self:addTimer('growing', MAIN_TIMER, "tween", 0.5, self, {sx = 1.3, sy = 1.3}, 'out-elastic')
end

function DieView:handleUnpick(player_area)
    self:removeTimer('growing', MAIN_TIMER)
    self.sx, self.sy = 1.3, 1.3
    self:addTimer('growing', MAIN_TIMER, "tween", 0.5, self, {sx = 1, sy = 1}, 'out-elastic')
    local die = self:getObj()
    local best_col, best_slot = 0, nil
    for slot in player_area:allSlots() do
        local col = self:collidesRect(slot.view.pos.x, slot.view.pos.y, slot.view.w, slot.view.h)
        if col > best_col then
            best_col, best_slot = col, slot
        end
    end
    if best_col > 0 then
        --Leave previous slot, if any
        local my_slot = die.slot
        assert(my_slot ~= nil)
        my_slot:removeDie()

        local target_slot = best_slot

        --Check for previous die in this new slot and remove it
        if target_slot:getDie() then
            local prev_die = target_slot:getDie()
            target_slot:removeDie()
            my_slot:putDie(prev_die)
        end

        --Occupy current slot
        target_slot:putDie(die)
        target_slot.view.has_die_over = false
        return
    else
        die.slot.view:centerDie()
        die.slot.view.view.has_die_over = false
    end
end

function DieView:slideTo(pos, snap)
    if snap then
        self.pos = pos
        return
    end
    local d = math.sqrt(self.pos:dist(pos)) / self.move_speed
    self.is_moving = true
    self:removeTimer("moving", MAIN_TIMER)
    self:addTimer("moving", MAIN_TIMER, "tween", d, self.pos,
                        {x = pos.x, y = pos.y}, 'out-quad',
                        function ()
                            self.is_moving = false
                        end
    )
end

--Mouse functions

function DieView:handleRightClick(player_area)
    local die = self:getObj()
    local slot
    --From turn slot go to dice area slot
    if die.slot.type == "turn" then
        slot = player_area:getAvailableMatSlot()
    --From dice area slot go to turn slot
    elseif die.slot.type == "mat" then
        slot = player_area:getAvailableTurnSlot()
    end

    if slot then
        die.slot:removeDie()
        slot:putDie(die)
    end
end

--Collision functions

--Checks if given point(x,y) collides with this view
function DieView:collidesPoint(x,y)
    local s = self
    return x >= s.pos.x and x <= s.pos.x + s.w and
           y >= s.pos.y and y <= s.pos.y + s.h
end

-- Returns the area of the collision of rect(x,y,w,h) with this view
function DieView:collidesRect(x, y, w, h)
    local x_l, x_r = math.max(x, self.pos.x), math.min(x + w, self.pos.x + self.w)
    if x_l >= x_r then return 0 end
    local y_l, y_r = math.max(y, self.pos.y), math.min(y + h, self.pos.y + self.h)
    if y_l >= y_r then return 0 end
    return (x_r - x_l) * (y_r - y_l)
end

--Returns the die actual height (includes die underside)
function DieView:getHeight()
    return self.h + DieHelper.getUnderside()
end

--Returns the die actual width
function DieView:getWidth()
    return self.w
end

--UTILITY FUNCTIONS--

return DieView
