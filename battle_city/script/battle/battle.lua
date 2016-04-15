local skynet = require "skynet"
local table_insert = table.insert

local room
local map
local players

local cmd = {}
local guid2unit = {}
setmetatable(guid2unit, {__mode = "v"})

require "battle.map"
local map_manager = require "battle.map_manager"

function cmd.init(_room)
    room = _room
    players = room.players

    for player_id, player in pairs(players) do
        player.loaded = 0
    end
end

function cmd.join_battle(player_id)
    local player = players[player_id]
    if not player then
        return false
    end
    player.loaded = 100

    if check_load_finished() then
        start()
    end
    return true
end

function check_load_finished()
    for _, player in pairs(players) do
        if player.loaded < 100 then
            return false
        end
    end
    return true
end

function init_map()
    local map_id = room.map_id
    local map_data = map_manager.get_map_data(map_id)
    map = Map.new()
    map:init(map_data)
    for _, line in ipairs(line) do
        for _, tile in ipairs(line) do
            guid2unit[tile.guid] = tile
        end
    end

end

function start()
    local tbl = {} 
    local count = 0
    for _, unit in pairs(guid2unit) do
        table_insert(tbl, {guid = unit.guid, unit_type = unit.unit_type, data = "" })
    end

    broadcast("S2C_StartBattle", tbl)
end

function broadcast(message_type, tbl)
    for player_id, _ in pairs(players) do
        skynet.call(".agent"..player_id, "lua", "send_package", message_type, tbl)
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = cmd[command]
        skynet.ret(skynet.pack(f(...)))
    end)
end)
