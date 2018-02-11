
--[[===============================================================================================

Interactable
---------------------------------------------------------------------------------------------------
Base methods for objects with start/collision/interaction scripts.

=================================================================================================]]

-- Imports
local FiberList = require('core/fiber/FiberList')

local Interactable = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Data with (x, y, h) coordinates, passable, persistent and scripts
function Interactable:init(instData)
  self:initScripts(instData)
  self.passable = instData.passable
  self.persistent = instData.persistent
  local layer = FieldManager.currentField.objectLayers[instData.h]
  assert(layer, 'height out of bounds: ' .. instData.h)
  layer = layer.grid[instData.x]
  assert(layer, 'x out of bounds: ' .. instData.x)
  local tile = layer[instData.y]
  assert(tile, 'y out of bounds: ' .. instData.y)
  tile.characterList:add(self)
end
-- Creates listeners from instData.
-- @param(instData : table) the instData from field file
function Interactable:initScripts(instData)
  self.fiberList = FiberList()
  self.startScript = instData.startScript
  self.collideScript = instData.collideScript
  self.interactScript = instData.interactScript
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
  FieldManager.characterList:removeElement(self)
  FieldManager.updateList:removeElement(self)
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

-- Called when a character interacts with this object.
-- @param(event : table) Table with tile and origin (usually player) and dest (this) objects.
function Interactable:onInteract(event)
  event.block = true
  local fiberList = self.interactScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.interactScript.commands, event)
  fiber:waitForEnd()
end
-- Called when a character collides with this object.
-- @param(event : table) Table with tile and origin and dest (this) objects.
function Interactable:onCollide(event)
  event.block = true
  local fiberList = self.collideScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(self.collideScript.commands, event)
  fiber:waitForEnd()
end
-- Called when this interactable is created.
-- @param(event : table) Table with origin (this).
function Interactable:onStart(event)
  event.block = true
  local fiberList = self.startScript.global and FieldManager.fiberList or self.fiberList
  fiberList:forkFromScript(self.startScript.commands, event)
end

return Interactable