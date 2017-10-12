
-- Imports
local FiberList = require('core/fiber/FiberList')

-- Alias
local round = math.round
local pixel2Tile = math.field.pixel2Tile
local tile2Pixel = math.field.tile2Pixel

local Interactable = class()

function Interactable:init(instData)
  self:initializeScripts(instData)
  self.passable = instData.passable
  local layer = FieldManager.currentField.objectLayers[instData.h]
  assert(layer, 'height out of bounds: ' .. instData.h)
  layer = layer.grid[instData.x]
  assert(layer, 'x out of bounds: ' .. instData.x)
  local tile = layer[instData.y]
  tile.characterList:add(self)
end

-- Creates listeners from instData.
-- @param(instData : table) the instData from field file
function Interactable:initializeScripts(instData)
  self.fiberList = FiberList()
  if instData.startScript and instData.startScript.path ~= '' then
    self.startScript = instData.startScript
  end
  if instData.collideScript and instData.collideScript.path ~= '' then
    self.collideScript = instData.collideScript
  end
  if instData.interactScript and instData.interactScript.path ~= '' then
    self.interactScript = instData.interactScript
  end
end

function Interactable:update()
  self.fiberList:update()
end

function Interactable:destroy()
  FieldManager.characterList:removeElement(self)
  FieldManager.updateList:removeElement(self)
end

function Interactable:onInteract(event)
  local path = 'character/' .. self.interactScript.path
  local fiberList = self.interactScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(path, event)
  fiber:execAll()
end

function Interactable:onCollide(event)
  local path = 'character/' .. self.collideScript.path
  local fiberList = self.collideScript.global and FieldManager.fiberList or self.fiberList
  local fiber = fiberList:forkFromScript(path, event)
  fiber:execAll()
end

function Interactable:onStart(event)
  local path = 'character/' .. self.startScript.path
  local fiberList = self.startScript.global and FieldManager.fiberList or self.fiberList
  fiberList:forkFromScript(path, event)
end

return Interactable