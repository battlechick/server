
local M = {}

local protobuf = require "protobuf"

local name2tbl = {}
function M.load_datas()
    local dir = WORKSPACE.."data/"
    local s = io.popen("ls ".. dir)
    local fileLists = s:read("*all")
    start_pos = 1
    while true do
        _,end_pos, filename = string.find(fileLists, "([^\n\r]+.data)", start_pos)
        if not end_pos then 
            break
        end
        local tbl_name = string.sub(filename, 1, -6)
        local file = io.open(dir..filename, "r")
        local str = file:read("*a")
        protobuf.register_file("../battle_city/proto/"..tbl_name..".pb" )
        local data = protobuf.decode("Base.UnitProto_ARRAY", str)
        dump_tbl(data)
        name2tbl[tbl_name] = data
        start_pos = end_pos + 1
    end
end

function M.get_data(name)
    return name2tbl[name]
end

return M
