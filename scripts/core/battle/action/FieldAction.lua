
--[[===============================================================================================

FieldAction
---------------------------------------------------------------------------------------------------
An abstract action where the player selects a tile in the field grid.
The method <execute> defines what happens when player confirms the selected tile.
The method <isSelectable> checks if a tile is valid to be chosen or not.
When called outsite of battle, it must set up tiles' graphics first.

=================================================================================================]]

-- Alias
local mathf = math.field

local FieldAction = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(range : table) The range of the action to the target tile (in tiles).
-- @param(area : table) The area of the action effect (in tiles).
function FieldAction:init(range, area)
  self.range = range or { far = 0, minh = 0, maxh = 0 }
  self.area = area or { far = 1, minh = 0, maxh = 0 }
  self.field = FieldManager.currentField
end

---------------------------------------------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------------------------------------------

-- Called when this action has been chosen.
function FieldAction:onSelect(input)
  self:resetTileProperties(input)
end
-- Called when the ActionGUI is open.
-- By default, just updates the "selectable" field in all tiles for grid selecting.
function FieldAction:onActionGUI(input)
  input.GUI:startGridSelecting(input.target or self:firstTarget(input))
end
-- Called when player chooses a target for the action. 
-- By default, just ends grid seleting and calls execute.
-- @ret(table) the battle result
function FieldAction:onConfirm(input)
  if input.GUI then
    input.GUI:endGridSelecting()
  end
  return self:execute(input)
end
-- Called when player chooses a target for the action. 
-- By default, just ends grid selecting.
-- @ret(table) the battle result:
--  nil to stay on ActionGUI;
--  table with nil timeCost empty to return to BattleGUI;
--  table with non-nil tomeCost to end turn
function FieldAction:onCancel(input)
  if input.GUI then
    input.GUI:endGridSelecting()
  end
  return {}
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Checks if the action can be executed.
function FieldAction:canExecute(input)
  return true -- Abstract.
end
-- Executes the action animations and applies effects.
function FieldAction:execute(input)
  return { executed = true, tiles = self:getAllAffectedTiles(input) }
end

---------------------------------------------------------------------------------------------------
-- Tiles Properties
---------------------------------------------------------------------------------------------------

-- Resets all general tile properties (movable, reachable, selectable).
function FieldAction:resetTileProperties(input)
  self:resetSelectableTiles(input)
end
-- Sets all tiles as selectable or not and resets color to default.
-- @param(selectable : boolean) The value to set all tiles.
function FieldAction:resetSelectableTiles(input)
  for tile in self.field:gridIterator() do
    tile.gui.selectable = self:isSelectable(input, tile)
  end
end

---------------------------------------------------------------------------------------------------
-- Grid navigation
---------------------------------------------------------------------------------------------------

-- Tells if a tile can be chosen as target. 
-- By default, no tile is selectable.
-- @param(tile : ObjectTile) The tile to check.
-- @ret(boolean) True if can be chosen, false otherwise.
function FieldAction:isSelectable(input, tile)
  return true -- Abstract.
end
-- Called when players selects (highlights) a tile.
function FieldAction:onSelectTarget(input)
  if input.GUI then
    if input.target.gui.selectable then
      local targets = self:getAllAffectedTiles(input)
      for i = #targets, 1, -1 do
        targets[i].gui:setSelected(true)
      end
    else
      input.target.gui:setSelected(true)
    end
  end
end
-- Called when players deselects (highlights another tile) a tile.
function FieldAction:onDeselectTarget(input)
  if input.GUI and input.target then
    local oldTargets = self:getAllAffectedTiles(input)
    for i = #oldTargets, 1, -1 do
      oldTargets[i].gui:setSelected(false)
    end
  end
end
-- Gets all tiles that will be affected by skill's effect.
-- @ret(table) An array of tiles.
function FieldAction:getAllAffectedTiles(input, tile)
  tile = tile or input.target
  local sizeX, sizeY = self.field.sizeX, self.field.sizeY
  local tiles = {}
  local height = input.target.layer.height
  for i, j in mathf.radiusIterator(self.area.far - 1, tile.x, tile.y, sizeX, sizeY) do
    for h = height - self.area.minh, height + self.area.maxh do
      if mathf.tileDistance(i, j, tile.x, tile.y) >= (self.area.near or 0)
          and self.field:isGrounded(i, j, h) then
        tiles[#tiles + 1] = self.field:getObjectTile(i, j, h)
      end
    end
  end
  return tiles
end
-- @ret(boolean) True if it's an area action, false otherwise.
function FieldAction:isArea()
  return self.area.far > 1 or self.area.far > 0 and (self.area.minh > 0 or self.area.maxh > 0)
end
-- Gets the next target given the player's input.
-- @param(axisX : number) The input in axis x.
-- @param(axisY : number) The input in axis y.
-- @ret(ObjectTile) The next tile (nil if not accessible).
function FieldAction:nextTarget(input, axisX, axisY)
  local x, y = mathf.nextCoord(input.target.x, input.target.y, 
    axisX, axisY, self.field.sizeX, self.field.sizeY)
  local tile = mathf.frontTile(input.target, x - input.target.x, y - input.target.y)
  while tile.layer.height > 0 and not FieldManager.currentField:isGrounded(tile:coordinates()) do
    tile = FieldManager.currentField:getObjectTile(tile.x, tile.y, tile.layer.height - 1)
  end
  return tile
end
-- Moves tile cursor to another layer.
-- @param(axis : number) The input direction (page up is 1, page down is -1).
-- @ret(ObjectTile) The next tile (nil if not accessible).
function FieldAction:nextLayer(input, axis)
  local tile = input.target
  repeat
    tile = FieldManager.currentField:getObjectTile(tile.x, tile.y, tile.layer.height + axis)
  until not tile or FieldManager.currentField:isGrounded(tile:coordinates())
  return tile or input.target
end

return FieldAction