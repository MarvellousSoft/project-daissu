local Class = require "common.extra_libs.hump.class"
local Util = require "util"
local ScrollWindow = Class {}

local bar_size = 10

function ScrollWindow:init(obj, w, h)
    self.obj = obj
    self.w = w or (obj.w + bar_size)
    self.h = h or (obj.h + bar_size)

    -- how much the bar was horizontally scrolled
    self.scroll_x = 0
    -- how much the bar was horizontally vertically
    self.scroll_y = 0
    -- which scrollbar is grabbed
    self.grab = nil
end

function ScrollWindow:hasVerticalBar()
    return self.h < self.obj.h
end

function ScrollWindow:verticalBarBounds()
    return
        self.obj.pos.x + self.w - bar_size, -- x
        self.obj.pos.y + self.scroll_y,     -- y
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
        self.obj.pos.x + self.scroll_x,     -- x
        self.obj.pos.y + self.h - bar_size, -- y
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
    love.graphics.setScissor(self.obj.pos.x, self.obj.pos.y, self.w, self.h)
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
    if but == 1 then
        if self:hasHorizontalBar() and Util.pointInRect(x, y, self:horizontalBarBounds()) then
            self.grab = 1
        elseif self:hasVerticalBar() and Util.pointInRect(x, y, self:verticalBarBounds()) then
            self.grab = 2
        else
            self.grab = nil
        end
    end

    if not self.obj.mousepressed or not Util.pointInRect(x, y, self.obj.pos.x, self.obj.pos.y, self.w - bar_size, self.h - bar_size) then return end
    local tx, ty = self:getActualTranslate()
    self.obj:mousepressed(x + tx, y + ty, but, ...)
end

function ScrollWindow:mousereleased(x, y, but, ...)
    if but == 1 then self.grab = nil end
    if not self.obj.mousereleased or not Util.pointInRect(x, y, self.obj.pos.x, self.obj.pos.y, self.w - bar_size, self.h - bar_size) then return end
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
    if self.grab == 1 then -- horizontal
        self.scroll_x = clamp(x - self.obj.pos.x, 0, self:maxScrollX())
    elseif self.grab == 2 then -- vertical
        self.scroll_y = clamp(y - self.obj.pos.y, 0, self:maxScrollY())
    end

    if not self.obj.mousemoved or not Util.pointInRect(x, y, self.obj.pos.x, self.obj.pos.y, self.w - bar_size, self.h - bar_size) then return end
    local tx, ty = self:getActualTranslate()
    self.obj:mousemoved(x + tx, y + ty, dx, dy, ...)
end

return ScrollWindow