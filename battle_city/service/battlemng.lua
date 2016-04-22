local skynet = require "skynet"
local cluster = require "cluster"
local config = require "config"
local config = config.battle

require "skynet.manager"
local data_manager = require "data_manager.data_manager"
local bt_manager = require "behavior_tree.bt_manager"
local map_manager = require "battle.map_manager"

local cmd = {}

function cmd.create(room)
    local address, port = skynet.call(".agentpool", "lua", "request_gate_address")
    if not address or not port then
        return 0
    end
    local battle = skynet.newservice("battle")
    skynet.call(battle, "lua", "init", room)
    return battle, address, port
end

function cmd.abort()
    skynet.log("battle server will be stop")
    skynet.fork(function()
        skynet.sleep(1) 
        skynet.abort()
    end)
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = cmd[command]
        skynet.ret(skynet.pack(f(...)))
    end)

    data_manager.load_datas()
    bt_manager.export_node_doc()
    bt_manager.load_trees()
    map_manager.load_maps()


    skynet.register ".battlemng"
    cluster.open "battlemng"

    local agentpool = skynet.uniqueservice("agentpool", "battle")

end)
