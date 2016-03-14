local skynet = require "skynet"

Player = class() 

require "player.player_test"
require "player.player_room"

function Player:ctor()
  print("player new")
  self.player_id = skynet.call(".db", "lua", "auto_player_id")
  self.player_name = tostring(self.player_id) 
  self.room_id = 0
end

function Player:login()
  print("player login")
end

function Player:logout()
  print("player logout")
end

function Player:send(message_type, tbl)
  skynet.call(".agent"..self.player_id, "lua", "send_package", message_type, tbl) 
end

function Player:rpc(self)

end

function Player_save(self)
  --skynet.call(".db", "lua", "save_player", self)
end
