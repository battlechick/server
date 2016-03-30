
BehaviorNode = class()
--[[
--节点文档说明，导出配置
  BehaviorNode.doc = {
  name = ""           -- 
  nickname = "",      -- 节点名称(XX节点)
  describe = "",      -- 节点描述(bababa...)
  classify = "",      -- 节点分类(行为节点)
  inputs = "",        -- 输入(a/int/0/常量, aa/key//变量)
  outputs = "",       -- 输出(a///变量)
  limit = 0,          -- 子节点限制
}]]
function BehaviorNode:ctor(tree_id, node_id, node_data)
  self.tree_id = tree_id
  self.node_id = node_id
  self.children = {}
end
function BehaviorNode:run()
  return true
end


AiRoot = class(BehaviorNode, "AiRoot")
AiRoot.doc = {
  nickname = "根节点", 
  describe = "AI的根节点,执行所有子节点", 
  inputs = "rate/int/100/执行频率(毫秒次)",
  classify = "复合节点",
  limit = 999,
}
function AiRoot:run()
  for _, child in ipairs(self.children) do
    child:run()
  end
  return true
end


Sequence = class(BehaviorNode, "Sequence")
Sequence.doc = {
  nickname = "顺序执行",
  describe = "执行所有子节点直到返回false",
  classify = "复合节点",
  limit = 999,
}
function Sequence:run()
  for _, child in ipairs(self.children) do
    if not child:run() then
      return false
    end
  end
  return true
end

Selector = class(BehaviorNode, "Selector")
Selector.doc = {
  nickname = "选择执行",
  describe = "执行所有子节点直到返回true",
  classify = "复合节点",
  limit = 999,
}
function Selector:run()
  for _, child in ipairs(self.children) do
    if child:run() then
      return true
    end
  end
  return false
end


