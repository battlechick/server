local skynet = require "skynet"
local cluster = require "cluster" 
local protobuf = require "protobuf"
local config = require "config"
local json = require "cjson"
config = config.master

require "skynet.manager"
require "player.player"
local data_manager = require "data_manager.data_manager"
local bt_manager = require "behavior_tree.bt_manager"
local map_manager = require "battle.map_manager"

skynet.start(function()
  local console = skynet.newservice("console")
  skynet.newservice("debug_console",8000)

  local db = skynet.newservice("db", config.db.address, config.db.db_name)
  skynet.name(".db",db) 

  local lobby = skynet.uniqueservice("lobby")

  local agentpool = skynet.uniqueservice("agentpool", "master")
  
  cluster.open "master"

  data_manager.load_datas()

  bt_manager.export_node_doc()
  bt_manager.load_trees()
--local player = Player.new()
--  local tree = bt_manager.create_tree(1, player)
--  tree:exec()

  map_manager.load_maps()
  skynet.exit()
end)
