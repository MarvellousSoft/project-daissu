local TextBox = require "classes.text_box"
local Font = require "font"
local Util = require "util"
local Color = require "classes.color.color"
local Button = require "classes.button"
local Gamestate = require "extra_libs.hump.gamestate"

local state = {}

local box
local chars = {"meele", "ranged"}
local chosen_char = 1
local char_button
local go_button

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
    box = TextBox(450, 300, 300, 30, 1, 1, false, Font.get('regular', 25), accepted, Color.convert(Color.new(10, 30, 10, 255, 'RGB')))
    box:activate()
    box:putString('159.89.154.166')

    char_button = Button(400, 350, 60, 60, "Change", function()
        chosen_char = (chosen_char % #chars) + 1
    end)

    go_button = Button(500, 450, 100, 100, "Go!", function()
        Gamestate.switch(require "gamestates.await_connection", box.lines[1], chars[chosen_char])
    end)
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
    Color.set(Color.white())
    Font.set('regular', 25)

    love.graphics.print("IP", 400, 300)
    box:draw()

    char_button:draw()
    Color.set(Color.white())
    Font.set('regular', 25)
    love.graphics.print("Your character: " .. chars[chosen_char], 480, 380)

    go_button:draw()
end

function state:keypressed(...)
    box:keyPressed(...)
end

function state:textinput(...)
    box:textInput(...)
end

function state:mousepressed(...)
    box:mousePressed(...)
    char_button:mousepressed(...)
    go_button:mousepressed(...)
end

function state:mousescroll(...)
    box:mouseScroll(...)
end

function state:mousereleased(...)
    box:mouseReleased(...)
end

function state:mousemoved(...)
    box:mouseMoved(...)
end

--Return state functions
return state
