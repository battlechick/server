local skynet = require "skynet"
local table_insert = table.insert

local room
local map
local players

local cmd = {}
local guid2unit = {}
setmetatable(guid2unit, {__mode = "v"})

require "battle.unit"
require "battle.map"
local map_manager = require "battle.map_manager"

local json = require "cjson"

function cmd.init(_room)
    room = _room
    --skynet.dump(room)
    players = room.players

    init_map()
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
    map = Map.new(map_id)
    map:init()
    guid2unit = map.guid2unit
end

function start()
    local tbl = {unitList={}} 
    local count = 0
    -- 分若干个小包发
    for _, unit in pairs(guid2unit) do
        table_insert(tbl.unitList, {
            guid = unit.guid, 
            unitId = unit.unit_id, 
            x = unit.position.x,
            y = unit.position.y,
            o = unit.position.o,
            data = json.encode(unit:get_data()) })
        if count >= 100 then
            count = 0
            broadcast("S2C_CreateUnit",tbl)
            tbl = {unitList={}} 
            skynet.sleep(2)
        end
        count = count + 1
    end
    broadcast("S2C_CreateUnit",tbl)
    broadcast("S2C_StartBattle", {})
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
