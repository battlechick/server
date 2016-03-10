
local skynet = require "skynet"
require "skynet.manager"

local table_insert = table.insert
local table_remove = table.remove

local auto_room_id = 10001
local rooms = {}
local room_list = {}

local CMD = {}
function CMD.create_room(player)
  local room = {}
  room.room_id = auto_room_id
  room.room_name = player.player_name .. "的房间"
  room.total_count = 2
  room.cur_count = 0
  room.players = {}
  room.captain = player
  player.ready = true

  rooms[room.room_id] = room
  table_insert(room_list, room)
  auto_room_id = auto_room_id + 1
  return room.room_id
end

function CMD.get_room_list(start_idx, end_idx)
  local tbl = {}
  for i = start_idx, end_idx, 1 do
    if i > #room_list then
      return tbl
    end
    table_insert(tbl, room_list[i])
  end
  return tbl
end

function CMD.join_room(room_id, player)
  if player.room_id ~= 0 then
    return false
  end
  local room = rooms[room_id]
  if not room then
    return false
  end
  room.players[player.player_id] = player
  room.cur_count = room.cur_count + 1

  broadcast_room_data(room)
  return true
end

function CMD.quit_room(room_id, player_id)
  if player.room_id ~= 0 then
    return false
  end
  local room = rooms[player.room_id]
  room.players[player_id] = nil
  check_empty(room)
  room.cur_count = room.cur_count - 1
  return true
end

function CMD.broadcast_room_data(room_id)
  local room = rooms[room_id]
  broadcast_room_data(room)
end

function check_empty(room)
  if next(room.players) then
    return
  end
  rooms[room.room_id] = nil
  table_remove(room_list, room)
end

function broadcast_room_data(room)
  local tbl = {
    roomId = room.room_id,
    roomName = room.room_name,
    captianId = room.captain.player_id,
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
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end)
  skynet.register ".lobby"
end)
