
--[[===============================================================================================

FieldMath
---------------------------------------------------------------------------------------------------
A module that provides basic field math operations, like tile-pixel coordinate convertion, neighbor 
shift, autotile rows, grid navigation/iteration, etc.
This module implements only the common operations. The abstract methods must be implemented by
specific field math modules for each grid type.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')

-- Constants
local tileW = Config.grid.tileW
local tileH = Config.grid.tileH
local tileB = Config.grid.tileB
local tileS = Config.grid.tileS

local FieldMath = {}

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates static fields.
function FieldMath.init()
  FieldMath.fullNeighborShift = FieldMath.createFullNeighborShift()
  FieldMath.neighborShift = FieldMath.createNeighborShift()
  FieldMath.vertexShift = FieldMath.createVertexShift()
  -- Angles
  FieldMath.tg = (tileH + tileS) / (tileW + tileB)
  local diag = 45 * FieldMath.tg
  local dir = {0, diag, 90, 180 - diag, 180, 180 + diag, 270, 360 - diag}
  FieldMath.dir = dir
  FieldMath.int = {dir[2] / 2, (dir[2] + dir[3]) / 2, (dir[3] + dir[4]) / 2, 
    (dir[4] + dir[5]) / 2, (dir[5] + dir[6]) / 2, (dir[6] + dir[7]) / 2,
    (dir[7] + dir[8]) / 2, (dir[8] + 360) / 2}
  -- Masks
  FieldMath.neighborMask = { grid = FieldMath.radiusMask(1, -1, 1),
    centerH = 1, centerX = 1, centerY = 1 }
  FieldMath.centerMask = { grid = {{{true}}},
    centerH = 1, centerX = 1, centerY = 1 }
  FieldMath.emptyMask = { grid = {{{false}}},
    centerH = 1, centerX = 1, centerY = 1 }
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

---------------------------------------------------------------------------------------------------
-- Neighbor
---------------------------------------------------------------------------------------------------

-- Verifies the tile coordinate differences are one of the neighbor shifts.
-- @param(dx : number) Difference in x between the tiles.
-- @param(dy : number) Difference in y between the tiles.
function FieldMath.isNeighbor(dx, dy)
  for i = 1, #FieldMath.neighborShift do
    local n = FieldMath.neighborShift[i]
    if n.x == dx and n.y == dy then
      return true
    end
  end
  return false
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

---------------------------------------------------------------------------------------------------
-- Field center
---------------------------------------------------------------------------------------------------

-- Gets the world center of the given field.
-- @param(field : Field)
-- @ret(number) center x
-- @ret(number) center y
function FieldMath.pixelCenter(sizeX, sizeY)
  local x1, y1 = FieldMath.tile2Pixel(1, 1, 0)
  local x2, y2 = FieldMath.tile2Pixel(sizeX, sizeY, 0)
  return (x1 + x2) / 2, (y1 + y2) / 2
end

---------------------------------------------------------------------------------------------------
-- Direction-angle convertion
---------------------------------------------------------------------------------------------------

local mod = math.mod
-- Converts row [0, 7] to float angle.
-- @param(row : number) the rown from 0 to 7
-- @ret(number) the angle in radians
function FieldMath.row2Angle(row)
  return FieldMath.dir[row + 1]
end
-- Converts float angle to row [0, 7].
-- @param(angle : number) the angle in radians
-- @ret(number) the row from 0 to 7
function FieldMath.angle2Row(angle)
  angle = mod(angle, 360)
  for i = 1, 8 do
    if angle < FieldMath.int[i] then
      return i - 1
    end
  end
  return 0
end

---------------------------------------------------------------------------------------------------
-- Mask
---------------------------------------------------------------------------------------------------

-- Constructor a mask where the tiles in the given radius are true.
-- @param(r : number) Radius. 0 means only the center tile.
-- @param(minh : number) Minimum height distance from the center tile (usually negative).
-- @param(maxh : number) Maximum height distance from the center tile (usually positive).
-- @ret(table) The mask grid.
function FieldMath.radiusMask(r, minh, maxh)
  local grid = {}
  for h = 1, maxh - minh + 1 do
    grid[h] = {}
    for i = 1, r * 2 + 1 do
      grid[h][i] = {}
      for j = 1, r * 2 + 1 do
        grid[h][i][j] = false
      end
    end
  end
  for i, j in FieldMath.radiusIterator(r, r + 1, r + 1,
      r * 2 + 1, r * 2 + 1) do
    for h = 1, maxh - minh + 1 do
      grid[h][i][j] = true
    end
  end
  return grid
end
-- Iterates over the tiles contained in the mask.
-- @param(mask : table) The mask table, with grid and center coordinates.
-- @param(x0 : number) X of the center tile in the field.
-- @param(y0 : number) Y of the center tile in the field.
-- @param(h0 : number) Height of the center tile in the field.
-- @ret(function) Iterator that return the coordinates of the tiles contained in the mask.
function FieldMath.maskIterator(mask, x0, y0, h0)
  local k, i, j = 1, 1, 1
  return function()
    while k <= #mask.grid do
      while i <= #mask.grid[k] do
        while j <= #mask.grid[k][i] do
          if mask.grid[k][i][j] then
            local h = k - mask.centerH + h0
            local x = i - mask.centerX + x0
            local y = j - mask.centerY + y0  
            j = j + 1
            return x, y, h
          end
          j = j + 1
        end
        i = i + 1
        j = 1
      end
      k = k + 1
      i = 1
    end
  end
end

return FieldMath