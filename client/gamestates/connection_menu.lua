local TextBox = require "classes.text_box"
local Font = require "font"
local Util = require "util"
local Color = require "classes.color.color"
local Button = require "classes.button"
local Gamestate = require "common.extra_libs.hump.gamestate"
local argparse = require "common.extra_libs.argparse"

local state = {}

local box
local chars = {"melee", "ranged"}
local chosen_char = 1
local char_button
local go_button

local function connect_to_server(options, host, char)
    Gamestate.switch(require "gamestates.await_connection", options, host, chars[chosen_char])
end

local function getCmdOptions()
    local parser = argparse()
    parser:argument("game")
    parser:option("--host")
    parser:option("--char")
    parser:option("--room")
    parser:option("--auto-ready")
    parser:option("--lang")
    parser:flag("--auto-connect")
    return parser:parse()
end

function state:enter()
    local options = getCmdOptions()
    if options.lang then
        local i18n = require "i18n"
        i18n.setLocale(options.lang)
    end

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
    box:putString(options.host or '159.89.154.166')
    if options.char then
        for i, c in ipairs(chars) do
            if c == options.char then
                chosen_char = i
            end
        end
    end

    char_button = Button(390, 350, 70, 70, "change_char", function()
        chosen_char = (chosen_char % #chars) + 1
    end)

    go_button = Button(500, 450, 100, 100, "confirm_ip", function()
        connect_to_server(options, box.lines[1], chars[chosen_char])
    end)

    if options.auto_connect then
        connect_to_server(options, box.lines[1], chars[chosen_char])
    end
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
    go_button:mousepressed(...)
    char_button:mousepressed(...)
end

function state:mousereleased(...)
    box:mousereleased(...)
    char_button:mousereleased(...)
    go_button:mousereleased(...)
end

function state:mousescroll(...)
    box:mouseScroll(...)
end

function state:mousemoved(...)
    box:mousemoved(...)
    char_button:mousemoved(...)
    go_button:mousemoved(...)
end

--Return state functions
return state
