local Server       = require "server"
local MatchManager = require "match_manager"
local Room         = require "room"
local log          = require "common.extra_libs.log"

local WaitRoom = {}

-- Map: Client -> Room Name
local clients = {}
-- Map: Room Name -> Room Obj
local rooms = {}

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
        log.info('Client connected --', client)
        addClientToRoom(client, 'none')
        sendData()
    end)

    local change_room_schema = 'string'
    Server.on('change room', function(room, client)
        if not Server.checkSchema(client, change_room_schema, room) then return end
        if clients[client] ~= room then
            log.trace('Client ', client , ' changing room to ', room)
            remClientFromRoom(client)
            addClientToRoom(client, room)
            sendData()
        end
    end)

    local ready_schema = {ready = 'boolean', archetype = 'string'}
    Server.on('ready', function(args, client)
        if not Server.checkSchema(client, ready_schema, args) then return end
        log.trace('Client', client, 'is ready', args.ready)
        log.trace('Client', client, 'is using archetype', args.archetype)
        local r = rooms[clients[client]]
        local all_ready = r:updatePlayer(client, args)
        if clients[client] ~= 'none' and all_ready and r:atLeastTwoPlayers() then
            rooms[clients[client]] = nil
            local cl_list = {}
            log.trace('Creating match for clients ')
            for client, info in pairs(r.players) do
                -- we don't need this information anymore
                info.ready = nil
                table.insert(cl_list, {
                    client = client,
                    info = info
                })
                clients[client] = nil
                log.trace(client)
            end
            log.trace('')
            MatchManager.startMatch(cl_list)
        end
        sendData()
    end)

    Server.on('disconnect', function(data, client)
        log.info('Client disconnected --', client)
        if clients[client] == nil then
            -- Client is no longer in wait room
        else
            remClientFromRoom(client)
            sendData()
        end
    end)
end

return WaitRoom
