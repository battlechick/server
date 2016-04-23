local skynet = require "skynet"
local cluster = require "cluster"

require "skynet.manager"

skynet.start(function()
    skynet.register ".stop"
    cluster.open "stop"
    skynet.log("stop all server")
    if pcall(function () cluster.call("master", ".master", "abort") end) then
        skynet.log("master stop!")
    else
        skynet.log("cannot stop master")
    end
    if pcall(function () cluster.call("battlemng", ".battlemng", "abort") end) then
        skynet.log("battlemng stop!")
    else
        skynet.log("cannot stop battle")
    end
    if pcall(function () cluster.call("login", ".login", "abort") end) then
        skynet.log("login stop!")
    else
        skynet.log("cannot stop login")
    end

    skynet.sleep(10)
    skynet.log("Done!")
    skynet.abort()
end)
