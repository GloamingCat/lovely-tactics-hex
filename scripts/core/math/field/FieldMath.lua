
--[[===========================================================================

The FieldMath is a module that provides basic math operations, like 
tile-pixel coordinate convertion, neighbor shift, autotile rows, grid
navigation/iteration, etc.

=============================================================================]]

-- Imports
local Vector = require('core/math/Vector')

-- Constants
local tileW = Config.grid.tileW
local tileH = Config.grid.tileH
local tileB = Config.grid.tileB
local tileS = Config.grid.tileS

local FieldMath = {}

---------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------

function FieldMath.init()
  FieldMath.tg = (tileH + tileS) / (tileW + tileB)
  FieldMath.fullNeighborShift = FieldMath.createFullNeighborShift()
  FieldMath.neighborShift = FieldMath.createNeighborShift()
  FieldMath.vertexShift = FieldMath.createVertexShift()
end
-- A neighbor shift is a list of "offset" values in tile coordinates (x, y)
--  from the center tile to each neighbor.
-- @ret(List) the list of vectors
function FieldMath.createFullNeighborShift()
  local s = {}
  local function put(x, y)
    s[#s + 1] = Vector(x, y)
  end
  put(1, 0)
  put(1, 1)
  put(0, 1)
  put(-1, 1)
  put(-1, 0)
  put(-1, -1)
  put(0, -1)
  put(1, -1)
  return s
end
-- Gets the tile in front if the other in the given direction.
-- @param(tile : ObjectTile) Origin tile.
-- @param(dx : number) The tile x delta.
-- @param(dy : number) The tile y delta.
-- @ret(ObjectTile) The front tile if any, nil if tile is not accessible.
function FieldMath.frontTile(tile, dx, dy)
  if FieldManager.currentField:exceedsBorder(tile.x + dx, tile.y + dy) then
    return nil
  else
    local nextTile = tile.layer.grid[tile.x + dx][tile.y + dy]
    local nextTile2 = tile:getRamp(nextTile.x, nextTile.y)
    if nextTile2 then
      local tile2 = nextTile:getRamp(tile.x, tile.y)
      if tile2 and tile2 ~= tile then
        return nextTile
      else
        return nextTile2
      end
    else
      return nextTile
    end
  end
end

-----------------------------------------------------------------------------------------------
-- Field center
-----------------------------------------------------------------------------------------------

-- Gets the world center of the given field.
-- @param(field : Field)
-- @ret(number) center x
-- @ret(number) center y
function FieldMath.pixelCenter(sizeX, sizeY)
  local x1, y1 = FieldMath.tile2Pixel(1, 1, 0)
  local x2, y2 = FieldMath.tile2Pixel(sizeX, sizeY, 0)
  return (x1 + x2) / 2, (y1 + y2) / 2
end

return FieldMath
