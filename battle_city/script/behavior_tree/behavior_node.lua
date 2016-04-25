local skynet = require "skynet"
-- 行为树节点基类
--
BehaviorNode = class()
function BehaviorNode:ctor()
    --节点文档说明，导出配置
    self.doc = {
        name = "",          -- 
        nickname = "",      -- 节点名称(XX节点)
        describe = "",      -- 节点描述(bababa...)
        classify = "",      -- 节点分类(行为节点)
        args_desc = {},     -- 输入(a/常量/int/0, aa/变量/key/)
        limit = 0,          -- 子节点限制
        style = "default",  -- 节点样式
    }
end
function BehaviorNode:init(node_data, tree)
    self.tree = tree
    if tree then
        self.owner = tree.owner
    end
    self.data = node_data
    self.node_id = node_data.nodeId
    self.children = {}
    for _, child_data in ipairs(node_data.children) do
        local node_name = child_data.name
        if not _G[node_name] then
            print("behavior node not exist: "..node_name)
            return
        end
        local child = _G[node_name].new()
        child:init(child_data, tree)
        table.insert(self.children, child)
    end
end
function BehaviorNode:exec()
    self:before_run()
    self:run()
    self:after_run()
end
function BehaviorNode:before_run()
    for i, desc in ipairs(self.doc.args_desc) do
        local arr = string.split(desc, '/')
        local key = arr[1]
        local t = arr[2]
        local arg = self.data.args[i]
        local var_flag =  self.data.varFlags[i]
        local value = nil
        if var_flag then
            value = self.tree:get_var(arg)
        else
            if t == "int" or t == "float" then
                value = tonumber(arg)
            else
                value = arg
            end
        end
        self[key] = value
        skynet.log("before_run key:"..key.." value:"..tostring(value).." desc:"..desc)
        skynet.dump(self.data)
    end
end
function BehaviorNode:run()
    return true
end
function BehaviorNode:after_run()
    for i , desc in ipairs(self.doc.args_desc) do
        local arr = string.split(desc, '/')
        local key = arr[1]
        local t = arr[3]
        local var_flag = self.data[i]
        local arg =  self.data[i]
        local value = self[key]

        if var_flag then
            self.tree:set_var(arg, value)
        end

    end
end
function BehaviorNode:set_var(key, value)
    self.tree:set_var(key, value)
end
function BehaviorNode:get_var(key)
    return self.tree:get_var(key)
end

require "behavior_tree/node/common"
require "behavior_tree/node/map"
require "behavior_tree/node/ai"

