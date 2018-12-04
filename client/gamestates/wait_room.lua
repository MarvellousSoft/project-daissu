local TextBox = require "classes.text_box"
local Font = require "font"
local Color = require "classes.color.color"
local Gamestate = require "common.extra_libs.hump.gamestate"
local Client = require "classes.net.client"
local Button = require "classes.button"
local Util = require "util"

local state = {}
local box
local room
local room_button
local ready_button
local room_list = {}
local ready = false

local function readyText()
    return ready and 'Not ready!' or 'Ready!'
end

function state:enter(prev, options, char_type)
    room = 'none'
    local cb = Client.on('client data', function(list)
        room_list = list
        for _, r in ipairs(room_list) do
            for _, c in ipairs(r.clients) do
                if c.id == Client.getConnectId() then
                    ready = c.ready
                    room = r.name
                    ready_button:setText(readyText())
                    return
                end
            end
        end
    end)
    Client.listenOnce('start game', function(i)
        assert(Client.removeCallback(cb))
        Gamestate.switch(require "gamestates.game", i, char_type)
    end)

    local accepted = {}
    for i = 33, 126 do
        accepted[string.char(i)] = string.char(i)
    end
    box = TextBox(450, 300, 300, 30, 1, 1, false, Font.get('regular', 25), accepted, Color.convert(Color.new(10, 30, 10, 255, 'RGB')))
    box:activate()
    if options.room then
        room = options.room
        box:putString(room)
        Client.send('change room', room)
        ready = true
        Client.send('ready', ready)
    end

    room_button = Button(350, 300, 100, 100, "Change room", function()
        if box.lines[1] == '' then return end
        room = box.lines[1]
        Client.send('change room', room)
    end)

    ready_button = Button(350, 500, 60, 60, readyText(), function()
        ready = not ready
        ready_button:setText(readyText())
        Client.send('ready', ready)
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
    box:draw()
    room_button:draw()
    ready_button:draw()

    Color.set(Color.white())
    Font.set('regular', 20)
    love.graphics.print('Your current room is ' .. room, 400, 600)
    love.graphics.print('You are ' .. (ready and 'ready' or 'not ready'), 400, 630)

    Font.set('regular', 15)
    local i = 0
    for _, room in ipairs(room_list) do
        love.graphics.print(room.name .. ':', 1000, 300 + i * 20)
        i = i + 1
        for _, cl in ipairs(room.clients) do
            love.graphics.print(cl.id .. '  ' .. (cl.ready and 'x' or ''), 1000, 300 + i * 20)
            i = i + 1
        end
        i = i + 2
    end
end

function state:keypressed(...)
    box:keyPressed(...)
end

function state:textinput(...)
    box:textInput(...)
end

function state:mousepressed(...)
    room_button:mousepressed(...)
    ready_button:mousepressed(...)
    box:mousePressed(...)
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
