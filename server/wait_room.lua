local Server = require "server"
local MatchManager = require "match_manager"

local WaitRoom = {}

local clients = {}
local rooms = {}
local room_size = {}

local function addClientToRoom(client, room)
    if rooms[room] == nil then
        rooms[room] = {}
        room_size[room] = 0
    end
    clients[client] = room
    rooms[room][client] = true
    room_size[room] = room_size[room] + 1
end

local function remClientFromRoom(client)
    local r = clients[client]
    clients[client] = nil
    rooms[r][client] = nil
    room_size[r] = room_size[r] - 1
    if r ~= 'default' and room_size[r] == 0 then
        rooms[r] = nil
        room_size[r] = nil
    end
end

local function sendClientList()
    local cl_list = {}
    for cl, room in pairs(clients) do
        cl_list[cl:getConnectId()] = room
    end
    for cl in pairs(clients) do
        cl:send('client list', cl_list)
    end
end

function WaitRoom.init()
    -- default room for all players
    rooms.default = {}
    room_size.default = 0

    Server.on('connect', function(data, client)
        print('Client connected --', client) io.flush()
        addClientToRoom(client, 'default')
        sendClientList()
    end)

    Server.on('change room', function(room, client)
        if clients[client] ~= room then
            print('Client ', client , ' changing room to ', room)
            remClientFromRoom(client)
            addClientToRoom(client, room)
            if room ~= 'default' and room_size[room] == 2 then
                local cl_list = {}
                for client in pairs(rooms[room]) do table.insert(cl_list, client) end
                assert(#cl_list == 2)
                local a, b = unpack(cl_list)
                rooms[room], room_size[room] = nil, nil
                clients[a], clients[b] = nil, nil
                print('Creating match for clients ', a, ' and ', b)
                MatchManager.startMatch(a, b)
            end
            sendClientList()
        end
    end)

    Server.on('disconnect', function(data, client)
        print('Client disconnected --', client) io.flush()
        if clients[client] == nil then
            -- Client is no longer in wait room
        else
            remClientFromRoom(client)
            sendClientList()
        end
    end)
end

return WaitRoom
