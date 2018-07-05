
--[[===============================================================================================

BattleMoveAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Move" button.
Any action used in PathFinder must inherit from this.

=================================================================================================]]

-- Imports
local MoveAction = require('core/battle/action/MoveAction')
local PathFinder = require('core/battle/ai/PathFinder')

-- Alias
local mathf = math.field

local BattleMoveAction = class(MoveAction)

---------------------------------------------------------------------------------------------------
-- Initalization
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:init.
function BattleMoveAction:init(...)
  self.showTargetWindow = false
  self.showStepWindow = true
  self.allTiles = true
  MoveAction.init(self, ...)
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:execute.
function BattleMoveAction:execute(input)  
  FieldManager.renderer:moveToObject(input.user, nil, true)
  FieldManager.renderer.focusObject = input.user  
  local result = MoveAction.execute(self, input)
  input.user:onMove(result.path)
  TurnManager:updatePathMatrix()
  return result
end
-- Overrides MoveAction:calculatePath.
function BattleMoveAction:calculatePath(input)
  local path = input.path
  if not path then
    path = self.range.far == 0 and TurnManager:pathMatrix():get(input.target.x, input.target.y)
    path = path or PathFinder.findPath(self, input.user, input.target)
  end
  local fullPath = true
  if not path then
    fullPath = false
    path = PathFinder.findPathToUnreachable(self, input.user, input.target)
  end
  return path, fullPath
end

---------------------------------------------------------------------------------------------------
-- Selectable Tiles
---------------------------------------------------------------------------------------------------

-- Tells if a tile can be chosen as target. 
-- By default, no tile is selectable.
-- @ret(boolean) true if can be chosen, false otherwise
function BattleMoveAction:isSelectable(input, tile)
  return tile.gui.movable
end

---------------------------------------------------------------------------------------------------
-- Path Finder
---------------------------------------------------------------------------------------------------

-- Checks passability between two tiles.
-- @param(initial : ObjectTile) origin tile
-- @param(final : ObjectTile) destination tile
-- @ret(boolean) true if it's passable, false otherwise
function BattleMoveAction:isPassableBetween(initial, final, user)
  local x, y, h = initial:coordinates()
  local c = self.field:collisionXYZ(user, x, y, h, final:coordinates())
  if c then
    return false
  end
  local maxdh = user.battler.jumpPoints()
  local mindh = -2 * maxdh
  local dh = final.layer.height - h
  return mindh <= dh and dh <= maxdh
end
-- The max distance the character can walk.
-- @ret(number) the distance in tiles (may not be integer)
function BattleMoveAction:maxDistance(user)
  return user.steps or self.pathLimit
end

return BattleMoveAction
