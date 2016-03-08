local skynet = require "skynet"

function player_create_room(player)
  if player.room_id ~= 0 then
    return false
  end
  
  local room_id = skynet.call(".lobby", "lua", "create_room")
  if room_id  == 0 then
    return false
  end

  player.room_id = room_id
  player_join_room(player, room_id)
  return true
end

function player_join_room(player, room_id)
  local ret = skynet.call(".lobby", "lua", "join_room", room_id, player)
  return ret
end

function player_quit_room(player)
  local ret = skynet.call(".lobby", "lua", "quit_room", player)
end
