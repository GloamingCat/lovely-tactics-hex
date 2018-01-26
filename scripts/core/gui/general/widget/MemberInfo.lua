
--[[===============================================================================================

MemberInfo
---------------------------------------------------------------------------------------------------
A button that shows a breef information about the member it represents.

=================================================================================================]]

-- Imports
local IconList = require('core/gui/general/widget/IconList')
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

-- Constants
local hpName = Config.attributes[Config.battle.attHP].shortName
local spName = Config.attributes[Config.battle.attSP].shortName

local MemberInfo = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(member : table)
-- @param(...) parameters from Button:init.
function MemberInfo:init(battler, w, h, topLeft)
  self.battler = battler
  topLeft = topLeft and topLeft:clone() or Vector(0, 0, 0)
  local margin = 4
  -- Icon
  local char = Database.characters[battler.charID]
  local icon = char.portraits and char.portraits.bigIcon
  if icon then
    local sprite = ResourceManager:loadIcon(icon, GUIManager.renderer)
    self.icon = SimpleImage(sprite, topLeft.x, topLeft.y, topLeft.z, nil, h)   
    local ix, iy, iw, ih = sprite:totalBounds()
    topLeft.x = topLeft.x + iw + margin
    w = w - iw - margin
  end
  topLeft.y = topLeft.y + 1
  local rw = (w - margin) / 2
  local small = Fonts.gui_small
  local tiny = Fonts.gui_tiny
  local medium = Fonts.medium
  -- Name
  local txtName = SimpleText(battler.name, topLeft, rw, 'left', medium)
  -- HP
  local middleLeft = Vector(topLeft.x, topLeft.y + 16, topLeft.z)
  local txtHP = SimpleText(hpName, middleLeft, rw, 'left', small)
  local hp = battler.state.hp .. '/' .. battler.mhp()
  local valueHP = SimpleText(hp, middleLeft, rw, 'right', tiny)
  -- SP
  local bottomLeft = Vector(middleLeft.x, middleLeft.y + 11, middleLeft.z)
  local txtSP = SimpleText(spName, bottomLeft, rw, 'left', small)
  local sp = battler.state.sp .. '/' .. battler.msp()
  local valueSP = SimpleText(sp, bottomLeft, rw, 'right', tiny)
  -- Status
  local topRight = Vector(topLeft.x + rw + margin + 7, topLeft.y + 8, topLeft.z - 20)
  local status = IconList(topRight, rw, 24)
  status:setIcons(battler.statusList:getIcons())
  -- Level / Class
  local middleRight = Vector(topRight.x - 7, topRight.y + 8, topRight.z)
  local level = Vocab.level .. ' ' .. battler.class.level
  local txtLevel = SimpleText(level, middleRight, rw, 'left', small)
  local txtClass = SimpleText(battler.class.data.name, middleRight, rw, 'right', small)
  -- EXP
  local bottomRight = Vector(middleRight.x, middleRight.y + 11, middleRight.z)
  local expCurrent = battler.class.expCurve(battler.class.level)
  local expNext = battler.class.expCurve(battler.class.level + 1)
  local exp = '/' .. (expNext - expCurrent)
  if battler.class.level == Config.battle.maxLevel then
    exp = (expNext - expCurrent) .. exp
  else
    exp = (battler.class.exp - expCurrent) .. exp
  end
  local txtEXP = SimpleText(Vocab.exp, bottomRight, rw, 'left', small)
  local valueEXP = SimpleText(exp, bottomRight, rw, 'right', tiny)
  
  self.content = { txtName, txtLevel, txtClass, 
    txtHP, valueHP, txtSP, valueSP,
    txtEXP, valueEXP, status }
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

-- Sets image position.
function MemberInfo:updatePosition(pos)
  if self.icon then
    self.icon:updatePosition(pos)
  end
  for i = 1, #self.content do
    self.content[i]:updatePosition(pos)
  end
end
-- Shows image.
function MemberInfo:show()
  if self.icon then
    self.icon:show()
  end
  for i = 1, #self.content do
    self.content[i]:show()
  end
end
-- Hides image.
function MemberInfo:hide()
  if self.icon then
    self.icon:hide()
  end
  for i = 1, #self.content do
    self.content[i]:hide()
  end
end
-- Destroys sprite.
function MemberInfo:destroy()
  if self.icon then
    self.icon:destroy()
  end
  for i = 1, #self.content do
    self.content[i]:destroy()
  end
end

return MemberInfo