local skynet = require "skynet"
local cluster = require "cluster" 
local protobuf = require "protobuf"
local config = require "config"
config = config.master

require "skynet.manager"

skynet.start(function()
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)

  local db = skynet.newservice("db", config.db.address, config.db.db_name)
  skynet.name(".db",db) 

  local lobby = skynet.uniqueservice("lobby")

  local agentpool = skynet.uniqueservice("agentpool", "master")
  

  cluster.open "master"
	skynet.exit()
end)
