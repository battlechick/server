local skynet = require "skynet"
local CMD = {}

function CMD.login(account_name, account_pwd)
  ret = skynet.call(".db", "lua", "query_account", account_name, account_pwd)
  if not ret or ret.pwd ~= account_pwd then
    print("login fail, account name:"..account_name)    
    return
  end
end

function CMD.register_account(account_name, account_pwd)

end


skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end) 
end)
