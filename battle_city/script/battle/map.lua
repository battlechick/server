
local skynet = require "skynet"
local table_insert = table.insert

local map_manager = require "battle.map_manager"

Map = class()

function Map:ctor(map_id)
    skynet.log("map_id"..map_id)
    self.map_id = map_id
    self.width = 0
    self.height = 0
    self.tiles = {}
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
            local block_id = map_data.blocks[i]
            local tile = Tile.new(block_id, x, y)
            table_insert(line, tile)
            i = i + 1 
        end
        table_insert(self.tiles, line)
    end
    skynet.dump(self.tiles)
    self.map_data = map_data 
end


Tile = class(Unit)

function Tile:ctor(unit_id, x, y)
    self.unit_id = unit_id
    self.position = {x = x, y = y}
    self.block = map_manager.get_map_block(unit_id)
end

function Tile:get_data()
    return {
    }
end
