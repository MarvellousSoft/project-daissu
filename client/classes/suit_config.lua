local suit = require "extra_libs.suit"

local config = {}

function config:init()
    local image_pressed = IMG.button_pressed
    local image_locked = IMG.button_locked
    local default_image = IMG.button
    local iw, ih = default_image:getWidth(), default_image:getHeight()
    local text_y_offset = -1.5

    suit.theme.Button = function(text, opt, x, y, w, h)
        local lg = love.graphics

        --Draw bg
        if opt.state == 'hovered' or opt.state == 'active' then
            lg.setColor(230, 230, 230)
        else
            lg.setColor(255, 255, 255)
        end
        local image
        if opt.locked then
            image = image_locked
        elseif opt.state == 'active' then
            image = image_pressed
        else
            image = default_image
        end
        lg.draw(image, x, y, nil, w / iw, h / ih)

        --Draw text aligned to center of button
        lg.setColor(0, 0, 0)
        local offset
        if opt.state == 'active' then
            offset = -text_y_offset * h / ih
        else
            offset = text_y_offset * h / ih
        end
        lg.setFont(opt.font)
        y = y + suit.theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
        lg.printf(text, x + 2, y + offset, w - 4, opt.align or 'center')
    end
end

return config