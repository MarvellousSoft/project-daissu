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

function state:enter(prev, options, char_type)
    room = 'default'
    Client.listenOnce('start game', function(i)
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
        Client.send('change room', room)
    end
    box:putString(room)

    room_button = Button(350, 300, 100, 100, "Change room", function()
        if box.lines[1] == '' then return end
        room = box.lines[1]
        Client.send('change room', room)
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

    Color.set(Color.white())
    Font.set('regular', 20)
    love.graphics.print('Your current room is ' .. room, 400, 600)
end

function state:keypressed(...)
    box:keyPressed(...)
end

function state:textinput(...)
    box:textInput(...)
end

function state:mousepressed(...)
    room_button:mousepressed(...)
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
