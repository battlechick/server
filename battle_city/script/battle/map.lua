
local table_insert = table.insert

local map_manager = "battle.map_manager"

Map = class()

function Map:ctor()
    self.map_data
    self.width = 0
    self.height = 0
    self.tiles = {}
end

function Map:init(map_data)
    self.width = map_data.width
    self.height = map_data.height
    for y, line in ipairs(map_data.blocks) do
        local tbl = {}
        for x, block_id in ipairs(line) do
            local tile = Tile.new(block_id, x, y)
            table_insert(tbl, tile)
        end
    end
end


Tile = class(Unit)

function Tile:ctor(block_id, x, y)
    self.unit_type = UNIT_TYPE_TILE
    self.position = {x = x, y = y}
    self.block = map_manager.get_map_block(block_id)
end

function Tile:get_data()
    return {
        block_id = self.block.id
    }
end
