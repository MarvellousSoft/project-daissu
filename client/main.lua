--HUMP STUFF
local Gamestate = require "common.extra_libs.hump.gamestate"
local Timer = require "common.extra_libs.hump.timer"

--MY MODULES
local Setup = require "setup"
local ResManager = require "res_manager"

--GAMESTATES
local GS = {
    GAME     = require "gamestates.game",     --Game Gamestate
    CONN_MENU = require "gamestates.connection_menu"
}

-- Networking
local Client = require "classes.net.client"

------------------
--LÖVE FUNCTIONS--
------------------

function love.load()

    Setup.config() --Configure your game

    Gamestate.registerEvents() --Overwrites love callbacks to call Gamestate as well

    --[[
        Setup support for multiple resolutions. ResManager.init() Must be called after Gamestate.registerEvents()
        so it will properly call the draw function applying translations.
    ]]
    ResManager.init()

    Gamestate.switch(GS.CONN_MENU)
    --Gamestate.switch(GS.GAME, tonumber(arg[2])) --Jump to the inicial state

end

function love.update(dt)
    Timer.update(dt)
    Client.update(dt)
end