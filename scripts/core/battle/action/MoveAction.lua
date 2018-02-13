
--[[===============================================================================================

MoveAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Move" button.
Any action used in PathFinder must inherit from this.

=================================================================================================]]

-- Imports
local BattleAction = require('core/battle/action/BattleAction')
local PathFinder = require('core/battle/ai/PathFinder')

-- Alias
local mathf = math.field

local MoveAction = class(BattleAction)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:execute.
function MoveAction:execute(input)
  local path = input.path or PathFinder.findPath(self, input.user, input.target)
  if not path then
    path = path 
  end
  local fullPath = true
  if not path then
    fullPath = false
    path = PathFinder.findPathToUnreachable(self, input.user, input.target)
  end
  input.user:walkPath(path)
  return { executed = fullPath }
end

---------------------------------------------------------------------------------------------------
-- Path Finder
---------------------------------------------------------------------------------------------------

-- Checks if a character can stay in this tile.
-- @param(tile : ObjectTile) tile to check
-- @ret(boolean) true if it can stay, false otherwise
function MoveAction:isStandable(tile, user)
  for c in tile.characterList:iterator() do
    if c ~= user and not c.passable then
      return false
    end
  end
  return true
end
-- Tells if a tile is last of the movement.
-- @param(tile : ObjectTile) tile to check
-- @ret(boolean) true if it's final, false otherwise
function MoveAction:isFinal(tile, final, user)
  return tile == final
end
-- Checks passability between two tiles.
-- @param(initial : ObjectTile) origin tile
-- @param(final : ObjectTile) destination tile
-- @ret(boolean) true if it's passable, false otherwise
function MoveAction:isPassableBetween(initial, final, user)
  local c = self.field:collisionXYZ(user, initial.x, initial.y, 
    initial.layer.height, final:coordinates())
  if c then
    return false
  end
  return final.layer.height == initial.layer.height
end
-- Gets the move cost between the two tiles.
-- @param(initial : ObjectTile) the initial tile
-- @param(final : ObjectTile) the destination tile
-- @ret(number) the move cost
function MoveAction:getDistanceBetween(initial, final, user)
  return (initial:getMoveCost() + final:getMoveCost()) / 2
end
-- Calculas a minimum cost between two tiles.
-- @param(initial : ObjectTile) the initial tile
-- @param(final : ObjectTile) the destination tile
-- @ret(number) the estimated move cost
function MoveAction:estimateCost(initial, final, user)
  local baseCost = mathf.tileDistance(initial.x, initial.y, final.x, final.y)
  if final.characterList.size > 0 then
    return baseCost 
  else
    return baseCost - 0.0001
  end
end
-- The max distance the character can walk.
-- @ret(number) the distance in tiles (may not be integer)
function MoveAction:maxDistance(user)
  return math.huge
end

return MoveAction
