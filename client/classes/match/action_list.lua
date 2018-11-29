local DRAWABLE  = require "classes.primitives.view"
local Class     = require "common.extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"
local Util      = require "util"
local Die       = require "classes.die.die"
local DieView   = require "classes.die.die_view"

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
    die_h = die_h + DieHelper:getDieUnderside()
    local image = IMG.next_action_grey
    local dx = die_w + 2*self.gap + image:getWidth() --How far apart each action is
    for i, action in ipairs(actions) do
        local player = self.players[i]
        self.dice[i] = DieView(Die({action}, player), self.pos.x + (i-1) * dx, self.pos.y, Color[self.colors[player]]())
    end

    --Y position for the arrows
    self.arrow_y = self.pos.y + die_h/2 - image:getWidth()/2

    self.grey_color = Color.new(150,150,150) --For dice that already had their action done

    self.current_action = 1
end

function ActionList:draw()
    local g = love.graphics
    local dx = DieHelper.getDieDimensions() + 2 * self.gap + IMG.next_action_grey:getWidth() --How far apart each action is
    local x = self.pos.x - self.gap - IMG.next_action_grey:getWidth()
    for i,die in ipairs(self.dice) do
        local image
        if i < self.current_action then
            die:setColor(self.grey_color)
            image = IMG["next_action_grey"]
        else
            image = IMG["next_action_"..self.colors[self.players[i]]]
        end
        --Draw correspondent arrow for this action
        g.setColor(255,255,255,255)
        g.draw(image, x, self.arrow_y)
        --Draw die representing this action
        die:draw()
        --Update arrou position
        x = x + dx
    end
end

function ActionList:bump()
    self.current_action = self.current_action + 1
end

return ActionList
