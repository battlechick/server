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

    test_quadtree()
    skynet.sleep(10)
    skynet.log("Done!")
    skynet.abort()
end)

local Quadtree = require "common.quadtree"
function test_quadtree()
   
    quadtree = Quadtree.create(0, 0, 640, 480)
    quadtree:insert({left = 64, top = 64, width = 128, height = 128})
    local objects = quadtree:collisions({left = 32, top = 32, width = 128, height = 128})
    --skynet.dump(quadtree)
    skynet.dump(objects)
end

