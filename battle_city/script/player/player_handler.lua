
local skynet = require "skynet"
local table_insert = table.insert

local cmd = {}

function cmd.C2S_Hello(package)
  print("client say hello"..package.a)
end

function cmd.Request_CreateRoom(package, player)
  if player.room_id ~= 0 then
    return {result = false}
  end
  local room_id = player:create_room()
  return {result = true, roomId = room_id}
end

function cmd.Request_RoomList(package, player)
  local start_idx = package.startIdx
  local end_idx = package.endIdx
  local room_list = skynet.call(".lobby", "lua", "get_room_list", start_idx, end_idx)
  local tbl = {}
  for _, room in ipairs(room_list) do
    table_insert(tbl, {
      roomId = room.room_id, 
      roomName = room.room_name,
      totalCount = room.total_count,
      currentCount = room.cur_count,
    })
  end
  --dump_tbl({roomList = tbl})
  return {roomList = tbl}
end

function cmd.Request_JoinRoom(package, player)
  local ret = player:join_room(package.roomId)
  return {result = ret}
end

function cmd.Request_QuitRoom(package, player)
  local ret = player:quit_room()
  return {result = ret}
end

function cmd.Request_PrepareGame(package, player)
  local ret = player:prepare_game(package.flag)
  return {result = ret}
end

function cmd.Request_StartGame(package, player)
  local ret = player:start_game()
  return {result = ret}
end

function cmd.C2S_BroadcastRoomData(package, player)
  if player.room_id == 0 then
    print("player not in room")
    return
  end
  skynet.call(".lobby", "lua", "broadcast_room_data", player.room_id)
end





























return cmd
