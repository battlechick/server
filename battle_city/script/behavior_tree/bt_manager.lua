
require "behavior_tree.behavior_node"
require "behavior_tree.behavior_tree"

local M = {}
-- 导出节点说明配置
function M.export_node_doc()
  local data = "["
  
  for name, obj in pairs(CLASS_SET) do
    local doc = obj.doc
    if doc then
      local function format(key, value)
        if type(value) == "string" then
          return "\""..key.."\":\""..tostring(value).."\""
        else
          return "\""..key.."\":"..tostring(value)
        end
      end
      nickname = doc.nickname or "" 
      describe = doc.describe or ""
      classify = doc.classify or ""
      inputs = doc.inputs or ""
      outputs = doc.outputs or ""
      limit = doc.limit or 0
      data = data .. "{" .. table.concat({format("name", name), 
          format("nickname", nickname),
          format("describe", describe),
          format("classify", classify),
          format("inputs", inputs), 
          format("outputs", outputs), 
          format("limit", limit)}, ',').. "},\n"
    end
  end

  if data ~= "[" then
    data = string.sub(data, 1,-3)
    data = data .. "]"
  end
  print(data)

  local file = io.open(WORKSPACE.."data/btree/node_doc.txt", "w")
  file:write(data)

  local json = require "cjson"
  dump_tbl(json.decode(data))


end

return M
