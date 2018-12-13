local TextBox = require "classes.text_box"
local Font = require "font"
local Util = require "util"
local Color = require "classes.color.color"
local Button = require "classes.button"
local Gamestate = require "common.extra_libs.hump.gamestate"
local argparse = require "common.extra_libs.argparse"
local suit = require "extra_libs.suit"
local i18n = require "i18n"

local state = {}

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

local options
local chars = {"melee", "ranged"}
local chosen_char = 1
local host_input = {
    text = nil
}

local function connect_to_server(options, host, char)
    Gamestate.switch(require "gamestates.await_connection", options, host, chars[chosen_char])
end

function state:enter()
    options = getCmdOptions()
    if options.lang then
        i18n.setLocale(options.lang)
    end

    host_input.text = options.host or '159.89.154.166'
    if options.char then
        for i, c in ipairs(chars) do
            if c == options.char then
                chosen_char = i
            end
        end
    end

    if options.auto_connect then
        connect_to_server(options, box.lines[1], chars[chosen_char])
    end

    Font.set('regular', 30)
end

function state:leave()
end

function state:update(dt)
    -- UI
    suit.layout:reset((WIN_W - 430) / 2, 200, 10, 30)

    local connect = false

    suit.layout:push(suit.layout:down(430, 50))
        suit.Label('IP:', {align = 'left'}, suit.layout:right(60, 50))
        connect = suit.Input(host_input, suit.layout:right(300, nil)).submitted
    suit.layout:pop()
    if suit.Button(i18n "ui/button/change_char", suit.layout:down()).hit then
        chosen_char = (chosen_char % #chars) + 1
    end
    suit.Label('Your character: ' .. chars[chosen_char], {id = 1}, suit.layout:down())
    local cols = suit.layout:cols { pos = {suit.layout:nextRow()}, min_width = 430,
        {'fill', 50},
        {100, 50},
        {'fill', 50},
    }

    local hit = suit.Button(i18n "ui/button/confirm_ip", cols.cell(2)).hit
    if connect or hit then
        print(connect, hit)
        connect_to_server(options, host_input.text, chars[chosen_char])
    end
end

function state:draw()
    suit.draw()
end

function state:keypressed(...)
    suit.keypressed(...)
end

function state:textinput(...)
    suit.textinput(...)
end

--Return state functions
return state
