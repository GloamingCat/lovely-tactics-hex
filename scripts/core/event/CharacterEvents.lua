
--[[===============================================================================================

Character Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local MoveAction = require('core/battle/action/MoveAction')

local util = {}

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Removes a character from the field.
-- @param(args.permanent : boolean) If false, character shows up again when field if reloaded.
-- @param(args.fade : number) Duration of fading animation.
function util.deleteChar(sheet, args)
  local char = sheet:findCharacter(args.key)
  if args.fade and args.fade > 0 then
    local speed = 255 / args.fade
    char:colorizeTo(nil, nil, nil, 0, speed)
  end
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not char:colorizing()
    end)
  end
  char:destroy(args.permanent)
end

---------------------------------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.key : string) The key of the character.
--  "origin" or "dest" to refer to event's characters, or any other key to refer to any other
--  character in the current field.

-- Moves straight to the given tile.
-- @param(args.x : number) Tile x difference.
-- @param(args.y : number) Tile y difference.
-- @param(args.h : number) Tile height difference (0 by default).
function util.moveCharTile(sheet, args)
  local char = sheet:findCharacter(args.key)
  char:removeFromTiles()
  char:walkTiles(args.x, args.y, args.h)
  char:addToTiles()
end
-- Moves in the given direction.
-- @param(args.angle : number) The direction in degrees.
-- @param(args.distance : number) The distance to move (in tiles).
function util.moveCharDir(sheet, args)
  local char = sheet:findCharacter(args.key)
  local nextTile = char:frontTile(args.angle)
  if nextTile then
    local ox, oy, oh = char:tileCoordinates()
    local dx, dy, dh = nextTile:coordinates()
    dx, dy, dh = dx - ox, dy - oy, dh - oh
    dx, dy, dh = dx * args.distance, dy * args.distance, dh * args.distance
    if char.autoTurn then
      char:turnToTile(ox + dx, oy + dy)
    end
    char:removeFromTiles()
    char:walkToTile(ox + dx, oy + dy, oh + dh)
    char:addToTiles()
  end
end
-- Moves a path to the given tile.
-- @param(args.x : number) Tile destination x.
-- @param(args.y : number) Tile destination y.
-- @param(args.h : number) Tile destination height.
-- @param(args.limit : number) The maxium length of the path to be calculated.
function util.moveCharPath(sheet, args)
  local char = sheet:findCharacter(args.key)
  local tile = FieldManager.currentField:getObjectTile(args.x, args.y, args.h)
  assert(tile, 'Tile not reachable: ', args.x, args.y, args.h)
  local action = MoveAction()
  action.pathLimit = args.limit
  action.callback = args.callback
  local input = ActionInput(action, char, tile)
  input.action:execute(input)
end

---------------------------------------------------------------------------------------------------
-- Direction
---------------------------------------------------------------------------------------------------

-- Turns character to the given tile.
-- @param(args.other : string) Key of a character in the destination tile (optional).
-- @param(args.x : number) Tile destination x.
-- @param(args.y : number) Tile destination y.
function util.turnCharTile(sheet, args)
  local char = sheet:findCharacter(args.key)
  if args.other then
    local other = sheet:findCharacter(args.other)
    local x, y = other:tileCoordinates()
    char:turnToTile(x, y)
  else
    char:turnToTile(args.x, args.y)
  end
end
-- Turn character to the given direction.
-- @param(args.angle : number) The direction angle in degrees.
function util.turnCharDir(sheet, args)
  local char = sheet:findCharacter(sheet, args.key)
  char:setDirection(args.angle)
end

return util