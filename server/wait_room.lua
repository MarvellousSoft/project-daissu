local Server = require "server"
local MatchManager = require "match_manager"
local Room = require "room"

local WaitRoom = {}

local clients = {}
local rooms = {}
local room_size = {}

local function addClientToRoom(client, room)
    rooms[room] = rooms[room] or Room()
    clients[client] = room
    rooms[room]:addPlayer(client)
end

local function remClientFromRoom(client)
    local r = clients[client]
    clients[client] = nil
    rooms[r]:remPlayer(client)
    if r ~= 'none' and rooms[r]:empty() then
        rooms[r] = nil
    end
end

local function debug(...)
    print(...)
    io.flush()
end

local function sendData()
    local room_list = {}
    for name, room in pairs(rooms) do
        table.insert(room_list, room:getData(name))
    end
    for cl in pairs(clients) do
        cl:send('client data', room_list)
    end
end

function WaitRoom.init()
    -- default room for all players
    rooms.none = Room()

    Server.on('connect', function(data, client)
        debug('Client connected --', client)
        addClientToRoom(client, 'none')
        sendData()
    end)

    local change_room_schema = 'string'
    Server.on('change room', function(room, client)
        if not Server.checkSchema(client, change_room_schema, room) then return end
        if clients[client] ~= room then
            debug('Client ', client , ' changing room to ', room)
            remClientFromRoom(client)
            addClientToRoom(client, room)
            sendData()
        end
    end)

    local ready_schema = 'boolean'
    Server.on('ready', function(is_ready, client)
        if not Server.checkSchema(client, ready_schema, is_ready) then return end
        debug('Client', client, 'is ready', is_ready)
        local r = rooms[clients[client]]
        local all_ready = r:playerReady(client, is_ready)
        if clients[client] ~= 'none' and all_ready and r:atLeastTwoPlayers() then
            rooms[clients[client]] = nil
            local cl_list = {}
            debug('Creating match for clients ')
            for client in pairs(r.players) do
                table.insert(cl_list, client)
                clients[client] = nil
                debug(client)
            end
            debug('')
            MatchManager.startMatch(cl_list)
        end
        sendData()
    end)

    Server.on('disconnect', function(data, client)
        debug('Client disconnected --', client)
        if clients[client] == nil then
            -- Client is no longer in wait room
        else
            remClientFromRoom(client)
            sendData()
        end
    end)
end

return WaitRoom
