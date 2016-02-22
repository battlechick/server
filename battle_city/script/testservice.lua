local skynet = require "skynet"

local CMD = {}

function CMD.test(source)
  print("test") 
end

skynet.start(function()
  print ("test service start")
  skynet.dispatch("lua", function(session, source, command, ...)
    print("call session"..session)
    local f = assert(CMD[command])
    skynet.ret(skynet.pack(f(source, ...)))
  end)
end)
