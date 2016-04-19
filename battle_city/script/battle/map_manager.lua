
local json = require "cjson"

local M = {}

local id2map_data = {}
function M.load_maps()
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
            print("load map data: "..filename)
            id2map_data[tonumber(map_id)] = data
        end

        start_pos = end_pos + 1
    end
end

local id2block = {}
function load_map_block()
    local file = io.open(WORKSPACE.."data/Map/MapBlock.txt", "r")
    local str = file:read("*a")
    id2block = json.decode(str)
    file:close()
end

function M.get_map_data(map_id)
    return id2map_data[map_id]
end

function M.get_map_block(block_id)
    return id2block[block_id]
end

return M
