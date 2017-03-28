
--[[===========================================================================

BattleCursor
-------------------------------------------------------------------------------
Cursor used to indicate current turn's character and the selected tile.

=============================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')

-- Alias
local mathf = math.field
local max = math.max

-- Constants
local cursorAnimID = Config.gui.battleCursorAnimID
local tileW = Config.grid.tileW
local tileH = Config.grid.tileH
local pph = Config.grid.pixelsPerHeight

local BattleCursor = require('core/class'):new()

-------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------

function BattleCursor:init()
  if cursorAnimID >= 0 then
    local animData = Database.animOther[cursorAnimID + 1]
    self.anim = Animation.fromData(animData, FieldManager.renderer)
    local _, _, w = self.anim.sprite.quad:getViewport()
    self.offsetX = - w / 2
    self.offsetY = - tileH
  end
end

-- Updates animation.
function BattleCursor:update()
  if self.anim then
    self.anim:update()
  end
end

-- Sets as visible.
function BattleCursor:show()
  if self.anim then
    self.anim.sprite:setVisible(true)
  end
end

-- Sets as not visible.
function BattleCursor:hide()
  if self.anim then
    self.anim.sprite:setVisible(false)
  end
end

-- Removes from renderer.
function BattleCursor:destroy()
  if self.anim then
    self.anim.sprite:removeSelf()
  end
end

-------------------------------------------------------------------------------
-- Position
-------------------------------------------------------------------------------

-- Sets the position to the given tile.
-- @param(tile : ObjectTile) the target tile
function BattleCursor:setTile(tile)
  if not self.anim then
    return
  end
  local x, y, z = mathf.tile2Pixel(tile:coordinates())
  self.anim.sprite:setVisible(tile.selectable)
  local maxH = 0
  for obj in tile.obstacleList:iterator() do
    maxH = max(maxH, obj.colliderHeight)
  end
  for obj in tile.characterList:iterator() do
    maxH = max(maxH, obj.colliderHeight)
  end
  self.anim.sprite:setXYZ(x + self.offsetX, y - maxH * pph + self.offsetY, z - 1)
end

-- Sets the position to the given character.
-- @param(char : Character) the target character
function BattleCursor:setCharacter(char)
    local x, y, z = char.position:coordinates()
    self.anim.sprite:setVisible(true)
    local maxH = char.colliderHeight
    self.anim.sprite:setXYZ(x + self.offsetX, y - maxH * pph + self.offsetY, z - 1)
end

return BattleCursor
