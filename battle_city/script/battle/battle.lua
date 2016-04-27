
local table_insert = table.insert

local battle = {
    room = nil,
    map = nil,
    players = nil,
    guid2unit = {}
}
--setmetatable(guid2unit, {__mode = "v"})

require "battle.unit"
require "battle.map"
local skynet = require "skynet"
local map_manager = require "battle.map_manager"
local bt_manager = require "behavior_tree.bt_manager"
local data_manager = require "data_manager.data_manager"

local json = require "cjson"

function battle:init(_room)
    self.room = _room
    self.players = self.room.players

    self:init_map()
    for player_id, player in pairs(self.players) do
        player.loaded = 0
    end
end

function battle:join_battle(player_id)
    local player = self.players[player_id]
    if not player then
        return false
    end
    player.loaded = 100

    if self:check_load_finished() then
        skynet.timeout(10, function()
            self:start()
        end)
    end
    return true
end

function battle:check_load_finished()
    for _, player in pairs(self.players) do
        if player.loaded < 100 then
            return false
        end
    end
    return true
end

function battle:init_map()
    local map_id = self.room.map_id
    self.map = Map.new(map_id)
    self.map:init()
    self.guid2unit = self.map.guid2unit
end

function battle:start()
    battle:broadcast_start()

    local tree_id = battle.map.proto.treeId
    skynet.log("scene treeid:"..tree_id)
    self.tree = bt_manager.create_tree(tree_id, battle)
    self.tree:exec()
end


function battle:create_unit(unit_id, x, y)
    skynet.log("Map:create_unit "..unit_id)
    return
end

function battle:create_hero(unit_id, x, y, idx)
    local ctrl_player
    for _, player in pairs(self.players) do
        if player.idx == idx then
            ctrl_player = player
        end
    end
    if ctrl_player then
        skynet.log("Map:create_hero "..unit_id)
    else
        skynet.log("Map:create_hero "..unit_id.." fail")
        return false
    end
    return true
end

function battle:broadcast(message_type, tbl)
    for player_id, _ in pairs(self.players) do
        skynet.call(".agent"..player_id, "lua", "send_package", message_type, tbl)
    end
end

function battle:broadcast_start()
    local tbl = {unitList={}} 
    -- 分若干个小包发
    for _, unit in pairs(self.guid2unit) do
        table_insert(tbl.unitList, {
            guid = unit.guid, 
            unitId = unit.unit_id, 
            x = unit.position.x,
            y = unit.position.y,
            o = unit.position.o,
            data = json.encode(unit:get_data()) })
    end
    skynet.log("send start")
    self:broadcast("S2C_CreateUnit",tbl)
    self:broadcast("S2C_StartBattle", {})
end

function battle:broadcast_unit(unit)
    local tbl = {unitList = {
        {
            guid = unit.guid, 
            unitId = unit.unit_id, 
            x = unit.position.x,
            y = unit.position.y,
            o = unit.position.o,
            data = json.encode(unit:get_data()) 
        } 
    }}
    self:broadcast("S2C_CreateUnit", tbl)
end

function battle:broadcast_hero(hero)
    local tbl = {
        guid = hero.guid, 
        unitId = hero.unit_id, 
        x = hero.position.x,
        y = hero.position.y,
        o = hero.position.o,
        data = json.encode(hero:get_data()) 
    }
    self:broadcast("S2C_CreateHero", tbl)
end
    

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = battle[command]
        skynet.ret(skynet.pack(f(battle, ...)))
    end)
end)
