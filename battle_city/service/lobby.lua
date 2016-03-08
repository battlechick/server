
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
  room.players[player] = true
  room.cur_count = room.cur_count + 1
  return true
end

function CMD.quit_room(player)
  if player.room_id ~= 0 then
    return false
  end
  local room = rooms[player.room_id]
  room.players[player] = nil
  player.room_id = 0
  check_empty(room)
  room.cur_count = room.cur_count - 1
  return true
end

function check_empty(room)
  if next(room.players) then
    return
  end
  rooms[room.room_id] = nil
  table_remove(room_list, room)
end

skynet.start(function() 
  skynet.dispatch("lua", function(_,_,command, ...)
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end)
  skynet.register ".lobby"
end)
