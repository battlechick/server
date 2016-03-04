local skynet = require "skynet"
require "skynet.manager"

local config = require "config" 
local gate_list = config.master.gate_list

local CMD = {}
local watchdog_list = {}

local idx = 1
function CMD.request_gate_address()
  --print("request_gate_address")
  local watchdog = watchdog_list[idx]
  for idx, watchdog in ipairs(watchdog_list) do
    local ret = skynet.call(watchdog, "lua", "is_full")
    if ret then
      local conf = gate_list[idx]
      return conf.address, conf.port
    end
  end
  return
end

skynet.start(function()
  skynet.dispatch("lua", function(_,_,command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
  end)
  skynet.register ".agentpool"
  
  for i, conf in ipairs(gate_list) do
    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", conf, "master_start")
    table.insert(watchdog_list, watchdog)
  end
end)
