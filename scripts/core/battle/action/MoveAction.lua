
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
-- Initalization
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:init.
function MoveAction:init(range, limit)
  self.pathLimit = limit or math.huge
  BattleAction.init(self, '', range)
end

---------------------------------------------------------------------------------------------------
-- Reachable Tiles
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:resetReachableTiles.
function MoveAction:resetReachableTiles(input)
  for tile in self.field:gridIterator() do
    tile.gui.reachable = tile.gui.movable
  end
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:execute.
function MoveAction:execute(input)
  local path, fullPath = self:calculatePath(input)
  if path then
    input.user:walkPath(path, false, true, self.player)
  end
  return { executed = fullPath, path = path }
end
-- @ret(Path) Path to input target, if any.
-- @ret(boolean) True if the whole path may be walked, false otherwise.
function MoveAction:calculatePath(input)
  local path = input.path or PathFinder.findPath(self, input.user, input.target)
  local fullPath = true
  if not path then
    fullPath = false
    path = PathFinder.findPathToUnreachable(self, input.user, input.target)
  end
  return path, fullPath
end

---------------------------------------------------------------------------------------------------
-- Path Finder
---------------------------------------------------------------------------------------------------

-- Checks if a character can stay in this tile.
-- @param(tile : ObjectTile) Tile to check.
-- @ret(boolean) True if it can stay, false otherwise.
function MoveAction:isStandable(tile, user)
  for c in tile.characterList:iterator() do
    if c ~= user and not c.passable then
      return false
    end
  end
  return true
end
-- Tells if a tile is last of the movement.
-- @param(tile : ObjectTile) Tile to check.
-- @param(target : ObjectTile) Movement target.
-- @ret(boolean) True if it's final, false otherwise.
function MoveAction:isFinal(tile, target, user)
  local dh = target.layer.height - tile.layer.height
  if dh > self.range.maxh or dh < -self.range.minh then
    return false
  end
  local cost = mathf.tileDistance(tile.x, tile.y, target.x, target.y)
  return cost <= self.range.far and cost >= self.range.near
    and self:isStandable(tile, user)
end
-- Checks passability between two tiles.
-- @param(initial : ObjectTile) origin tile
-- @param(final : ObjectTile) destination tile
-- @ret(boolean) true if it's passable, false otherwise
function MoveAction:isPassableBetween(initial, final, user)
  local x, y, h = initial:coordinates()
  local c = self.field:collisionXYZ(user, x, y, h, final:coordinates())
  if c then
    return false
  end
  return true
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
    return baseCost - 0.00001
  end
end
-- The max distance the character can walk.
-- @ret(number) the distance in tiles (may not be integer)
function MoveAction:maxDistance(user)
  return self.pathLimit
end

return MoveAction