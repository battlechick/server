local skynet = require "skynet"
local cluster = require "cluster"
local config = require "config"
local config = config.battle

require "skynet.manager"

local cmd = {}

function cmd.create(room)
  local address, port = skynet.call(".agentpool", "lua", "request_gate_address")
  if not address or not port then
    return 0
  end
  local battle = skynet.newservice("battle")
  skynet.call(battle, "lua", "init", room)
  return battle, address, port
end

skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
    local f = cmd[command]
    skynet.ret(skynet.pack(f(...)))
  end)
  skynet.register ".battlemng"

  local agentpool = skynet.uniqueservice("agentpool", "battle")

  cluster.open "battle"
end)
