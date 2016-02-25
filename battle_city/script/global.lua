local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

function dump_tbl(root)
  local cache = {  [root] = "." }
  local function _dump(t,space,name)
    local temp = {}
    for k,v in pairs(t) do
      local key = tostring(k)
      if cache[v] then
        tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
      elseif type(v) == "table" then
        local new_key = name .. "." .. key
        cache[v] = new_key
        tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
      else
        tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
      end
    end
    return tconcat(temp,"\n"..space)
  end
  print(_dump(root, "",""))
end


local _class={}
 
function class(super)
  local class_type={}
  class_type.ctor=false
  class_type.super=super
  class_type.new=function(...) 
    local obj={}
    do
      local create
      create = function(c,...)
        if c.super then
          create(c.super,...)
        end
        if c.ctor then
          c.ctor(obj,...)
        end
      end

      create(class_type,...)
    end
    setmetatable(obj,{ __index=_class[class_type] })
    return obj
  end
  local vtbl={}
  _class[class_type]=vtbl

  setmetatable(class_type,{__newindex=function(t,k,v)
    vtbl[k]=v
  end})

  if super then
    setmetatable(vtbl,{__index=function(t,k)
      local ret=_class[super][k]
      vtbl[k]=ret
      return ret
    end})
  end

  return class_type
end

