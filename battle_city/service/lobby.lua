
local skynet = require "skynet"
local cluster = require "cluster"
require "skynet.manager"

local table_insert = table.insert
local table_remove = table.remove

local auto_room_id = 10001
local rooms = {}
local room_list = {}

local cmd = {}
function cmd.create_room(room_name, player_id)
    local room = {}
    room.map_id = 1 
    room.room_id = auto_room_id
    room.room_name = room_name 
    room.total_count = 2
    room.cur_count = 0
    room.players = {}
    room.status = "waiting"
    room.captain = player_id

    rooms[room.room_id] = room
    table_insert(room_list, room)
    auto_room_id = auto_room_id + 1
    return room.room_id
end

function cmd.get_room_list(start_idx, end_idx)
    local tbl = {}
    for i = start_idx, end_idx, 1 do
        if i > #room_list then
            return tbl
        end
        table_insert(tbl, room_list[i])
    end
    return tbl
end

function cmd.join_room(room_id, player_id, player_name)
    local room = rooms[room_id]
    if not room or room.players[player_id] then
        return false
    end
    room.cur_count = room.cur_count + 1
    local player = {
        player_id = player_id,
        player_name = player_name,
        ready = false,
        idx = room.cur_count
    }
    room.players[player_id] = player

    broadcast_room_data(room)
    return true
end

function cmd.quit_room(room_id, player_id)
    local room = rooms[room_id]
    room.players[player_id] = nil
    if check_empty(room) then
        rooms[room_id] = nil
    end
    room.cur_count = room.cur_count - 1
    return true
end

function cmd.broadcast_room_data(room_id)
    local room = rooms[room_id]
    broadcast_room_data(room)
end

function cmd.prepare_game(room_id, player_id, flag)
    local room = rooms[room_id]
    if not room then return false end
    local player = room.players[player_id]
    if not player then return false end
    player.ready = flag
end

function cmd.start_game(room_id, player_id)
    local room = rooms[room_id]
    if not room then return false end 
    if room.captain ~= player_id then
        return false
    end
    local battle, address, port = cluster.call("battlemng", ".battlemng", "create", room) 
    if battle ~= 0 then
        room.status = "loading"
        broadcast(room, "S2C_LoadBattle", {battle = battle, address = address, port = port}) 
    else
        return false
    end

    return true
end

function cmd.abort()
    skynet.fork(function()
        print("lobby server will be stop")
        skynet.sleep(100) 
        skynet.abort()
    end)
end

function check_empty(room)
    if next(room.players) then
        return
    end
    rooms[room.room_id] = nil
    for i,v in ipairs(room_list) do
        if v == room then
            table_remove(room_list, i)
        end
    end
end

function broadcast_room_data(room)
    local tbl = {
        roomId = room.room_id,
        roomName = room.room_name,
        captianId = room.captain,
        playerList = {}
    }
    for _, player in pairs(room.players) do
        table_insert(tbl.playerList, {
            playerId = player.player_id,
            playerName = player.player_name,
            ready = player.ready,
        })
    end
    broadcast(room, "S2C_RoomData", tbl)
end

function broadcast(room, message_type, tbl)
    print("broadcast")
    for player_id, _ in pairs(room.players) do
        print("call agent"..player_id)
        skynet.call(".agent"..player_id, "lua", "send_package", message_type, tbl)
    end
end

function send_package(player_id, message_type, tbl)
    skynet.call(".agent"..player_id, "lua", "send_package", message_type, tbl) 
end

skynet.start(function() 
    skynet.dispatch("lua", function(_,_,command, ...)
        local f = cmd[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    skynet.register ".lobby"
end)
