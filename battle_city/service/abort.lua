local skynet = require "skynet"

require "skynet.manager"

skynet.start(function()
  print("save data")
  skynet.abort()
end)
