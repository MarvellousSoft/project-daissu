local DRAWABLE  = require "classes.primitives.view"
local Class     = require "common.extra_libs.hump.class"
local Color     = require "classes.color.color"
local DieHelper = require "classes.die.helper"
local Util      = require "util"
local Die       = require "classes.die.die"
local DieView   = require "classes.die.die_view"
local Font      = require "font"
local Gamestate = require "common.extra_libs.hump.gamestate"

local funcs = {}

--CLASS DEFINITION--

local ActionList = Class{
    __includes={DRAWABLE},
}

function ActionList:init(pos, actions, players, number_players)
    self.pos = pos

    local match = Util.findId("match")
    self.colors = match:getColors()
    self.players = players
    self.number_players = number_players

    self.gap = 10 --Gap between actions and arrows

    self.next_action_image = IMG.next_action

    self.w = 0
    self.h = 60

    self.dice = {}
    local die_w, die_h = DieHelper:getDimensions()
    die_h = die_h + DieHelper:getUnderside()
    local dx = die_w + 2*self.gap + self.next_action_image:getWidth() --How far apart each action is
    for i, action in ipairs(actions) do
        local player = self.players[i]
        self.dice[i] = DieView(
                        Die({action}, player),
                                self.pos.x + self.next_action_image:getWidth() + self.gap + (i-1) * dx,
                                self.pos.y, self.colors[player])
    end

    --Y position for the arrows
    self.focused_arrow_scale = 1
    self.focused_arrow_y = self.pos.y + die_h/2 - self.next_action_image:getHeight()/2
    self.unfocused_arrow_scale = .8
    self.unfocused_arrow_y = self.pos.y + die_h/2 - self.next_action_image:getHeight()*self.unfocused_arrow_scale/2
    self.unfocused_offset = self.next_action_image:getWidth()*(self.focused_arrow_scale-self.unfocused_arrow_scale)

    self.slot_number_image = IMG.slot_number
    self.slot_number_font = Font.get("regular", 18)

    self.grey_color = Color.new(150,150,150) --For dice that already had their action done

    self.current_action = 1
end

function ActionList:draw()
    local g = love.graphics
    local dx = DieHelper.getDimensions() + 2 * self.gap + self.next_action_image:getWidth() --How far apart each action is
    local x = self.pos.x
    local arrow_alpha, arrow_y
    for i,die in ipairs(self.dice) do
        local image_color
        local offset = self.unfocused_offset
        arrow_y = self.unfocused_arrow_y
        scale = self.unfocused_arrow_scale
        if i < self.current_action then
            die:setColor(self.grey_color)
            image_color = self.grey_color
            arrow_alpha = 150
        else
            image_color = self.colors[self.players[i]]
            arrow_alpha = 160
            if i == self.current_action then
                arrow_y = self.focused_arrow_y
                scale = self.focused_arrow_scale
                arrow_alpha = 255
                offset = math.sin(10*love.timer.getTime())*3
            end
        end

        --Draw die representing this action
        die:draw()

        --Draw correspondent arrow for this action
        Color.setWithAlpha(image_color, arrow_alpha)
        g.draw(self.next_action_image, x + offset, arrow_y, nil, scale)

        --Draw number below die
        local sn_x = die.pos.x + die:getWidth()/2 - self.slot_number_image:getWidth()/2
        local sn_y = die.pos.y + die:getHeight() + 5
        g.draw(self.slot_number_image, sn_x, sn_y)
        local font = self.slot_number_font
        Color.setWithAlpha(Color.black(), self.alpha)
        Font.set(font)
        local number = math.ceil(i/self.number_players)
        local tx = sn_x + self.slot_number_image:getWidth()/2 - font:getWidth(number)/2
        local ty = sn_y + self.slot_number_image:getHeight()/2 - font:getHeight(number)/2
        g.print(number, tx, ty)

        --Update arrow position
        x = x + dx
    end
    self.w = x - self.pos.x
end

function ActionList:bump()
    self.current_action = self.current_action + 1
end

function ActionList:mousepressed(x, y, but)
    for i, die in ipairs(self.dice) do
        if die:collidesPoint(x, y) and
           die:getObj():getCurrent() ~= 'none' and
           (but == 3 or love.keyboard.isDown('lshift', 'rshift'))
        then
            Gamestate.push(GS.DIE_DESC, die)
        end
    end
end

return ActionList
