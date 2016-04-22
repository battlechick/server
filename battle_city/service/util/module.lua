local skynet = require "skynet"

local modules = {}
local cmd = {}
function cmd.get_module(module_name)
    return modules[module_name]
end
