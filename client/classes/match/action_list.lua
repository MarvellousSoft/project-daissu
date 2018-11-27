local DRAWABLE  = require "classes.primitives.view"
local Class     = require "common.extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"
local Util      = require "util"

local funcs = {}

--CLASS DEFINITION--

local ActionList = Class{
    __includes={DRAWABLE},
}

function ActionList:init(pos,actions,players)
    self.pos = pos

    local match = Util.findId("match")
    self.colors = match:getColors()
    self.players = players

    self.gap = 10 --Gap between actions and arrows

    self.dice = {}
    local die_w, die_h = DieHelper:getDieDimensions()
    local image = IMG.next_action_grey
    self.dx = die_w + 2*self.gap + image:getWidth() --How far apart each action is
    for i, action in ipairs(actions) do
        local player = self.players[i]
        self.dice[idx] = DieView(Die({action}, player), self.pos.x + (i-1) * dx, self.pos.y, self.colors[player])
    end

    --Y position for the arrows
    self.arrow_y = self.pos.y + die_h/2 - image:getWidth()/2

    self.current_action = 1
end

function ActionList:draw()
    local x = self.pos.x - self.gap - IMG.next_action_grey:getWidth()
    for i,die in ipairs(self.dice) do
        --Draw correspondent arrow for this action
        local image
        if i < self.current_action then
            image = IMG["next_action_grey"]
        else
            image = IMG["next_action_"..self.colors[i]]
        end
        love.graphics.draw(image, x, self.arrow.y)
        x = x + dx
        --Draw die representing this action
        die:draw()
    end
end

function ActionList:bump()
    self.current_action = self.current_action + 1
end
