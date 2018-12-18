local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "common.extra_libs.hump.class"
local Vector      = require "common.extra_libs.hump.vector"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Color       = require "classes.color.color"
local Font        = require "font"
local UI          = require("assets").images.UI

local funcs = {}

--CLASS DEFINITION--

local Mat = Class{
    __includes={DRAWABLE}
}

function Mat:init(player_area, dice_n, pos, w, h, player_num)
    DRAWABLE.init(self, pos.x, pos.y, Color.purple())
    self.w = w
    self.h = h
    self.slots = {}
    self.player_area = player_area

    local margin_x = 20
    local margin_y = 3

    --Mat header info--
    local header_h = 90
    --Bag
    self.bag_w, self.bag_h = 80, 80
    self.bag_image = UI.bag
    self.bag_img_sx = self.bag_w/self.bag_image:getWidth()
    self.bag_img_sy = self.bag_h/self.bag_image:getHeight()
    self.bag_pos = Vector(pos.x + margin_x, pos.y + margin_y)
    --Rerolls
    self.rerolls_w, self.rerolls_h = 70, 70
    self.rerolls_image = UI.rerolls
    self.rerolls_img_sx = self.rerolls_w/self.rerolls_image:getWidth()
    self.rerolls_img_sy = self.rerolls_h/self.rerolls_image:getHeight()
    self.rerolls_pos = Vector(self.pos.x + self.w/2 - self.rerolls_w/2,
                              self.pos.y + header_h/2 - self.rerolls_h/2)
    self.rerolls_font = Font.get('regular', 20)
    local tw = self.rerolls_font:getWidth("0")
    local th = self.rerolls_font:getHeight("0")
    self.rerolls_text_pos = Vector(self.rerolls_pos.x + self.rerolls_w/2 - tw/2,
                                   self.rerolls_pos.y + self.rerolls_h/2 - th/2)
    --Gravepool
    self.grave_w, self.grave_h = 80, 80
    self.grave_image = UI.gravepool
    self.grave_img_sx = self.grave_w/self.grave_image:getWidth()
    self.grave_img_sy = self.grave_h/self.grave_image:getHeight()
    self.grave_pos = Vector(pos.x + w - margin_x - self.grave_image:getWidth()*self.grave_img_sx, pos.y + margin_y)

    --Initiate slots
    local dw, dh = DieSlotView.getSize()
    local margin = 10
    local h_gap, v_gap = 5, 10
    local max_slots_per_row = math.floor((self.w-2*margin_x)/(dw+h_gap))
    local x = self.pos.x + self.w/2 - math.min(dice_n, max_slots_per_row)*(dw + h_gap - 1)/2
    local y = pos.y + header_h
    for i = 1, dice_n do
        self.slots[i] = DieSlot("mat", player_num)
        DieSlotView(self.slots[i], Vector(x,y))
        if i%max_slots_per_row == 0 then
            x = self.pos.x + self.w/2 - math.min(dice_n-i, max_slots_per_row)*(dw + h_gap - 1)/2
            y = y + dh + v_gap
        else
            x = x + dw + h_gap
        end
    end

    --Bg
    self.image = UI.mat
    self.img_sx = self.w/self.image:getWidth()
    self.img_sy = self.h/self.image:getHeight()
end

--CLASS FUNCTIONS--

function Mat:draw()
    local g = love.graphics

    --Draw bg shadow
    Color.set("black")
    local off = 8
    g.draw(self.image, self.pos.x+off, self.pos.y+off, nil,
                       self.img_sx, self.img_sy)

    --Draw bg
    Color.set("white")
    g.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.img_sx, self.img_sy)

    --Draw bag
    Color.set("black")
    local off = 4
    g.draw(self.bag_image, self.bag_pos.x + off, self.bag_pos.y + off, nil,
                       self.bag_img_sx, self.bag_img_sy)
    Color.set("white")
    g.draw(self.bag_image, self.bag_pos.x, self.bag_pos.y, nil,
                       self.bag_img_sx, self.bag_img_sy)

    --Draw rerolls
    Color.set("black")
    local off = 2
    g.draw(self.rerolls_image, self.rerolls_pos.x + off, self.rerolls_pos.y + off, nil,
                       self.rerolls_img_sx, self.rerolls_img_sy)
    Color.set("white")
    g.draw(self.rerolls_image, self.rerolls_pos.x, self.rerolls_pos.y, nil,
                       self.rerolls_img_sx, self.rerolls_img_sy)
    Font.set(self.rerolls_font)
    Color.set("black")
    g.print(self.player_area:getRerolls(), self.rerolls_text_pos.x, self.rerolls_text_pos.y)

    --Draw grave
    Color.set("black")
    local off = 4
    g.draw(self.grave_image, self.grave_pos.x + off, self.grave_pos.y + off, nil,
                      self.grave_img_sx, self.grave_img_sy)
    Color.set("white")
    g.draw(self.grave_image, self.grave_pos.x, self.grave_pos.y, nil,
                      self.grave_img_sx, self.grave_img_sy)

    --Draw slot
    for _, die_slot in ipairs(self.slots) do
        die_slot.view:draw()
    end
end

--Return all dices that are in a die slot in this area
function Mat:getDice()
    local t = {}
    for _, die_slot in ipairs(self.slots) do
        if die_slot:getDie() then
            table.insert(t, die_slot:getDie())
        end
    end

    return t
end

--Returns center position of bag
function Mat:getBagPosition()
    return Vector(self.bag_pos.x + self.bag_w/2, self.bag_pos.y)
end

--Returns center position of gravepool
function Mat:getGravepoolPosition()
    return Vector(self.grave_pos.x + self.grave_w/2, self.grave_pos.y)
end

return Mat
