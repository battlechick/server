local skynet = require "skynet"
local cluster = require "cluster"

require "skynet.manager"

skynet.start(function()
  print("save data")
  cluster.call("login", ".login", "abort")
  --skynet.abort()
end)
