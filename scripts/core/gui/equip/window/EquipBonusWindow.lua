
--[[===============================================================================================

EquipBonusWindow
---------------------------------------------------------------------------------------------------
A window that shows the attribute and element bonus of the equip item.

=================================================================================================]]

-- Imports
local IconList = require('core/gui/general/widget/IconList')
local List = require('core/datastruct/List')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Alias
local round = math.round

-- Constants
local attConfig = Config.attributes
local equipTypes = Config.equipTypes

local EquipBonusWindow = class(Window)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

function EquipBonusWindow:updateBonus(bonusList)
  for i = 1, #self.content do
    self.content[i]:destroy()
  end
  self.content = List()
  local font = Fonts.gui_small
  local x = self:hPadding() - self.width / 2
  local y = self:vPadding() - self.height / 2
  local w = self.width / 2 - self:hPadding()
  -- Attributes
  for i = 1, #bonusList do
    local key = bonusList[i].key
    local valueW = 40
    local namePos = Vector(x, y, 0)
    local name = SimpleText(attConfig[key].shortName, namePos, w / 2, 'left', font)
    self.content:add(name)
    local valuePos1 = Vector(x + w / 2, y, 0)
    local value1 = SimpleText(round(bonusList[i].oldValue), valuePos1, valueW, 'left', font)
    self.content:add(value1)
    local valuePos2 = Vector(x + w / 2 + valueW, y, 0)
    local value2 = SimpleText(round(bonusList[i].newValue), valuePos2, valueW, 'left', font)
    self.content:add(value2)
    y = y + 10
  end
  for i = 1, #self.content do
    self.content[i]:updatePosition(self.position)
  end
end

function EquipBonusWindow:setEquip(slotKey, newEquip)
  self.equip = newEquip
  self.slotKey = slotKey
  local base, oldBonus, newBonus = self:calculateBonus(slotKey, newEquip and newEquip.equip)
  local bonusList = {}
  for i = 1, #attConfig do
    local key = attConfig[i].key
    if oldBonus[key] ~= newBonus[key] then
      bonusList[#bonusList + 1] = {
        oldValue = base[key] + oldBonus[key],
        newValue = base[key] + newBonus[key],
        key = key }
    end
  end
  self:updateBonus(bonusList)
end

function EquipBonusWindow:setMember(member)
  self.member = member
  self:setEquip(self.slotKey, self.equip)
end

----------------------------------------------------------------------------------------------------
-- Calculate Bonus
----------------------------------------------------------------------------------------------------

function EquipBonusWindow:calculateBonus(slotKey, newEquip)
  local base = self:baseAttributes()
  -- Unequip
  if not newEquip then
    local oldEquip = self.member.equipSet:getEquip(slotKey)
    local oldBonus = self:equipAttributes(base, oldEquip and oldEquip.equip)
    return base, oldBonus, self:equipAttributes(base)
  end
  -- New equip
  local newBonus = self:equipAttributes(base, newEquip)
  local oldBonus = self:equipAttributes(base, nil)
  -- Slots to be unequiped
  local unequipSlots = {}
  for i = 1, #newEquip.block do
    local key = newEquip.block[i]
    self:insertSlots(unequipSlots, key)
  end
  if newEquip.allSlots then
    self:insertSlots(unequipSlots, newEquip.type)
  else
    unequipSlots[slotKey] = true
  end
  -- Merge bonus
  for slot in pairs(unequipSlots) do
    local item = self.member.equipSet:getEquip(slot)
    if item then
      local bonus = self:equipAttributes(base, item and item.equip)
      for i = 1, #attConfig do
        local k = attConfig[i].key
        oldBonus[k] = oldBonus[k] + bonus[k]
      end
    end
  end
  return base, oldBonus, newBonus
end

function EquipBonusWindow:insertSlots(slots, key)
  if not equipTypes[key] then
    slots[key] = true
  else
    for i = 1, equipTypes[key].count do
      local keyi = key .. i
      slots[keyi] = true
    end
  end
end

function EquipBonusWindow:baseAttributes()
  local base = {}
  for i = 1, #attConfig do
    local key = attConfig[i].key
    base[key] = self.member.att:getBase(key)
  end
  return base
end

function EquipBonusWindow:equipAttributes(base, equip)
  local att = {}
  if equip then
    local add, mul = self.member.equipSet:equipAttributes(equip)
    for i = 1, #attConfig do
      local key = attConfig[i].key
      att[key] = (add[key] or 0) + (mul[key] or 0) * base[key]
    end
  else
    for i = 1, #attConfig do
      local key = attConfig[i].key
      att[key] = 0
    end
  end
  return att
end

-- @ret(string) string representation (for debugging)
function EquipBonusWindow:__tostring()
  return 'Equip Bonus Window'
end

return EquipBonusWindow