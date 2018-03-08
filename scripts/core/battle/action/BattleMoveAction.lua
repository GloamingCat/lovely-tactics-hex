
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
function BattleMoveAction:init(range)
  MoveAction.init(self, range or 0, 1)
  self.showTargetWindow = false
  self.showStepWindow = true
  self.allTiles = true
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:execute.
function BattleMoveAction:execute(input)
  local path = input.path
  if not path then
    path = self.range == 0 and TurnManager:pathMatrix():get(input.target.x, input.target.y)
    path = path or PathFinder.findPath(self, input.user, input.target)
  end
  local fullPath = true
  if not path then
    fullPath = false
    path = PathFinder.findPathToUnreachable(self, input.user, input.target)
  end
  FieldManager.renderer:moveToObject(input.user, nil, true)
  FieldManager.renderer.focusObject = input.user
  input.user:walkPath(path, false, true)
  input.user:onMove(path)
  TurnManager:updatePathMatrix()
  return { executed = fullPath }
end

---------------------------------------------------------------------------------------------------
-- Selectable Tiles
---------------------------------------------------------------------------------------------------

-- Tells if a tile can be chosen as target. 
-- By default, no tile is selectable.
-- @ret(boolean) true if can be chosen, false otherwise
function BattleMoveAction:isSelectable(input, tile)
  return tile.gui.movable and tile.characterList:isEmpty()
end

---------------------------------------------------------------------------------------------------
-- Path Finder
---------------------------------------------------------------------------------------------------

-- Tells if a tile is last of the movement.
-- @param(tile : ObjectTile) tile to check
-- @ret(boolean) true if it's final, false otherwise
function BattleMoveAction:isFinal(tile, final, user)
  local cost = self:estimateCost(tile, final, user)
  return cost <= self.range and self:isStandable(tile, user)
end
-- Checks passability between two tiles.
-- @param(initial : ObjectTile) origin tile
-- @param(final : ObjectTile) destination tile
-- @ret(boolean) true if it's passable, false otherwise
function BattleMoveAction:isPassableBetween(initial, final, user)
  local c = self.field:collisionXYZ(user, initial.x, initial.y, 
    initial.layer.height, final:coordinates())
  if c then
    return false
  end
  local maxdh = user.battler.jumpPoints()
  local mindh = -2 * maxdh
  local dh = final.layer.height - initial.layer.height
  return mindh <= dh and dh <= maxdh
end
-- The max distance the character can walk.
-- @ret(number) the distance in tiles (may not be integer)
function BattleMoveAction:maxDistance(user)
  return user.steps
end

return BattleMoveAction
