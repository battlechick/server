local skynet = require "skynet"

function Player:create_room()
  if self.room_id ~= 0 then
    return false
  end
  
  local room_id = skynet.call(".lobby", "lua", "create_room", self.player_name.."的房间", self.player_id)
  if room_id  == 0 then
    return false
  end

  self:join_room(room_id)
  self:prepare_game(true)
  skynet.call(".lobby", "lua", "broadcast_room_data", room_id)
  return true
end

function Player:join_room(room_id)
  if self.room_id ~= 0 then
    return false
  end
  local ret = skynet.call(".lobby", "lua", "join_room", room_id, self.player_id, self.player_name)
  if ret then
    self.room_id = room_id
  else
    print("player cannot join room")
  end
  print("player"..self.player_id.." join room"..room_id)
  return ret
end

function Player:quit_room()
  if self.room_id == 0 then
    return false
  end
  local ret = skynet.call(".lobby", "lua", "quit_room", self.room_id, self.player_id)
  if ret then
     self.room_id = 0
  end
  return ret
end

function Player:prepare_game(flag)
  if self.room_id == 0 then
    return false
  end
  return skynet.call(".lobby", "lua", "prepare_game", self.room_id, self.player_id, flag)
end

function Player:start_game()
  if self.room_id == 0 then
    return false
  end
  return skynet.call(".lobby", "lua", "start_game", self.room_id, self.player_id)
end

