local skynet = require "skynet"
local datacenter = require "datacenter"
local M = {}

local protobuf = require "protobuf"

function M.load_datas()
    local dir = WORKSPACE.."data/"
    local s = io.popen("ls ".. dir)
    local fileLists = s:read("*all")
    start_pos = 1
    while true do
        _,end_pos, filename = string.find(fileLists, "([^\n\r]+.bytes)", start_pos)
        if not end_pos then 
            break
        end
        local tbl_name = string.sub(filename, 1, -7)
        local file = io.open(dir..filename, "r")
        local str = file:read("*a")
        protobuf.register_file("../battle_city/proto/"..tbl_name..".pb" )
        local data = protobuf.decode("Base."..tbl_name.."_ARRAY", str)
        file:close()
        datacenter.set("name2tbl", tbl_name, data)
        start_pos = end_pos + 1
    end
end

function M.get_data(name)
    return datacenter.get("name2tbl", name)
end

return M
