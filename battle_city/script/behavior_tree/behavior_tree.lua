local skynet = require "skynet"
BehaviorTree = class()

function BehaviorTree:ctor(tree_data, owner)
  self.data = tree_data
  self.tree_id = tree_data.tree_id
  self.owner = owner
  self.vars = {}
  local root_name = tree_data.root.name
  if not _G[root_name] then
    print("behavior node not exist: "..root_name)
    return
  end
  self.root = _G[tree_data.root.name].new()
  self.root:init(tree_data.root, self)
  
end

function BehaviorTree:exec()
  self.root:exec()
end

function BehaviorTree:get_var(key)
  if self.vars[key] then
    return self.vars[key]
  end
  if self.owner then
    return self.owner[key]
  end
end

function BehaviorTree:set_var(key, value)
  if self.vars[key] then
    self.vars[key] = value
    return
  end
  if self.owner and self.owner[key] then
    self.owner[key] = value
  end
  self.vars[key] = value
end

