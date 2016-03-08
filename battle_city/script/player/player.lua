local skynet = require "skynet"
require "player.player_test"
require "player.player_room"

function player_new()
  print("player new")
  local self = {}
  self.player_id = skynet.call(".db", "lua", "auto_player_id")
  self.player_name = tostring(self.player_id) 
  self.room_id = 0
  return self
end

function player_login(self)
  print("player login")
end

function player_logout(self)
  print("player logout")
end

function player_send(self, message_type, tbl)
  assert(self.send_func)
  self.send_func(message_type, tbl)
end

function player_rpc(self)

end

function player_save(self)
  --skynet.call(".db", "lua", "save_player", self)
end
