local ELEMENT = require "classes.primitives.element"
local Class   = require "common.extra_libs.hump.class"
local Vector  = require "common.extra_libs.hump.vector"
local Color   = require "classes.color.color"
local Actions = require "classes.actions"
local Font    = require "font"

local funcs = {}

--Die side dimensions to draw each action
local ds_w = 80
local ds_h = 80

--LOCAL FUNCTIONS DECLARATIONS
local drawDieSide
local drawDieInfo
local collidesPointRect

--CLASS DEFINITION--

local DieFaces = Class{
    __includes={ELEMENT}
}

function DieFaces:init(die)
    ELEMENT.init(self)

    self.die = die
    self.die_sides = die:getObj():getNumSides()
    self.focused_side = die:getObj():getCurrentNum()

    self.info_w = 400
    self.info_h = 300
    self.info_gap = 70 --Gap between sides and info

    self.alpha = 0
    self.alpha_speed = 500
    self.gap = 30
    self.w = (self.die_sides*ds_w + (self.die_sides-1)*self.gap) --Width for sides
    self.h = ds_h --Height for sides
    local x = (WIN_W-self.w)/2
    local y = (WIN_H-self.h)/2 + (self.info_h+self.info_gap)/2
    self.pos = Vector(x,y)


    self:addTimer("enter", MAIN_TIMER, "tween", 255/self.alpha_speed, self, {alpha = 255}, "out-quad")
    self.closing = false --If this object is fading out
end

--CLASS FUNCTIONS--

function DieFaces:draw()

    --Draw selected die info
    local x = (WIN_W - self.info_w)/2
    local y = self.pos.y - self.info_gap - self.info_h
    local action = self.die:getObj():getSide(self.focused_side)
    drawDieInfo(x, y, self.info_w, self.info_h, action, self.alpha)

    --Draw all sides for die
    x, y = self.pos.x, self.pos.y
    for i = 1, self.die_sides do
        drawDieSide(x, y, self.die, i, i == self.focused_side, self.alpha)
        x = x + ds_w + self.gap
    end

end

function DieFaces:kill()
    if self.closing then return end
    self.closing = true
    self:removeTimer("enter", MAIN_TIMER)
    self:addTimer("closing", MAIN_TIMER, "tween", self.alpha/self.alpha_speed, self, {alpha = 0}, 'out-quad',
                  function()
                      self:destroy()
                  end)
end

function DieFaces:mousepressed(x, y, button)
    local _x, _y = self.pos.x, self.pos.y
    local margin = 20
    local w, h = self.w + 2*margin, self.h + 2*margin

    --Leave die description state if player clicks outside die sides
    if not collidesPointRect(x, y, _x-margin, _y-margin, w, h) then
        return false
    end

    for i = 1, self.die_sides do
        if collidesPointRect(x, y, _x, _y, ds_w,ds_h) then
            self.focused_side = i
            break
        end
        _x = _x + ds_w + self.gap
    end
    return true
end

--LOCAL FUNCTIONS--

function drawDieSide(x, y, die, side, focused, alpha)
    local g = love.graphics
    local color = die.color

    --Draw die bg
    g.setLineWidth(3)
    if focused then
        g.setColor(color.r*1.2,color.g*1.2,color.b*1.2, alpha)
    else
        Color.setWithAlpha(color, alpha)
    end
    g.rectangle("fill", x, y, ds_w, ds_h, 5, 5)
    g.setColor(color.r*.5,color.g*.5,color.b*.5, alpha)
    g.rectangle("line", x, y, ds_w, ds_h, 5, 5)

    --Draw die icon
    local icon = die.side_images[side]
    icon:setFilter("linear")

    local sx = ds_w/icon:getWidth()
    local sy = ds_h/icon:getHeight()
    local off = 2
    Color.setWithAlpha(Color.black(), alpha)
    g.draw(icon, x + off, y + off, nil, sx, sy)
    Color.setWithAlpha(Color.white(), alpha)
    g.draw(icon, x, y, nil, sx, sy)

    --Draw focused border
    if focused then
        local scale = 1.3 + math.sin(5*love.timer.getTime())*.1
        local offx = ds_w*(scale - 1)/2
        local offy = ds_h*(scale - 1)/2
        g.setLineWidth(5)
        g.setColor(250, 250, 200, alpha)
        g.rectangle("line", x - offx, y - offy, ds_w*scale, ds_h*scale, 10, 10)
    end
end

function drawDieInfo(x, y, w, h, action, alpha)
    local action_module = Actions.getAction(action)
    local g = love.graphics

    --Draw bg
    local image = IMG.die_info
    local sx = w/image:getWidth()
    local sy = h/image:getHeight()
    Color.setWithAlpha(Color.white(), alpha)
    g.draw(image, x, y, nil, sx, sy)

    local border = 25

    --Draw action name
    local font = Font.get("regular", 35)
    local text = action_module.name
    local tx, ty = x + w/2 - font:getWidth(text)/2, y + border
    Font.set(font)
    g.print(text, tx, ty)

    --Draw action description centralized in the remaining space
    font = Font.get("regular", 20)
    text = action_module.desc
    local margin = 30
    local limit = w - 2*margin
    _, lines = font:getWrap(text, limit)
    tx = x + margin
    ty = y + h/2 - #lines*font:getHeight()/2 + border
    Font.set(font)
    g.printf(text, tx, ty, w - 2*margin, "center")
end

--Checks if given point(x,y) collides with given rect(rx,ry,rw,rh)
function collidesPointRect(x,y,rx,ry,rw,rh)
    return x >= rx and x <= rx + rw and
           y >= ry and y <= ry + rh
end

return DieFaces
