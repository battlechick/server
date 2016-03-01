local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson"

local host, db_name = "127.0.0.1", "battle_city" 

skynet.start(function()
  local db = mongo.client({host = host})[db_name]
  db.base:dropIndex("*")
  db.base:ensureIndex({table_name = 1}, {unique = true})
  local ret = db.base:findOne({table_name = "global"})
  if not ret then
    db.base:safe_insert({table_name = "global", auto_player_id = 0})
  end
  db.account:dropIndex("*")
  db.account:ensureIndex({name = 1}, {unique = true})
  db.player:dropIndex("*")
  db.player:ensureIndex({player_id = 1}, {unique = true})
end)
