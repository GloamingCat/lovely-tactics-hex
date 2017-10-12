
--[[===============================================================================================

TransitionGen
---------------------------------------------------------------------------------------------------
Generates empty characters that teleports the player to another map.

=================================================================================================]]

local Interactable = require('core/objects/Interactable')

local function toScript(transition)
  local func = 'util.event.moveToField(event,' .. transition .. ',60)'
  return {
    path = 'Func',
    param = func,
    global = true }
end

local function instantiate(x, y, field, script)
  local tile = field:getObjectTile(x, y, 0)
  if not tile:collidesObstacle(0, 0) then
    local char = {
      key = '',
      x = x, y = y, h = 0,
      passable = false,
      collideScript = script }
    Interactable(char)
    print('instantiate', x, y)
  end
end

local function instantiateX(x, field, transition)
  local script = toScript(transition)
  for y = 1, field.sizeY do
    instantiate(x, y, field, script)
  end
end

local function instantiateY(y, field, transition)
  local script = toScript(transition)
  for x = 1, field.sizeX do
    instantiate(x, y, field, script)
  end
end

return function(event)
  local field = FieldManager.currentField
  local north = field.tags.north
  local south = field.tags.south
  local west = field.tags.west
  local east = field.tags.east
  if north then
    instantiateY(1, field, north)
  end
  if south then
    instantiateY(field.sizeY, field, south)
  end
  if west then
    instantiateX(1, field, west)
  end
  if east then
    instantiateX(field.sizeX, field, east)
  end
end