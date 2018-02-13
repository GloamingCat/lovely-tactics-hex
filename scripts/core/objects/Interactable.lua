
--[[===============================================================================================

Interactable
---------------------------------------------------------------------------------------------------
Base methods for objects with start/collision/interaction scripts.

=================================================================================================]]

-- Imports
local FiberList = require('core/fiber/FiberList')

-- Alias
local copyTable = util.table.deepCopy

local Interactable = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Data with (x, y, h) coordinates, passable, persistent and scripts.
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
-- Creates listeners from instData.
-- @param(instData : table) The instData from field file.
function Interactable:initScripts(instData, save)
  self.fiberList = FiberList(save and save.fiberList)
  self.startScript = instData.startScript
  self.collideScript = instData.collideScript
  self.interactScript = instData.interactScript
  self.deleted = save and save.deleted
  self.vars = save and copyTable(save.vars) or {}
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
  data.fiberList = self.fiberList:getState()
  data.vars = copyTable(self.vars)
  data.deleted = self.deleted
  return data
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

-- Called when a character interacts with this object.
-- @param(event : table) Table with tile and origin (usually player) and dest (this) objects.
function Interactable:onInteract(event)
  event.block = true
  event.self = self
  local fiberList = self.interactScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.interactScript.commands, event)
  fiber:waitForEnd()
end
-- Called when a character collides with this object.
-- @param(event : table) Table with tile and origin and dest (this) objects.
function Interactable:onCollide(event)
  event.block = true
  event.self = self
  local fiberList = self.collideScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.collideScript.commands, event)
  fiber:waitForEnd()
end
-- Called when this interactable is created.
-- @param(event : table) Table with origin (this).
function Interactable:onStart(event)
  event.block = true
  event.self = self
  local fiberList = self.startScript.global and FieldManager.fiberList or self.fiberList
  fiberList:forkFromScript(self.startScript.commands, event)
end

return Interactable