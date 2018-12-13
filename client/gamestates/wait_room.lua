local TextBox   = require "classes.text_box"
local Font      = require "font"
local Color     = require "classes.color.color"
local Gamestate = require "common.extra_libs.hump.gamestate"
local Client    = require "classes.net.client"
local Button    = require "classes.button"
local Util      = require "util"
local i18n      = require "i18n"
local suit      = require "extra_libs.suit"

local state = {}
local room
local room_list = {}
local larger_font
local title_font

local room_input = { text = "" }
local ready_checkbox = { text = "Ready", checked = false }

function state:enter(prev, options, char_type)
    room = 'none'
    local cb = Client.on('client data', function(list)
        room_list = list
        for _, r in ipairs(room_list) do
            for _, c in ipairs(r.clients) do
                if c.id == Client.getConnectId() then
                    ready_checkbox.checked = c.ready
                    room = r.name
                    return
                end
            end
        end
    end)
    Client.listenOnce('start game', function(info)
        assert(Client.removeCallback(cb))
        Gamestate.switch(require "gamestates.game", info, char_type)
    end)

    if options.room then
        room = options.room
        Client.send('change room', room)
    end


    if options.auto_ready then
        MAIN_TIMER:after(tonumber(options.auto_ready) or 0, function()
            ready_checkbox.checked = true
            Client.send('ready', ready)
        end)
    end

    larger_font = Font.get('regular', 28)
    title_font = Font.get('regular', 50)
    Font.set('regular', 20) -- default font for UI in this gamestate
end

function state:leave()
end

function state:update(dt)
    suit.Label('Wait Room', {font = title_font}, 0, 0, WIN_W, 100)

    suit.layout:reset((WIN_W - 400) / 2, 200, 10, 30)

    local input_sub = suit.Input(room_input, suit.layout:row(400, 50)).submitted
    local change_click = suit.Button(i18n "ui/button/change_room", {id = 2}, suit.layout:cols{pos = {suit.layout:row()}, min_width = 400, {'fill', 50}, {200, 50}, {'fill', 50}}.cell(2)).hit

    if input_sub or change_click and room_input.text ~= '' then
        room = room_input.text
        Client.send('change room', room)
    end

    if suit.Checkbox(ready_checkbox, suit.layout:row()).hit then
        Client.send('ready', ready_checkbox.checked)
    end
    suit.Label("Current Room: " .. room, {font = larger_font}, suit.layout:row(400, 40))

    -- Players list
    suit.layout:reset(WIN_W - 350, 200)

    for _, room in ipairs(room_list) do
        suit.Label(room.name .. ':', {font = larger_font, align = 'left'}, suit.layout:row(330, 35))
        for _, cl in ipairs(room.clients) do
            suit.Label(cl.id .. (cl.ready and ' x' or ''), {align = 'left'}, suit.layout:row(nil, 20))
        end
        suit.layout:row()
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
