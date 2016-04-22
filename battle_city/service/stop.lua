local skynet = require "skynet"
local cluster = require "cluster"

require "skynet.manager"

skynet.start(function()
    skynet.register ".stop"
    cluster.open "stop"
    print("stop all server")
    if pcall(function () cluster.call("master", ".master", "abort") end) then
        print("master stop!")
    else
        print("cannot stop master")
    end
    if pcall(function () cluster.call("battlemng", ".battlemng", "abort") end) then
        print("battlemng stop!")
    else
        print("cannot stop battle")
    end
    if pcall(function () cluster.call("login", ".login", "abort") end) then
        print("login stop!")
    else
        print("cannot stop login")
    end

    skynet.sleep(10)
    print("Done!")
    skynet.abort()
end)
