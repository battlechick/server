
CreateUnit = class(BehaviorNode)
function CreateUnit:ctor()
    self.doc = {
        nickname = "创建单位", 
        describe = "在地图上创建一个单位", 
        args_desc = {"unit_id/int/0/单位ID","x/int/0/x", "y/int/0/y"},
        classify = "复合节点",
        limit = 999,
    }
end
function CreateUnit:run()
    self.owner:create_unit(self.unit_id, self.x, self.y) 
    return true
end

