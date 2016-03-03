local skynet = require "skynet"
local cluster = require "cluster" 
local sprotoloader = require "sprotoloader"
local protobuf = require "protobuf"
local config = require "config"
config = config.master

local max_client = 64

require "skynet.manager"

function test()
  protobuf.register_file "proto/msg.pb"
  
  data = {b =  666}
  
  buffer = protobuf.encode("hello",data)
  print("encode:"..buffer)

  decode = protobuf.decode("hello", buffer)
  print("decode"..decode.b)

end

skynet.start(function()
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)

  local db = skynet.newservice("db", config.db.address, config.db.db_name)
  skynet.name(".db",db) 

  skynet.uniqueservice("agentpool", config.gate_list)
  
  cluster.open "master"
	skynet.exit()
end)
