
--[[===============================================================================================

Interactable
---------------------------------------------------------------------------------------------------
Base methods for objects with start/collision/interaction scripts.
It is created from a instance data table, which contains (x, y, h) coordinates, scripts, and 
passable and persistent properties.

=================================================================================================]]

-- Imports
local FiberList = require('core/base/fiber/FiberList')

-- Alias
local copyTable = util.table.deepCopy

local Interactable = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(instData : table) Instance data from field file.
-- @param(save : table) Persistent data from save file (optional).
function Interactable:init(instData, save)
  self:initScripts(instData)
  self.key = instData.key
  self.passable = instData.passable
  self.persistent = instData.persistent
  local layer = FieldManager.currentField.objectLayers[instData.h]
  assert(layer, 'height out of bounds: ' .. instData.h)
  layer = layer.grid[instData.x]
  assert(layer, 'x out of bounds: ' .. instData.x)
  self.tile = layer[instData.y]
  assert(self.tile, 'y out of bounds: ' .. instData.y)
  self.tile.characterList:add(self)
  FieldManager.updateList:add(self)
end
-- Creates listeners from instance data.
-- @param(instData : table) Instance data from field file.
function Interactable:initScripts(instData, save)
  self.fiberList = FiberList(self)
  if instData.loadScript and instData.loadScript.name ~= '' then
    self.loadScript = instData.loadScript
  end
  if instData.collideScript and instData.collideScript.name ~= '' then
    self.collideScript = instData.collideScript
  end
  if instData.interactScript and instData.interactScript.name ~= '' then
    self.interactScript = instData.interactScript
  end
  self.deleted = save and save.deleted
  self.vars = save and util.table.deepCopy(save.vars) or {}
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Updates fiber list.
function Interactable:update()
  self.fiberList:update()
end
-- Removes from FieldManager.
function Interactable:destroy()
  FieldManager.updateList:removeElement(self)
  for i = 1, self.fiberList.size do
    self.fiberList[i]:interrupt()
  end
  if self.persistent then
    SaveManager:storeCharData(FieldManager.currentField.id, self)
  end
end
-- @ret(string) String representation (for debugging).
function Interactable:__tostring()
  return 'Interactable: ' .. self.key
end
-- Data with fiber list's state and local variables.
-- @ret(table) Interactable's state to be saved.
function Interactable:getPersistentData()
  local data = {}
  data.vars = copyTable(self.vars)
  data.deleted = self.deleted
  return data
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

-- Called when a character interacts with this object.
-- @param(event : table) Table with tile and origin (usually player) and dest (this) objects.
function Interactable:onInteract(tile)
  local fiberList = self.interactScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.interactScript, self)
  fiber.tile = self.tile
  fiber:waitForEnd()
end
-- Called when a character collides with this object.
-- @param(event : table) Table with tile and origin and dest (this) objects.
function Interactable:onCollide(tile, collided, collider)
  local fiberList = self.collideScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.collideScript, self)
  fiber.tile = self.tile
  fiber:waitForEnd()
end
-- Called when this interactable is created.
-- @param(event : table) Table with origin (this).
function Interactable:onStart()
  local fiberList = self.loadScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.loadScript, self)
  fiber.tile = self.tile
  fiber:waitForEnd()
end

return Interactable