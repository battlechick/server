
local skynet = require "skynet"
local table_insert = table.insert

local map_manager = require "battle.map_manager"
local data_manager = require "data_manager.data_manager"

Map = class()

function Map:ctor(map_id)
    self.map_id = map_id
    self.width = 0
    self.height = 0
    self.tiles = {}
    self.guid2unit = {}
    self.proto = nil
    self.room = nil
end

function Map:init()
    local map_data = map_manager.get_map_data(self.map_id)
    skynet.log("loading map "..self.map_id)
    self.width = map_data.width
    self.height = map_data.height
   
    local i = 1
    for y=1, self.height do
        local line = {}
        for x=1, self.width do
            local unit_id = map_data.blocks[i]
            local tile = Tile.new(unit_id, x, y)
            if unit_id ~= 201 then
                self.guid2unit[tile.guid] = tile
            end
            table_insert(line, tile)
            i = i + 1 
        end
        table_insert(self.tiles, line)
    end
    self.map_data = map_data 
    self.proto = data_manager.get_data("SceneProto", self.map_id) 
    
    local tree_id = self.proto.treeId
end

Tile = class(Unit)

function Tile:ctor(unit_id, x, y)
    self.unit_id = unit_id
    self.position = {x = x, y = y, o = 0}
    self.block = map_manager.get_map_block(unit_id)
end

function Tile:get_data()
    return {
    }
end
