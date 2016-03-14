local skynet = require "skynet"

local room
local players

local cmd = {}

function cmd.init(_room)
  room = _room
  players = room.players

  for player_id, player in pairs(players) do
    player.loaded = 0
  end
end

function cmd.join_battle(player_id)
  local player = players[player_id]
  if not player then
    return false
  end
  player.loaded = 100

  if check_load_finished() then
    start()
  end
  return true
end

function check_load_finished()
  for _, player in pairs(players) do
    if player.loaded < 100 then
      return false
    end
  end
  return true
end

function start()
  broadcast("S2C_StartBattle", {})
end

function broadcast(message_type, tbl)
   for player_id, _ in pairs(players) do
      skynet.call(".agent"..player_id, "lua", "send_package", message_type, tbl)
   end
end

skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
    local f = cmd[command]
    skynet.ret(skynet.pack(f(...)))
  end)
end)
