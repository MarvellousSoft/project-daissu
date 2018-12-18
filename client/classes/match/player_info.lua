local POS       = require "classes.primitives.pos"
local ELEMENT   = require "classes.primitives.element"
local Color     = require "classes.color.color"
local Class     = require "common.extra_libs.hump.class"
local Vector    = require "common.extra_libs.hump.vector"
local Util      = require "steaming_util"
local Font      = require "font"
local UI        = require("assets").images.UI
local Archetype = require("assets").images.characters

local PlayerInfo = Class{
    __includes = {ELEMENT, POS},
    init = function(self, x, y, w, h, player_id, archetype)
        ELEMENT.init(self)

        POS.init(self, x, y)
        self.w, self.h = w, h

        self.archetype = archetype
        self.player_id = player_id

        local match = Util.findId("match")
        assert(match, "Couldn't access match")

        self.color = match:getPlayerColor(player_id)
        self.flip = match:getPlayerSource(player_id) == 'remote' --If its an opponent's info

        --BG
        self.bg_image = UI.player_info
        self.bg_ix = self.w/self.bg_image:getWidth()  --Horizontal scale for image
        self.bg_iy = self.h/self.bg_image:getHeight() --Vertical scale for image

        --Portrait
        self.pt_w, self.pt_h = 110, 110
        self.pt_margin = 5
        self.pt_image = UI.player_info_portrait
        self.pt_ix = self.pt_w/self.pt_image:getWidth()  --Horizontal scale for image
        self.pt_iy = self.pt_h/self.pt_image:getHeight() --Vertical scale for image
        --Player image
        self.pi_w, self.pi_h = 80, 80
        self.pi_offset = 1
        self.pi_image = Archetype[self.archetype]
        self.pi_ix = self.pi_w/self.pi_image:getWidth()  --Horizontal scale for image
        self.pi_iy = self.pi_h/self.pi_image:getHeight() --Vertical scale for image

        --Player order
        self.po_margin = 10
        self.po_w, self.po_h = 80, 80
        self.po_image = UI.player_order
        self.po_ix = self.po_w/self.po_image:getWidth()  --Horizontal scale for image
        self.po_iy = self.po_h/self.po_image:getHeight() --Vertical scale for image
        self.po_font = Font.get('regular', 30)

        self.tp = "player_info"
    end
}

function PlayerInfo:draw()
    local g = love.graphics

    --Draw bg
    Color.set("black")
    local offset = 5
    g.draw(self.bg_image, self.pos.x + offset, self.pos.y + offset, nil, self.bg_ix, self.bg_iy)
    Color.set(self.color)
    g.draw(self.bg_image, self.pos.x, self.pos.y, nil, self.bg_ix, self.bg_iy)

    --Draw portrait bg
    local scale
    if self.flip then
        offset = self.w - self.pt_margin
        scale = -1
    else
        offset = self.pt_margin
        scale = 1
    end
    Color.setWithAlpha(Color.black(),180)
    local shadow = 8
    g.draw(self.pt_image, self.pos.x + offset + shadow*scale, self.pos.y + self.h/2 - self.pt_h/2 + shadow, nil, self.pt_ix * scale, self.pt_iy)
    Color.set(self.color)
    g.draw(self.pt_image, self.pos.x + offset, self.pos.y + self.h/2 - self.pt_h/2, nil, self.pt_ix * scale, self.pt_iy)

    --Draw portrait
    if self.flip then
        offset = self.w - self.pt_margin - self.pt_w/2 + self.pi_w/2 + self.pi_offset
        scale = -1
    else
        offset = self.pt_margin + self.pi_offset + self.pt_w/2 - self.pi_w/2
        scale = 1
    end
    Color.set("white")
    g.draw(self.pi_image, self.pos.x + offset, self.pos.y + self.h/2 - self.pi_h/2, nil, self.pi_ix * scale, self.pi_iy)

    --Draw player order
    if self.flip then
        offset = self.po_margin
    else
        offset = self.w - self.po_margin - self.po_w
    end
    Color.set(self.color)
    local x, y = self.pos.x + offset, self.pos.y + self.h/2 - self.po_h/2
    g.draw(self.po_image, x, y, nil, self.po_ix, self.po_iy)
    local match = Util.findId("match")
    if match then
        local order = match:getPlayerOrder(self.player_id)
        local tw = self.po_font:getWidth(order)
        local th = self.po_font:getHeight(order)
        Color.set("black")
        Font.set(self.po_font)
        g.print(order, x + self.po_w/2 - tw/2, y + self.po_h/2 - th/2)
    end
end

return PlayerInfo
