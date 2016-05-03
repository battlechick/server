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

require "common.quadtree"
function test_quadtree()
    local quadtree = QuadTree.new(0, 0, 1000, 1000)
    quadtree:subdivide()
    quadtree:subdivide()
    quadtree:subdivide()

    obj1 = {
        name   = "obj1",
        x      = 10,
        y      = 10,
        prev_x = 10,
        prev_y = 10,
        width  = 50,
        height = 50
    }
    quadtree:addObject(obj1)

    obj2 = {
        name   = "obj2",
        x      = 100,
        y      = 10,
        prev_x = 100,
        prev_y = 10,
        width  = 50,
        height = 50
    }
    quadtree:addObject(obj2)

    obj3 = {
        name   = "obj3",
        x      = 100,
        y      = 10,
        prev_x = 100,
        prev_y = 10,
        width  = 700,
        height = 50
    }
    quadtree:addObject(obj3)

    obj4 = {
        name   = "obj4",
        x      = 700,
        y      = 10,
        prev_x = 700,
        prev_y = 10,
        width  = 50,
        height = 50
    }
    quadtree:addObject(obj4)

    print("Should be objects 2,3")
    near = quadtree:getCollidableObjects(obj1, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,3")
    near = quadtree:getCollidableObjects(obj2, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,2,4")
    near = quadtree:getCollidableObjects(obj3, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 3")
    near = quadtree:getCollidableObjects(obj4, false)
    for i,j in pairs(near) do print(j.name) end

    obj1.prev_x, obj1.prev_y = obj1.x, obj1.y
    obj1.x     , obj1.y      = 900   , 200
    quadtree:updateObject(obj1)

    print("Should be objects 3,4")
    near = quadtree:getCollidableObjects(obj1, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 3")
    near = quadtree:getCollidableObjects(obj2, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,2,4")
    near = quadtree:getCollidableObjects(obj3, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 1,3")
    near = quadtree:getCollidableObjects(obj4, false)
    for i,j in pairs(near) do print(j.name) end
    
    skynet.dump(quadtree)
end

