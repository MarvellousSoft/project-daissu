local TextBox = require "classes.text_box"
local Font = require "font"
local Util = require "util"
local Color = require "classes.color.color"

local state = {}

local box

function state:enter()
    local accepted = {}
    for i = 1, 26 do
        local c_lower, c_upper = string.char(97 + i - 1), string.char(65 + i - 1)
        accepted[c_lower] = c_lower
        accepted[c_upper] = c_lower
    end
    for i = 0, 10 do
        local digit = string.char(48 + i)
        accepted[digit] = digit
    end
    accepted['.'] = '.'
    box = TextBox(100, 100, 300, 30, 1, 1, false, Font.get('regular', 25), accepted, Color.convert(Color.new(10, 30, 10, 255, 'RGB')))
    box:activate()
end

function state:leave()
end


function state:update(dt)
    box:update(dt)
    Util.updateTimers(dt)

    Util.updateDrawTable(dt)

    Util.destroyAll()
end

function state:draw()
    box:draw()
end

function state:keypressed(...)
    box:keyPressed(...)
end

function state:textinput(...)
    box:textInput(...)
end

function state:mousepressed(...)
    box:mousePressed(...)
end

function state:mousescroll(...)
    box:mouseScroll(...)
end

--Return state functions
return state
