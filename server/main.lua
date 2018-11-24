local Server = require "server"
local MatchManager = require "match_manager"
local WaitRoom = require "wait_room"

function love.load()
    Server.init()
    MatchManager.init()
    WaitRoom.init()
end

function love.update(dt)
    Server.update()
end
