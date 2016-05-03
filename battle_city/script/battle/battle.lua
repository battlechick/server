
local table_insert = table.insert
local socket = require "socket"
local protobuf = require "protobuf"

local battle = {
    room = nil,
    map = nil,
    players = nil,
    guid2unit = {}
}
--setmetatable(guid2unit, {__mode = "v"})

require "battle.unit.unit"
require "battle.map"
require "common.quadtree"
local skynet = require "skynet"
local map_manager = require "battle.map_manager"
local bt_manager = require "behavior_tree.bt_manager"
local data_manager = require "data_manager.data_manager"

local json = require "cjson"

function battle:init(_room)
    self.room = _room
    self.players = self.room.players
    self.msgCache = {packageList = {}}

    for player_id, player in pairs(self.players) do
        player.loaded = 0
    end
end

function battle:join_battle(player_id, client_fd)
    local player = self.players[player_id]
    if not player then
        return false
    end
    player.loaded = 100
    player.client_fd = client_fd
    skynet.log("join fd", client_fd)

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
    skynet.log(self.map.width, self.map.height)
    self.qtree = QuadTree.new(0,0, self.map.width, self.map.height, 50, 1000, 100)
    self.qtree:subdivide()
    self.guid2unit = self.map.guid2unit
    for guid, unit in pairs(self.guid2unit) do
        local collider = map_manager.get_collider(unit.unit_id)
        if collider then
            unit.x = unit.position.x - collider.width/2 
            unit.y = unit.position.y - collider.height/2
            unit.width = collider.width
            unit.height = collider.height
            self.qtree:addObject(unit)
        end
    end
    skynet.dump(self.qtree)
end

function battle:start()
    self:init_map()

    local tree_id = battle.map.proto.treeId
    skynet.log("scene treeid:"..tree_id)
    self.btree = bt_manager.create_tree(tree_id, battle)
    self.btree:exec()


    battle:broadcast_start()
    self:main_loop()
end

function battle:main_loop()
    
    self:raw_send_package()

    skynet.timeout(10, function()
        self:main_loop()
    end)
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
    local hero = Hero.new(unit_id)
    hero:set_position({x = 1, y = 1, o = 90})
    hero.x = 1
    hero.y = 1
    hero.width = 2
    hero.height = 2
    self.qtree:addObject(hero)
    local objects = self.qtree:getCollidableObjects(hero)
    skynet.log("做碰撞检测啦", #objects)
    for _, obj in ipairs(objects) do
        skynet.log(obj.position.x, obj.position.y)
    end
    self:broadcast_create_unit(hero)
    return true
end

protobuf.register_file "../battle_city/proto/Msg.pb"  
function battle:raw_send_package()
    if #self.msgCache.packageList == 0 then
        return
    end
    skynet.log("&&&&raw_send_package "..#self.msgCache.packageList)
    for player_id, player in pairs(self.players) do
        socket.write(player.client_fd, string.pack("<s4", protobuf.encode("Message",self.msgCache)))
    end
    self.msgCache.packageList = {}
end

function battle:broadcast(message_type, tbl, delay)
    local buffer = protobuf.encode(message_type, tbl)
    table_insert(self.msgCache.packageList, {name = message_type, rpcId = 0, data = buffer}) 
end

function battle:broadcast_start()
    -- 分若干个小包发
    self:broadcast("S2C_StartBattle", {})
    for _, unit in pairs(self.guid2unit) do
        self:broadcast_create_unit(unit, 100)     
    end
    skynet.log("send start")
end

function battle:broadcast_create_unit(unit, delay)
    local tbl = {unitInfo = 
        {
            guid = unit.guid, 
            unitId = unit.unit_id, 
            x = unit.position.x,
            y = unit.position.y,
            o = unit.position.o,
            data = json.encode(unit:get_data()) 
        } 
    }
    self:broadcast("S2C_CreateUnit", tbl, delay)
end

function battle:broadcast_update_position(unit)
    local tbl = {
        guid = unit.guid,
        x = unit.position.x,
        y = unit.position.y,
        o = unit.position.o,
    }
    self:broadcast("S2C_UpdatePosition", tbl)
end

function battle:broadcast_del_unit(unit)
    local tbl = {
        guid = unit.guid,
    }
    self:broadcast("S2C_DelUnit", tbl)
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = battle[command]
        skynet.ret(skynet.pack(f(battle, ...)))
    end)
end)
