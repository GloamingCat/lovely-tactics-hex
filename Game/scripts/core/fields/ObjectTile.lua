
local Vector = require('core/math/Vector')
local List = require('core/algorithm/List')
local Animation = require('core/graphics/Animation')
local Color = require('custom/Color')
local mathf = math.field
local tileW = Config.tileW
local tileH = Config.tileH
local max = math.max

--[[===========================================================================

An ObjectTile stores a list of static obstacles and a list of dynamic characters.
There's only one ObjectTile for each (i, j, height) in the field.

=============================================================================]]

local ObjectTile = require('core/class'):new()

-- @param(layer : ObjectLayer) the layer that this tile is in
-- @param(x : number) the tile's x coordinate
-- @param(y : number) the tile's y coordinate
function ObjectTile:init(layer, x, y, defaultRegion)
  self.layer = layer
  self.x = x
  self.y = y
  self.obstacleList = List()
  self.characterList = List()
  self.regionList = List()
  self.battlerTypeList = List()
  self.party = nil
  self.neighborList = nil
  if defaultRegion then
    self.regionList:add(defaultRegion)
  end
  self:createGraphics()
end

-- Creates the graphical elements for battle grid navigation.
function ObjectTile:createGraphics()
  local renderer = FieldManager.renderer
  local x, y, z = mathf.tile2Pixel(self:coordinates())
  x = x - tileW / 2
  y = y - tileH / 2
  if Config.gui.tileAnimID >= 0 then
    local baseAnim = Database.animOther[Config.gui.tileAnimID + 1]
    self.baseAnim = Animation.fromData(baseAnim, renderer)
    self.baseAnim.sprite:setXYZ(x, y, z)
  end
  if Config.gui.tileHLAnimID >= 0 then
    local hlAnim = Database.animOther[Config.gui.tileHLAnimID + 1]
    self.highlightAnim = Animation.fromData(hlAnim, renderer)
    self.highlightAnim.sprite:setXYZ(x, y, z)
  end
  self:hide()
end

-- Updates graphics pixel depth according to the terrains' 
--  depth in this tile's coordinates.
function ObjectTile:updateDepth()
  local tiles = FieldManager.currentField.terrainLayers[self.layer.height]
  local maxDepth = tiles[1].grid[self.x][self.y].depth
  for i = #tiles, 2, -1 do
    maxDepth = max(maxDepth, tiles[i].grid[self.x][self.y].depth)
  end
  if self.baseAnim then
    self.baseAnim.sprite:setOffset(nil, nil, maxDepth / 2)
  end
  if self.highlightAnim then
    self.highlightAnim.sprite:setOffset(nil, nil, maxDepth / 2 - 1)
  end
end

-- Stores the list of neighbor tiles.
function ObjectTile:createNeighborList()
  self.neighborList = List()
  for i, n in ipairs(mathf.neighborShift) do
    local row = self.layer.grid[n.x + self.x]
    if row then
      local tile = row[n.y + self.y]
      if tile then
        self.neighborList:add(tile)
      end
    end
  end
end

-- @ret(number) tile's grid x
-- @ret(number) tile's grid y
-- @ret(number) tile's height
function ObjectTile:coordinates()
  return self.x, self.y, self.layer.height
end

-- Converts to string.
-- @ret(string) the string representation
function ObjectTile:toString()
  return 'ObjectTile (' .. self.x .. ', ' ..  self.y .. ', ' .. self.layer.height .. ')' 
end

-- Generates a unique character ID for a character in this tile.
-- @ret(string) new ID
function ObjectTile:generateCharacterID()
  local h, x, y = self:coordinates()
  return '' .. h .. '.' .. x .. '.' .. y .. '.' .. self.characterList.size
end

-------------------------------------------------------------------------------
-- Troop
-------------------------------------------------------------------------------

-- Returns the list of battlers that are suitable for this tile.
-- @ret(List) the list of battlers
function ObjectTile:getBattlerList()
  local battlers = nil
  if self.party == 0 then
    battlers = PartyManager:backupBattlers()
  else
    battlers = List()
    for r, regionID in self.regionList:iterator() do
      local data = Config.regions[regionID + 1]
      for i = 1, #data.battlers do
        local id = data.battlers[i]
        local battlerData = Database.battlers[id + 1]
        battlers:add(battlerData)
      end
    end
  end
  battlers:conditionalRemove(
    function(b, battler) 
      return not self.battlerTypeList:contains(battler.typeID)
    end)
  return battlers
end

-- Checks if any of types in a table are in this tile.
-- @ret(boolean) true if contains one or more types, falsa otherwise
function ObjectTile:containsBattleType(types)
  for i = 1, #types do
    local typeID = types[i]
    if self.battlerTypeList:contains(typeID) then
      return true
    end
  end
  return false
end
-------------------------------------------------------------------------------
-- Collision
-------------------------------------------------------------------------------

-- Checks if there's any object collider in this tile.
-- @ret(boolean) true if collides, false otherwise
function ObjectTile:hasColliders()
  return self.characterList:isEmpty() == false
end

-- Checks if this tile is passable from the given direction.
-- @param(dx : number) the x difference in tiles
-- @param(dy : number) the y difference in tiles
-- @param(obj : Object) the object that is trying to access this tile (optional)
-- @ret(boolean) true if passable, false otherwise
function ObjectTile:isPassable(dx, dy, obj)
  for i, o in self.obstacleList:iterator() do
    if not o:isPassable(dx, dy, obj) then
      return false
    end
  end
  return true
end

-- Checks if this tile is passable from the given tile.
-- @param(x : number) the x in tiles
-- @param(y : number) the y in tiles
-- @param(obj : Object) the object that is trying to access this tile (optional)
-- @ret(boolean) true if passable, false otherwise
function ObjectTile:isPassableFrom(x, y, obj)
  return self:isPassable(self.x - x, self.y - y, obj)
end

-- Checks collision with characters.
-- @param(char : Character) the character to check collision with
-- @param(party : number) the character's party (if not nil, it's passable for allies)
-- @ret(boolean) true is collides with any of the characters, false otherwise
function ObjectTile:collidesCharacter(char, party)
  if party then
    for i, c in self.characterList:iterator() do
      if char ~= c and c.party ~= party then
        return true
      end
    end
  else
    for i, c in self.characterList:iterator() do
      if char ~= c then
        return true
      end
    end
  end
  return false
end

-------------------------------------------------------------------------------
-- Battle
-------------------------------------------------------------------------------

-- Checks if this tile os in control zone for given party.
-- @param(you : Battler) the battler of the current character
-- @ret(boolean) true if it's control zone, false otherwise
function ObjectTile:isControlZone(you)
  local containsAlly, containsEnemy = false, false
  for _, char in self.characterList:iterator() do
    if char.battler then
      if char.battler.party == you.party then
        containsAlly = true
      else
        containsEnemy = true
      end
    end
  end
  if containsEnemy then
    return true
  elseif containsAlly then
    return false
  end
  for _, n in self.neighborList:iterator() do
    for _, char in n.characterList:iterator() do
      if char.battler and char.battler.party ~= you.party then
        return true
      end
    end
  end
  return false
end

-- Gets the party of the current character in the tile.
-- @ret(number) the party number (nil if more than one character with different parties)
function ObjectTile:getCurrentParty()
  local party = nil
  for i, c in self.characterList:iterator() do
    if c.battler then
      if party == nil then
        party = c.battler.party
      elseif c.battler.party ~= party then
        return nil
      end
    end
  end
  return party
end

-- Checks if there are any enemies in this tile (character with a different party number)
-- @param(yourPaty : number) the party number to check
-- @ret(boolean) true if there's at least one enemy, false otherwise
function ObjectTile:hasEnemy(yourParty)
  for i, c in self.characterList:iterator() do
    if c.battler and c.battler.party ~= yourParty then
      return true
    end
  end
end

-- Checks if there are any allies in this tile (character with the same party number)
-- @param(yourPaty : number) the party number to check
-- @ret(boolean) true if there's at least one ally, false otherwise
function ObjectTile:hasAlly(yourParty)
  for i, c in self.characterList:iterator() do
    if c.party == yourParty then
      return true
    end
  end
end

-- Gets the terrain move cost in this tile.
-- @ret(number) the move cost
function ObjectTile:getMoveCost()
  return FieldManager.currentField:getMoveCost(self.x, self.y, self.layer.height)
end

-------------------------------------------------------------------------------
-- Grid selecting
-------------------------------------------------------------------------------

-- Selects / deselects this tile.
-- @param(value : boolean) true to select, false to deselect
function ObjectTile:setSelected(value)
  if self.highlightAnim then
    self.highlightAnim.sprite:setVisible(value)
  end
end

-- Sets color to the color with the given label.
-- @param(name : string) color label
function ObjectTile:setColor(name)
  self.colorName = name
  if name == nil or name == '' then
    name = 'nothing'
  end
  name = 'tile_' .. name
  if not self.selectable then
    name = name .. '_off'
  end
  local c = Color[name]
  self.baseAnim.sprite:setColor(c)
end

-- Shows tile edges.
function ObjectTile:show()
  if self.baseAnim then
    self.baseAnim.sprite:setVisible(true)
  end
end

-- Hides tile edges.
function ObjectTile:hide()
  if self.baseAnim then
    self.baseAnim.sprite:setVisible(false)
  end
  self:setSelected(false)
end

return ObjectTile
