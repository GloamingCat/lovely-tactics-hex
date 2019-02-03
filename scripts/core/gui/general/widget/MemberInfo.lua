
--[[===============================================================================================

MemberInfo
---------------------------------------------------------------------------------------------------
A container for a battler's main information.

=================================================================================================]]

-- Imports
local Gauge = require('core/gui/general/widget/Gauge')
local IconList = require('core/gui/general/widget/IconList')
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

-- Alias
local findByName = util.array.findByName

local MemberInfo = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(battler : table)
-- @param(w : number) width of the container
-- @param(h : number) height of the container
-- @param(topLeft : Vector) the position of the top left corner of the container
function MemberInfo:init(battler, w, h, topLeft)
  self.battler = battler
  topLeft = topLeft and topLeft:clone() or Vector(0, 0, 0)
  local margin = 4
  -- Icon
  local charData = Database.characters[battler.charID]
  local icon = findByName(charData.portraits, "smallIcon")
  if icon then
    local sprite = ResourceManager:loadIcon(icon, GUIManager.renderer)
    sprite:applyTransformation(charData.transform)
    self.icon = SimpleImage(sprite, topLeft.x, topLeft.y, topLeft.z, nil, h)   
    local ix, iy, iw, ih = sprite:totalBounds()
    topLeft.x = topLeft.x + iw + margin
    w = w - iw - margin
  end
  topLeft.y = topLeft.y + 1
  topLeft.z = topLeft.z - 2
  local rw = (w - margin) / 2
  local small = Fonts.gui_small
  local tiny = Fonts.gui_tiny
  local medium = Fonts.medium
  -- Name
  local txtName = SimpleText(battler.name, topLeft, rw, 'left', medium)
  -- HP
  local middleLeft = Vector(topLeft.x, topLeft.y + 17, topLeft.z)
  local txtHP = SimpleText(Vocab.hp, middleLeft, rw, 'left', small)
  -- SP
  local bottomLeft = Vector(middleLeft.x, middleLeft.y + 11, middleLeft.z)
  local txtSP = SimpleText(Vocab.sp, bottomLeft, rw, 'left', small)
  -- HP gauge
  local gaugeX = 2 + math.max(txtSP.sprite:getWidth(), txtHP.sprite:getWidth())
  local gaugeHP = Gauge(middleLeft, rw, Color.barHP, gaugeX)
  gaugeHP:setValues(battler.state.hp, battler.mhp())
  -- SP gauge
  local gaugeSP = Gauge(bottomLeft, rw, Color.barSP, gaugeX)
  gaugeSP:setValues(battler.state.sp, battler.msp())
  
  -- Status
  local topRight = Vector(topLeft.x + rw + margin + 8, topLeft.y + 8, topLeft.z - 20)
  local status = IconList(topRight, rw, 20)
  status:setIcons(battler.statusList:getIcons())
  -- Level / Class
  local middleRight = Vector(topRight.x - 7, topRight.y + 8, topRight.z)
  local level = Vocab.level .. ' ' .. battler.class.level
  local txtLevel = SimpleText(level, middleRight, rw, 'left', small)
  local txtClass = SimpleText(battler.class.data.name, middleRight, rw, 'right', small)
  -- EXP
  local bottomRight = Vector(middleRight.x, middleRight.y + 11, middleRight.z)
  local txtEXP = SimpleText(Vocab.exp, bottomRight, rw, 'left', small)
  -- EXP gauge
  local gaugeEXP = Gauge(bottomRight, rw, Color.barEXP, 2 + txtEXP.sprite:getWidth())
  local expCurrent = battler.class.expCurve(battler.class.level)
  local expNext = battler.class.expCurve(battler.class.level + 1)
  local expMax = expNext - expCurrent
  local exp = battler.class.level == Config.battle.maxLevel and expMax or battler.class.exp - expCurrent
  gaugeEXP:setValues(exp, expMax)
  
  self.content = { txtName, txtLevel, txtClass, status,
    txtHP, gaugeHP, txtSP, gaugeSP,
    txtEXP, gaugeEXP  }
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