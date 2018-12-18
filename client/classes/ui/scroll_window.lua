local Class  = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local Util   = require "common.util"

local ScrollWindow = Class {}

local bar_size = 18

function ScrollWindow:init(obj, w, h)
    self.obj = obj
    self.w = w or (obj.w + bar_size)
    self.h = h or (obj.h + bar_size)

    self.offset = Vector(0,0)

    -- how much the bar was horizontally scrolled
    self.scroll_x = 0
    -- how much the bar was vertically scrolled
    self.scroll_y = 0
    -- which scrollbar is grabbed
    self.grab = nil
    self.grab_d = 0 -- used to adjust mouse position to the grabbed bar
end

function ScrollWindow:hasVerticalBar()
    return self.h < self.obj.h
end

function ScrollWindow:verticalBarBounds()
    local ox, oy = self.offset.x, self.offset.y
    return
        self.obj.pos.x + ox + self.w - bar_size, -- x
        self.obj.pos.y + oy + self.scroll_y,     -- y
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
    local ox, oy = self.offset.x, self.offset.y
    return
        self.obj.pos.x + ox + self.scroll_x,     -- x
        self.obj.pos.y + oy + self.h - bar_size, -- y
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

function ScrollWindow:setOffset(x,y)
    self.offset.x = x
    self.offset.y = y
end

function ScrollWindow:draw()
    local prev = {love.graphics.getScissor()}
    local ox, oy = self.offset.x, self.offset.y
    love.graphics.setScissor(self.obj.pos.x + ox, self.obj.pos.y + oy, self.w, self.h)
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
    local ox, oy = self.offset.x, self.offset.y
    if not Util.pointInRect(x, y, self.obj.pos.x + ox, self.obj.pos.y + oy, self.w, self.h) then return end
    if but == 1 then
        if self:hasHorizontalBar() and y >= self.obj.pos.y + oy + self.h - bar_size then
            self.grab = 1
            local xb, _, w = self:horizontalBarBounds()
            if x < xb then
                self.grab_d = 0
                self.scroll_x = x - self.obj.pos.x + ox
            elseif x > xb + w then
                self.grab_d = w
                self.scroll_x = x - self.obj.pos.x + ox - w
            else
                self.grab_d = x - xb
            end
        elseif self:hasVerticalBar() and x >= self.obj.pos.x + ox + self.w - bar_size then
            self.grab = 2
            local _, yb, _, h = self:verticalBarBounds()
            if y < yb then
                self.grab_d = 0
                self.scroll_y = y - self.obj.pos.y + oy
            elseif y > yb + h then
                self.grab_d = h
                self.scroll_y = y - self.obj.pos.y + oy - h
            else
                self.grab_d = y - yb
            end
        else
            self.grab = nil
        end
    end

    if not self.obj.mousepressed or
       not Util.pointInRect(x, y, self.obj.pos.x + ox, self.obj.pos.y + oy, self.w - bar_size, self.h - bar_size)
    then
        return
    end
    local tx, ty = self:getActualTranslate()
    self.obj:mousepressed(x + tx, y + ty, but, ...)
end

function ScrollWindow:mousereleased(x, y, but, ...)
    local ox, oy = self.offset.x, self.offset.y
    if but == 1 then self.grab = nil end
    if not self.obj.mousereleased or not Util.pointInRect(x, y, self.obj.pos.x + ox, self.obj.pos.y + oy, self.w - bar_size, self.h - bar_size) then return end
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

function ScrollWindow:mousemoved(x, y, dx, dy, ...)
    local ox, oy = self.offset.x, self.offset.y
    if self.grab == 1 then -- horizontal
        self.scroll_x = clamp(x - self.obj.pos.x + ox - self.grab_d, 0, self:maxScrollX())
    elseif self.grab == 2 then -- vertical
        self.scroll_y = clamp(y - self.obj.pos.y + oy - self.grab_d, 0, self:maxScrollY())
    end

    if not self.obj.mousemoved or
       not Util.pointInRect(x, y, self.obj.pos.x + ox, self.obj.pos.y + oy, self.w - bar_size, self.h - bar_size)
    then
        return
    end
    local tx, ty = self:getActualTranslate()
    self.obj:mousemoved(x + tx, y + ty, dx, dy, ...)
end

return ScrollWindow
