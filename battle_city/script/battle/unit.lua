
Unit = class()

--global unique id
local auto_id = 0
function auto_guid()
    auto_id = auto_id + 1
    return auto_id
end

function Unit:ctor()
    self.guid = auto_guid()
    self.unit_id = 0
    self.position = {x = 0, y = 0}
end

-- 单位数据,发送到客户端
function Unit:get_data()
    return {}
end


