local skynet = require "skynet"
-- 常用节点
--
Root = class(BehaviorNode)
function Root:ctor()
    self.doc = {
        nickname = "根节点", 
        describe = "AI的根节点,执行所有子节点", 
        args_desc = {"rate/int/100/执行频率(毫秒次)"},
        classify = "复合节点",
        limit = 999,
        style = "green",
    }
end
function Root:run()
    skynet.log("Root:run")
    for _, child in ipairs(self.children) do
        child:exec()
    end
    return true
end


Sequence = class(BehaviorNode)
function Sequence:ctor()
    self.doc = {
        nickname = "顺序执行",
        describe = "执行所有子节点直到返回false",
        classify = "复合节点",
        limit = 999,
        style = "blue",
    }
end
function Sequence:run()
    skynet.log("Sequence:run")
    for _, child in ipairs(self.children) do
        if not child:exec() then
            return false
        end
    end
    return true
end

Selector = class(BehaviorNode)
function Selector:ctor()
    self.doc = {
        nickname = "选择执行",
        describe = "执行所有子节点直到返回true",
        classify = "复合节点",
        limit = 999,
        style = "blue",
    }
end
function Selector:run()
    for _, child in ipairs(self.children) do
        if child:exec() then
            return true
        end
    end
    return false
end

LimitExec = class(BehaviorNode)
function LimitExec:ctor()
    self.doc = {
        nickname = "限制执行",
        describe = "子节点最多执行limit次，如果超过了次数，则返回false。\
        如果子节点为空，则返回false；否则，执行并返回子节点的值。",
        args_desc = {"limit/int/1/执行次数"},
        classify = "复合节点",
        limit = 999,
        style = "red",
    }
end
function LimitExec:run()
    if self.limit < 1 then
        return false
    end
    local count = self:get_var(self.node_id) or 0
    if count >= self.limit then
        return false
    end
    self:set_var(self.node_id, count+1)
    for _, child in ipairs(self.children) do
        if child:exec() then
            return true
        end
    end
    return true
end

