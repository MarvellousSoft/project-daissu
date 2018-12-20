local Class  = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local Util   = require "common.util"

local ScrollWindow = Class {}

local bar_size = 18

function ScrollWindow:init(obj, x, y, w, h)
    self.obj = obj
    self.w = w or (obj.w + bar_size)
    self.h = h or (obj.h + bar_size)
    self.pos = Vector(x, y)

    -- how much the bar was horizontally scrolled
    self.scroll_x = 0
    -- how much the bar was vertically scrolled
    self.scroll_y = 0
    -- how much to scroll the bar when using mousewheel
    self.intensity = 20
    -- which scrollbar is grabbed
    self.grab = nil
    self.grab_d = 0 -- used to adjust mouse position to the grabbed bar
end

function ScrollWindow:hasVerticalBar()
    return self.h < self.obj.h
end

function ScrollWindow:verticalBarBounds()
    return
        self.pos.x + self.w - bar_size, -- x
        self.pos.y + self.scroll_y,     -- y
        bar_size,                           -- width
        (self.h / (self.obj.h + bar_size)) * self.h      -- height
end

function ScrollWindow:maxScrollY()
    return self.h - self.h * (self.h / (self.obj.h + bar_size))
end

function ScrollWindow:hasHorizontalBar()
    return self.w < self.obj.w
end

function ScrollWindow:horizontalBarBounds()
    return
        self.pos.x + self.scroll_x,     -- x
        self.pos.y + self.h - bar_size, -- y
        (self.w / (self.obj.w + bar_size)) * self.w,     -- width
        bar_size                            -- height
end

function ScrollWindow:maxScrollX()
    -- the size of the scrollbar depends on the ratio of
    -- the sizes of the window and the underlying object
    return self.w - self.w * (self.w / (self.obj.w + bar_size))
end

function ScrollWindow:getActualTranslate()
    return
        (self.scroll_x / self:maxScrollX()) * (self.obj.w + bar_size - self.w),
        (self.scroll_y / self:maxScrollY()) * (self.obj.h + bar_size - self.h)
end

function ScrollWindow:draw()
    local prev = {love.graphics.getScissor()}
    love.graphics.setScissor(self.pos.x, self.pos.y, self.w, self.h)
    local tx, ty = self:getActualTranslate()
    love.graphics.translate(-tx, -ty)
    self.obj:draw()
    love.graphics.translate(tx, ty)
    love.graphics.setScissor(unpack(prev))


    -- Horizontal Bar
    if self:hasHorizontalBar() then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', self:horizontalBarBounds())
    end

    -- Vertical bar
    if self:hasVerticalBar() then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', self:verticalBarBounds())
    end
end

function ScrollWindow:mousepressed(x, y, but, ...)
    if not Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w, self.h) then return end
    if but == 1 then
        if self:hasHorizontalBar() and y >= self.pos.y + self.h - bar_size then
            self.grab = 1
            local xb, _, w = self:horizontalBarBounds()
            if x < xb then
                self.grab_d = 0
                self.scroll_x = x - self.pos.x
            elseif x > xb + w then
                self.grab_d = w
                self.scroll_x = x - self.pos.x - w
            else
                self.grab_d = x - xb
            end
        elseif self:hasVerticalBar() and x >= self.pos.x + self.w - bar_size then
            self.grab = 2
            local _, yb, _, h = self:verticalBarBounds()
            if y < yb then
                self.grab_d = 0
                self.scroll_y = y - self.pos.y
            elseif y > yb + h then
                self.grab_d = h
                self.scroll_y = y - self.pos.y - h
            else
                self.grab_d = y - yb
            end
        else
            self.grab = nil
        end
    end

    if not self.obj.mousepressed or
       not Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w - bar_size, self.h - bar_size)
    then
        return
    end
    local tx, ty = self:getActualTranslate()
    self.obj:mousepressed(x + tx, y + ty, but, ...)
end

function ScrollWindow:mousereleased(x, y, but, ...)
    if but == 1 then self.grab = nil end
    if not self.obj.mousereleased or not Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w - bar_size, self.h - bar_size) then return end
    local tx, ty = self:getActualTranslate()
    self.obj:mousereleased(x + tx, y + ty, but, ...)
end

local function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

function ScrollWindow:wheelmoved(x, y)
    x, y = y*self.intensity, y*self.intensity
    local mx, my = love.mouse.getPosition()
    if self:hasVerticalBar() and
       Util.pointInRect(mx, my, self.pos.x, self.pos.y, self.w, self.h)
    then
        self.scroll_y = clamp(self.scroll_y - y, 0, self:maxScrollY())
    elseif self:hasHorizontalBar() and
       Util.pointInRect(mx, my, self.pos.x, self.pos.y, self.w, self.h)
    then
        self.scroll_x = clamp(self.scroll_x - x, 0, self:maxScrollX())
    end
end

function ScrollWindow:mousemoved(x, y, dx, dy, ...)
    if self.grab == 1 then -- horizontal
        self.scroll_x = clamp(x - self.pos.x - self.grab_d, 0, self:maxScrollX())
    elseif self.grab == 2 then -- vertical
        self.scroll_y = clamp(y - self.pos.y - self.grab_d, 0, self:maxScrollY())
    end

    if not self.obj.mousemoved or
       not Util.pointInRect(x, y, self.pos.x, self.pos.y, self.w - bar_size, self.h - bar_size)
    then
        return
    end
    local tx, ty = self:getActualTranslate()
    self.obj:mousemoved(x + tx, y + ty, dx, dy, ...)
end

return ScrollWindow
