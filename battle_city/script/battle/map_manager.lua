local skynet = require "skynet"
local json = require "cjson"
local datacenter = require "datacenter"

local M = {}

function M.load_maps()
    skynet.log("load map")
    load_map_block()
    load_unit_collider()
    local dir = WORKSPACE.."data/Map/"
    local s = io.popen("ls ".. dir)
    local fileLists = s:read("*all")
    start_pos = 1
    while true do
        local _,end_pos, filename = string.find(fileLists, "([^\n\r]+.txt)", start_pos)
        if not end_pos then 
            break
        end
        local _,_, id_str = string.find(filename, "(%d+)")
        local map_id = tonumber(id_str)
        if map_id then
            local file = io.open(dir..filename, "r")
            local str = file:read("*a")
            local data = json.decode(str)
            file:close()
            skynet.log("load map data: "..filename)
            datacenter.set("id2map_data", tonumber(map_id), data)
        end

        start_pos = end_pos + 1
    end
end

function load_map_block()
    local file = io.open(WORKSPACE.."data/Map/MapBlock.txt", "r")
    local str = file:read("*a")
    file:close()
    local list = json.decode(str)
    local dict = {}
    for _, block in pairs(list) do
        dict[block.unitId] = block
    end
    datacenter.set("id2block", dict)
end

function load_unit_collider()
    local file = io.open(WORKSPACE.."data/Map/UnitCollider.txt", "r")
    local str = file:read("*a")
    file:close()
    local list = json.decode(str)
    local dict = {}
    for _, collider in pairs(list) do
        dict[collider.unitId] = collider
    end
    datacenter.set("id2collider", dict)
end

function M.get_map_data(map_id)
    return datacenter.get("id2map_data", map_id)
end

function M.get_map_block(block_id)
    return datacenter.set("id2block", block_id)
end

function M.get_collider(unit_id)
    return datacenter.get("id2collider", unit_id)
end

return M
