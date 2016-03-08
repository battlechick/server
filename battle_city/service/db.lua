local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson"

local host, db_name = ... 

function collection(name)
  local db = mongo.client({host = host})
  return db[db_name][name]
end

function get_global_data(key)
  local col = collection("base")
  local tbl = col:findOne({table_name = "global"})
  return tbl[key]
end

function save_global_data(key, value)
  local col = collection("base")
  local update_doc = {}
  update_doc[key] = value
  return col:findAndModify({query = {table_name = "global"}, update = {["$set"] = update_doc}})
end

local CMD = {}
function CMD.query_account(account_name, account_pwd)
  local col = collection("account")
  local ret = col:findOne({name = account_name})
  if not ret then
    col:safe_insert({name = account_name, pwd = account_pwd})
    ret = col:findOne({name = account_name})
  end
  return ret
end

function CMD.save_account(account)
  local col = collection("account")
  return col:findAndModify({query = {name = account.name}, update = account})
end

function CMD.query_player(player_id)
  local col = collection("player")  
  return col:findOne({player_id = player_id})
end

function CMD.save_player(player)
  local col = collection("player")
  return col:findAndModify({query = {player_id = player.player_id}, update = player})
end

function CMD.auto_player_id()
  local auto_id = get_global_data("auto_player_id") or 0
  auto_id = auto_id + 1
  save_global_data("auto_player_id", auto_id)
  return auto_id
end

skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
  end)
end)
