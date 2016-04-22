local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

-- 一些全局变量 
WORKSPACE = "../battle_city/"

UNIT_TYPE_ERROR = 0
UNIT_TYPE_TILE = 1
UNIT_TYPE_PLAYER = 2
UNIT_TYPE_TANK = 3
UNIT_TYPE_BULLET = 4


local skynet = require "skynet"
skynet.log = skynet.error

function _dump_tbl(root)
    if type(root) ~= "table" then
        return "not table"
    end

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
    return _dump(root, "","")
end
skynet.dump = function(root)
    skynet.log("\n".._dump_tbl(root))
end

local _class={}

function class(super, class_name)
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

function bytes_to_int(str,endian,signed) -- use length of string to determine 8,16,32,64 bits
    local t={str:byte(1,-1)}
    if endian=="big" then --reverse bytes
        local tt={}
        for k=1,#t do
            tt[#t-k+1]=t[k]
        end
        t=tt
    end
    local n=0
    for k=1,#t do
        n=n+t[k]*2^((k-1)*8)
    end
    if signed then
        n = (n > 2^(#t-1) -1) and (n - 2^#t) or n -- if last bit set, negative.
    end
    return n
end

function int_to_bytes(num,endian,signed)
    if num<0 and not signed then num=-num print"warning, dropping sign from number converting to unsigned" end
    local res={}
    local n = math.ceil(select(2,math.frexp(num))/8) -- number of bytes to be used.
    if signed and num < 0 then
        num = num + 2^n
    end
    for k=n,1,-1 do -- 256 = 2^8 bits per char.
        local mul=2^(8*(k-1))
        res[k]=math.floor(num/mul)
        num=num-res[k]*mul
    end
    assert(num==0)
    if endian == "big" then
        local t={}
        for k=1,n do
            t[k]=res[n-k+1]
        end
        res=t
    end
    return string.char(unpack(res))
end

-- 字符串分割
function string.split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

