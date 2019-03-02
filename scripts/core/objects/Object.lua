
--[[===============================================================================================

Object
---------------------------------------------------------------------------------------------------
A common class for obstacles and characters.

=================================================================================================]]

-- Imports
local TagMap = require('core/datastruct/TagMap')
local Transformable = require('core/math/transform/Transformable')
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')

-- Alias
local round = math.round
local pixel2Tile = math.field.pixel2Tile
local tile2Pixel = math.field.tile2Pixel

-- Constants
local pph = Config.grid.pixelsPerHeight

local Object = class(Transformable)

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(data : table) Data from file (obstacle or character).
function Object:init(data, pos)
  Transformable.init(self, pos)
  self.data = data
  self.name = data.name
  if data.tags then
    self.tags = TagMap(data.tags)
  end
end
-- Dispose sprite and remove from tiles' object lists.
function Object:destroy()
  if self.sprite then
    self.sprite:destroy()
  end
  self:removeFromTiles()
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

-- Overrides Movable:setXYZ.
-- Updates sprite position.
function Object:setXYZ(x, y, z)
  Transformable.setXYZ(self, x, y, z)
  self.sprite:setXYZ(x, y, z)
end

---------------------------------------------------------------------------------------------------
-- Tile
---------------------------------------------------------------------------------------------------

-- Gets the aproximate tile coordinates of this object.
-- @ret(number) Tile x.
-- @ret(number) Tile y.
-- @ret(number) Tile height.
function Object:tileCoordinates()
  local i, j, h = pixel2Tile(self.position:coordinates())
  i = round(i)
  j = round(j)
  h = round(h)
  return i, j, h
end
-- Converts current pixel position to tile.
-- @ret(ObjectTile) Current tile.
function Object:getTile()
  local x, y, h = self:tileCoordinates()
  local layer = FieldManager.currentField.objectLayers[h]
  assert(layer, 'height out of bounds: ' .. h)
  layer = layer.grid[x]
  assert(layer, 'x out of bounds: ' .. x)
  return layer[y]
end
-- Sets object's current position to the given tile.
-- @param(tile : ObjectTile) Destination tile.
function Object:setTile(tile)
  local x, y, z = tile2Pixel(tile:coordinates())
  self:setXYZ(x, y, z)
end
-- Move to the given tile.
-- @param(tile : ObjectTile) Destination tile.
function Object:moveToTile(tile, ...)
  local x, y, z = tile2Pixel(tile:coordinates())
  self:moveTo(x, y, z, ...)
end
-- Gets all tiles this object is occuping.
-- @ret(table) The list of tiles.
function Object:getAllTiles(i, j, h)
  if i and j and h then
    return { FieldManager.currentField:getObjectTile(i, j, h) }
  else
    return { self:getTile() }
  end
end
-- Adds this object to the tiles it's occuping.
function Object:addToTiles(tiles)
  -- Abstract.
end
-- Removes this object from the tiles it's occuping.
function Object:removeFromTiles()
  -- Abstract.
end
-- Sets this object to the center of its current tile.
function Object:adjustToTile()
  local x, y, z = tile2Pixel(self:tileCoordinates())
  self:setXYZ(x, y, z)
end

---------------------------------------------------------------------------------------------------
-- Collision
---------------------------------------------------------------------------------------------------

-- Checks if a tile point is colliding with something.
-- @param(tile : Tile) The origin tile.
-- @param(dx : number) The grid displacement in x axis.
-- @param(dy : number) The grid displaciment in y axis.
-- @param(dh : number) The grid height displacement.
-- @ret(number) The collision type.
function Object:collision(tile, dx, dy, dh)
  local orig = Vector(tile:coordinates())
  local dest = Vector(dx, dy, dh)
  dest:add(orig)
  return FieldManager.currentField:collision(self, orig, dest)
end
-- Gets the collider's height in grid units.
-- @param(x : number) The x of the tile of check the height.
-- @param(y : number) The y of the tile of check the height.
-- @ret(number) Height in grid units.
function Object:getHeight(x, y)
  return 0
end
-- Gets the collider's height in pixels.
-- @param(x : number) The x of the tile of check the height.
-- @param(y : number) The y of the tile of check the height.
-- @ret(number) Height in pixels.
function Object:getPixelHeight(dx, dy)
  local h = self:getHeight(dx, dy)
  return h * pph
end

return Object