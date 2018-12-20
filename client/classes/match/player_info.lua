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
        self.pt_margin = 5 --Distance between player info edge and portrait
        self.pt_image = UI.player_info_portrait
        self.pt_ix = self.pt_w/self.pt_image:getWidth()  --Horizontal scale for image
        self.pt_iy = self.pt_h/self.pt_image:getHeight() --Vertical scale for image
        --Player image
        self.pi_w, self.pi_h = 80, 80
        self.pi_offset = 1
        self.pi_image = Archetype[self.archetype]
        self.pi_ix = self.pi_w/self.pi_image:getWidth()  --Horizontal scale for image
        self.pi_iy = self.pi_h/self.pi_image:getHeight() --Vertical scale for image

        --Icons
        self.icons_left_margin = 20 --Distance between portrait and first icon
        self.icons_margin = 28 --Distance between each icon
        self.icons_right_margin = 35 --Distance between last icon and player order
        self.icons_font = Font.get("regular", 20) --Font for number below each icon
        --Inver margins if its flipped
        if self.flip then
            self.icons_left_margin, self.icons_right_margin = self.icons_right_margin, self.icons_left_margin
        end
        self.icons_w, self.icons_h = 50, 50
        --Player Bag
        self.pb_image = UI.bag_icon
        self.pb_ix = self.icons_w/self.pb_image:getWidth()  --Horizontal scale for image
        self.pb_iy = self.icons_h/self.pb_image:getHeight() --Vertical scale for image
        self.pb_value = 6
        --Player Mat
        self.pm_image = UI.mat_icon
        self.pm_ix = self.icons_w/self.pm_image:getWidth()  --Horizontal scale for image
        self.pm_iy = self.icons_h/self.pm_image:getHeight() --Vertical scale for image
        self.pm_value = 6
        --Player Grave
        self.pg_image = UI.grave_icon
        self.pg_ix = self.icons_w/self.pg_image:getWidth()  --Horizontal scale for image
        self.pg_iy = self.icons_h/self.pg_image:getHeight() --Vertical scale for image
        self.pg_value = 6

        --Player order
        self.po_w, self.po_h = 50, 70
        self.po_image = UI.player_order
        self.po_ix = self.po_w/self.po_image:getWidth()  --Horizontal scale for image
        self.po_iy = self.po_h/self.po_image:getHeight() --Vertical scale for image
        self.po_font = Font.get('regular', 30)

        self.tp = "player_info"
    end
}

function PlayerInfo:draw()
    local g = love.graphics
    local match = Util.findId("match")
    local scale, x, order
    if self.flip then
        scale = -1
        x = self.pos.x + self.w
        order = {'pg', 'pm', 'pb'}
    else
        scale = 1
        x = self.pos.x
        order = {'pb', 'pm', 'pg'}
    end

    --Draw bg
    Color.set("black")
    local offset = 5
    g.draw(self.bg_image, self.pos.x + offset, self.pos.y + offset, nil, self.bg_ix, self.bg_iy)
    Color.set(self.color)
    g.draw(self.bg_image, self.pos.x, self.pos.y, nil, self.bg_ix, self.bg_iy)

    --Draw portrait bg
    x = x + scale*(self.pt_margin)
    Color.setWithAlpha(Color.black(),180)
    local shadow = 8
    g.draw(self.pt_image, x + shadow*scale, self.pos.y + self.h/2 - self.pt_h/2 + shadow, nil, self.pt_ix * scale, self.pt_iy)
    Color.set(self.color)
    g.draw(self.pt_image, x, self.pos.y + self.h/2 - self.pt_h/2, nil, self.pt_ix * scale, self.pt_iy)

    --Draw portrait
    local px = x + scale*(self.pt_w/2 - self.pi_w/2) + self.pi_offset
    Color.set("white")
    g.draw(self.pi_image, px, self.pos.y + self.h/2 - self.pi_h/2, nil, self.pi_ix * scale, self.pi_iy)

    --Draw icons
    x = x + scale*(self.pt_w + self.icons_left_margin + self.icons_w/2) - self.icons_w/2
    Font.set(self.icons_font)
    local y = self.pos.y + self.h/2 - self.icons_h/2 - self.icons_font:getHeight()/2
    for _, icon in ipairs(order) do
        Color.set("white")
        g.draw(self[icon..'_image'], x, y, nil, self[icon..'_ix'], self[icon..'_iy'])
        Color.set("black")
        local value = self[icon..'_value']
        local tx = self.icons_font:getWidth(value)
        g.print(value, x + self.icons_w/2 - tx/2, y + self.icons_h + 5)
        x = x + scale*(self.icons_w + self.icons_margin)
    end

    --Draw player order
    Color.set(self.color)
    x = x + scale*(-self.icons_margin + self.icons_right_margin - self.icons_w/2) + self.icons_w/2
    g.draw(self.po_image, x, self.pos.y + self.h/2 - self.po_h/2, nil, self.po_ix*scale, self.po_iy)
    if match then
        local order = match:getPlayerOrder(self.player_id)
        local tw = self.po_font:getWidth(order)
        local th = self.po_font:getHeight(order)
        Color.set("white")
        Font.set(self.po_font)
        g.print(order, x + scale*self.po_w/2 - tw/2, self.pos.y + self.h/2 - th/2)
    end
end

return PlayerInfo
