
Unit = class()

--global unique id
local auto_id = 0
function auto_guid()
    auto_id = auto_id + 1
    return auto_id
end

function Unit:ctor()
    self.guid = auto_guid()
    self.unit_type = UNIT_TYPE_ERROR
end




