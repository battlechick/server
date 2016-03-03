
local skynet = require "skynet"
require "skynet.manager"

skynet.start(function() 
  skynet.dispatch("lua", function(_,_,command, ...)
     local f = CMD[command]
     skynet.ret(skynet.pack(f(...)))
  end)
  skynet.name ".lobby"
end)
