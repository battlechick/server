local skynet = require "skynet"

function player_create_room(player)
  if player.room_id ~= 0 then
    return false
  end
  
  local room_id = skynet.call(".lobby", "lua", "create_room", player)
  print("player"..player.player_id.." create room"..room_id)
  if room_id  == 0 then
    return false
  end

  player_join_room(player, room_id)
  return true
end

function player_join_room(player, room_id)
  if player.room_id ~= 0 then
    return false
  end
  local ret = skynet.call(".lobby", "lua", "join_room", room_id, player)
  if ret then
    player.room_id = room_id
  end
  print("player"..player.player_id.." join room"..room_id)
  return ret
end

function player_quit_room(player)
  if player.room_id == 0 then
    return false
  end
  local ret = skynet.call(".lobby", "lua", "quit_room", player.room_id, player.player_id)
  if ret then
     player.room_id = 0
  end
  return ret
end

function player_prepare_game(player)
  if player.room_id == 0 then
    return false
  end
  return skynet.call(".lobby", "lua", "prepare", player.room_id, player.player_id)
end

function player_start_game(player)
  if player.room_id == 0 then
    return false
  end
  return skynet.call(".lobby", "lua", "start", player.room_id, player.player_id)
end

