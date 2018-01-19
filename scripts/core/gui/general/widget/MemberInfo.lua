
--[[===============================================================================================

MemberInfo
---------------------------------------------------------------------------------------------------
A button that shows a breef information about the member it represents.

=================================================================================================]]

-- Imports
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

local MemberInfo = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(member : table)
-- @param(...) parameters from Button:init.
function MemberInfo:init(battler, w, h, topLeft)
  self.battler = battler
  local margin = 4
  topLeft = topLeft or Vector(0, 0, 0)
  
  -- Icon
  local char = Database.characters[battler.charID]
  local icon = char.portraits and char.portraits.bigIcon
  if icon then
    local sprite = ResourceManager:loadIcon(icon, GUIManager.renderer)
    self.icon = SimpleImage(sprite, topLeft.x, topLeft.y, topLeft.z, nil, h)   
    local ix, iy, iw, ih = sprite:totalBounds()
    topLeft.x = topLeft.x + iw + 4
    w = w - iw - 4
  end
  -- Name
  self.textName = SimpleText(battler.name, topLeft, w, 'left', Fonts.gui_medium)
end

-------------------------------------------------------------------------------
-- Window Content methods
-------------------------------------------------------------------------------

-- Sets image position.
function MemberInfo:updatePosition(pos)
  if self.icon then
    self.icon:updatePosition(pos)
  end
  self.textName:updatePosition(pos)
end
-- Shows image.
function MemberInfo:show()
  if self.icon then
    self.icon:show()
  end
  self.textName:show()
end
-- Hides image.
function MemberInfo:hide()
  if self.icon then
    self.icon:hide()
  end
  self.textName:hide()
end
-- Destroys sprite.
function MemberInfo:destroy()
  if self.icon then
    self.icon:destroy()
  end
  self.textName:destroy()
end

return MemberInfo