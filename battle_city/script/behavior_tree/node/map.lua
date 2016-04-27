
CreateUnit = class(BehaviorNode)
function CreateUnit:ctor()
    self.doc = {
        nickname = "创建单位", 
        describe = "在地图上创建一个单位", 
        args_desc = {"unit_id/int/0/单位ID","x/int/0/x", "y/int/0/y"},
        classify = "地图节点",
        limit = 999,
    }
end
function CreateUnit:run()
    self.owner:create_unit(self.unit_id, self.x, self.y) 
    return true
end

CreateHero = class(BehaviorNode)
function CreateHero:ctor()
    self.doc = {
        nickname = "创建英雄单位", 
        describe = "在地图上创建一个英雄单位", 
        args_desc = {"unit_id/int/0/单位ID","x/int/0/x", "y/int/0/y", "idx/int/0/玩家编号"},
        classify = "地图节点",
        limit = 999,
    }
end
function CreateHero:run()
    self.owner:create_hero(self.unit_id, self.x, self.y, self.idx) 
    return true
end

