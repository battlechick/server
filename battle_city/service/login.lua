local skynet = require "skynet"
local cluster = require "cluster"
local config = require "config"
config = config.login
local CMD = {}

require "skynet.manager"
require "player.player"

local db

function CMD.login(account_name, account_pwd)
  local account = skynet.call(db, "lua", "query_account", account_name, account_pwd)
  if not account or account.pwd ~= account_pwd then
    print("login fail, account name:"..account_name)    
    return
  end
  local player = skynet.call(db, "lua", "query_player", account.player_id)
  if not player then
    player = player_new()
  end
  return account, player
end

function CMD.logout()
  
end

function CMD.register_account(account_name, account_pwd)
  
end

function CMD.abort()
  print("abort")
  skynet.abort()
end


skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end) 
  skynet.register ".login"
  cluster.open "login"

  db = skynet.newservice("db", config.db.address, config.db.db_name)
  
  local watchdog = skynet.newservice("watchdog")
  skynet.call(watchdog, "lua", "start", config.gate_list[1])
end)
