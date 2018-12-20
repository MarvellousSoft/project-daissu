local Class        = require "common.extra_libs.hump.class"
local Util         = require "common.util"
local Logic        = require "common.match.board_logic"
local Server       = require "server"
local log          = require "common.extra_libs.log"
local ActionsModel = require "common.actions_model"
local PlayerData   = require "common.match.player_data"

local Match = Class {}

local function newTurn(self)
    self.logic:startNewTurn()
    for _, p in ipairs(self.players) do
        Util.exhaust(function() return p.data:grab(2) end)
        p.data:refillRerolls()
    end
end

function Match:init(cl_list)
    self.logic = Logic(5, 5, #cl_list)
    Util.shuffle(cl_list)
    local archetypes = Util.map(cl_list, function(c) return c.info.archetype end)
    -- Player list
    self.players = {}
    -- Map: Client -> Player
    self.player_from_client = {}
    for i, c in ipairs(cl_list) do
        local seed = love.math.random(0, 2 ^ 32 - 1)
        self.players[i] = {
            client = c.client,
            i = i,
            data = PlayerData(archetypes[i], seed)
        }
        self.player_from_client[c.client] = self.players[i]
        c.client:send('start game', {
            local_id = i,
            player_count = #cl_list,
            archetypes = archetypes,
            seed = seed
        })
    end
    self.actions = {}
    self.lock_count = 0
    self.logic:start()
    newTurn(self)
end

function Match:getInputForAction(data)
    if data == nil then
        self.turn_co = nil
        self.waiting_for_input = nil
        newTurn(self)
        return nil
    end
    if data.action == 'none' then return self:getInputForAction(self.turn_co()) end
    if ActionsModel.needsInput(data.action) then
        self.waiting_for_input = data.player
    else
        return self:getInputForAction(self.turn_co())
    end
end

local function idsToDice(player, ids)
    return Util.map(ids, function(id)
        if id == -1 then return nil end
        return Util.assertNonNil(player.data:getByIdFromMat(id))
    end)
end

local function diceToActions(player, dice)
    return Util.map(dice, function(d)
        return d and d:getCurrent() or 'none'
    end)
end

function Match:actionsLocked(client, actions)
    local p = self.player_from_client[client]
    if not p or self.logic.state ~= 'choosing actions' or self.actions[p.i] then
        log.warn('Client sent invalid action.')
        return Server.kick(client)
    end
    -- id -> die
    actions = idsToDice(p, actions)
    for _, d in ipairs(actions) do
        if d then
            p.data:sendDieToGrave(d)
        end
    end
    self.actions[p.i] = diceToActions(p, actions)
    self.lock_count = self.lock_count + 1
    if self.lock_count == #self.players then
        local actions = self.actions
        self.lock_count = 0
        self.actions = {}
        for i, p in ipairs(self.players) do
            p.client:send('turn ready', actions)
        end
        self.turn_co = Util.wrap(function() self.logic:playTurnFromActions(actions) end)
        self:getInputForAction(self.turn_co())
    end
end

function Match:actionInput(client, data)
    local p = self.player_from_client[client]
    if not p or self.logic.state ~= 'playing turn' or self.waiting_for_input ~= p.i then
        return Server.kick(client)
    end
    for i, p2 in ipairs(self.players) do
        if p ~= p2 then
            p2.client:send('action input', data)
        end
    end
    self.waiting_for_input = nil
    -- continue turn
    self:getInputForAction(self.turn_co(unpack(data)))
end

function Match:reroll(client, id)
    local p = self.player_from_client[client]
    if not p or self.logic.state ~= 'choosing actions' or self.actions[p.i] then
        log.warn('Client sent invalid action.')
        return Server.kick(client)
    end
    p.data:reroll(p.data:getByIdFromMat(id))
end

return Match
