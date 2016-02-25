local skynet = require "skynet"
local CMD = {}

function CMD.login(account_name, account_pwd)
  print("login "..account_name)
  ret = skynet.call(".db", "lua", "query_account", account_name, account_pwd)
  print(ret)
end

function CMD.register_account(account_name, account_pwd)

end


skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end) 
end)
