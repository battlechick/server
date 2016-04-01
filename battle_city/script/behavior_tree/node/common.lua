-- 常用节点

Root = class(BehaviorNode)
function Root:ctor()
  self.doc = {
    nickname = "根节点", 
    describe = "AI的根节点,执行所有子节点", 
    args_desc = {"rate/int/100/执行频率(毫秒次)"},
    classify = "复合节点",
    limit = 999,
  }
end
function Root:run()
  for _, child in ipairs(self.children) do
    child:run()
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
  }
end
function Sequence:run()
  for _, child in ipairs(self.children) do
    if not child:run() then
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
  }
end
function Selector:run()
  for _, child in ipairs(self.children) do
    if child:run() then
      return true
    end
  end
  return false
end


