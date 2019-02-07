
--[[===============================================================================================

Obstacle
---------------------------------------------------------------------------------------------------
An Obstacle is a static object stored in the tile. 
It may be passable or not, and have an image or not.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Object = require('core/objects/Object')

-- Alias
local tile2Pixel = math.field.tile2Pixel

-- Constants
local neighborShift = math.field.fullNeighborShift

local Obstacle = class(Object)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(data : table) the obstacle's data from tileset file
-- @param(tileData : table) the data about ramp and collision
-- @param(initTile : ObjectTile) the object this tile is in
-- @param(group : table) the group this obstacle is part of
function Obstacle:init(data, tileData, initTile, group)
  local x, y, z = tile2Pixel(initTile:coordinates())
  Object.init(self, data, Vector(x, y, z))
  self.type = 'obstacle'
  self.group = group
  self.sprite = group.sprite
  self.collisionHeight = tileData.height
  self.ramp = tileData.ramp
  initTile.obstacleList:add(self)
  self:initNeighbors(tileData.neighbors)
  self:addToTiles()
end
-- Creates neighborhood.
-- @param(neighbors : table) the table of booleans indicating passability
function Obstacle:initNeighbors(neighbors)
  self.neighbors = {}
  local function addNeighbor(x, y, i)
    if self.neighbors[x] == nil then
      self.neighbors[x] = {}
    end
    self.neighbors[x][y] = neighbors[i]
  end
  for i, n in ipairs(neighborShift) do
    addNeighbor(n.x, n.y, i)
  end
  addNeighbor(0, 0, #neighborShift + 1)
end

---------------------------------------------------------------------------------------------------
-- Collision
---------------------------------------------------------------------------------------------------

-- Checks if the object is passable from the given direction.
-- @param(dx : number) the direction in axis x
-- @param(dy : number) the direction in axis y
-- @param(obj : Object) the object which is trying to pass through this obstacle (optional)
function Obstacle:isPassable(dx, dy, obj)
  if self == obj then
    return true
  end
  if self.neighbors[dx] == nil then
    return false
  end
  return self.neighbors[dx][dy] == true
end
-- Overrides Object:getHeight.
function Obstacle:getHeight(x, y)
  return self.collisionHeight
end

---------------------------------------------------------------------------------------------------
-- Tiles
---------------------------------------------------------------------------------------------------

-- Overrides Object:addToTiles.
function Obstacle:addToTiles()
  local tile = self:getTile()
  tile.obstacleList:add(self)
  local rampNeighbors, topTile = self:getRampNeighbors(tile)
  if rampNeighbors then
    for i = 1, #rampNeighbors do
      topTile.ramps:add(rampNeighbors[i])
      rampNeighbors[i].ramps:add(topTile)
    end
  end
end
-- Overrides Object:removeFromTiles.
function Obstacle:removeFromTiles()
  local tile = self:getTile()
  tile.obstacleList:removeElement(self)
  local rampNeighbors, topTile = self:getRampNeighbors(tile)
  if rampNeighbors then
    for i = 1, #rampNeighbors do
      topTile.ramps:removeElement(rampNeighbors[i])
      rampNeighbors[i].ramps:removeElement(topTile)
    end
  end
end
-- Gets an array of tiles to each the obstacle's ramp transits.
-- @ret(table) Array of tiles if the obstacle is a ramp, nil if it's not.
function Obstacle:getRampNeighbors(tile)
  if not self.ramp then
    return nil
  end
  tile = tile or self:getTile()
  local field = FieldManager.currentField
  local height = tile.layer.height
  local neighbors = {}
  if field.objectLayers[height] then
    for _, n in ipairs(neighborShift) do
      if self:isPassable(n.x, n.y) then
        n = field:getObjectTile(n.x + tile.x, n.y + tile.y, height)
        if n then
          neighbors[#neighbors + 1] = n
        end
      end
    end
  end
  return neighbors, field:getObjectTile(tile.x, tile.y, self.collisionHeight + height)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- @ret(string) String representation (for debugging).
function Obstacle:__tostring()
  return 'Obstacle ' .. self.name .. ' ' .. tostring(self.position)
end

return Obstacle