local TextBox = require "classes.text_box"
local Font = require "font"
local Util = require "util"
local Color = require "classes.color.color"

local state = {}

local box

function state:enter()
    box = TextBox(100, 100, 300, 30, 1, 1, false, Font.get('regular', 25), nil, Color.green('HSL'), Color.red('HSL'))
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
