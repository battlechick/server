local skynet = require "skynet"
require "skynet.manager"

local config = require "config" 
local service_name = ...
local gate_list = config[service_name].gate_list 
local agent_start_func = service_name .. "_start"

local cmd = {}
local watchdog_list = {}

local idx = 1
function cmd.request_gate_address()
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
    local f = cmd[command]
    skynet.ret(skynet.pack(f(...)))
  end)
  skynet.register ".agentpool"
  
  for i, conf in ipairs(gate_list) do
    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", conf, agent_start_func)
    table.insert(watchdog_list, watchdog)
  end
end)
