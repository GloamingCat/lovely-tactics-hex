
--[[===============================================================================================

EquipBonusWindow
---------------------------------------------------------------------------------------------------
A window that shows the attribute and element bonus of the equip item.

=================================================================================================]]

-- Imports
local EquipSet = require('core/battle/battler/EquipSet')
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

-- Constructor.
-- @param(GUI : GUI)
-- @param(...) Other arguments to Window:init.
function EquipBonusWindow:init(GUI, ...)
  self.member = GUI.memberGUI:currentMember()
  Window.init(self, GUI, ...)
end
-- Prints a list of attributes to receive a bonus.
-- @param(att : table) Array of attributes bonus (with key, oldValue and newValue).
function EquipBonusWindow:updateBonus(att)
  for i = 1, #self.content do
    self.content[i]:destroy()
  end
  self.content = List()
  local font = Fonts.gui_small
  local x = self:hPadding() - self.width / 2
  local y = self:vPadding() - self.height / 2
  local w = self.width - self:hPadding() * 2
  -- Attributes
  for i = 1, #att do
    local key = att[i].key
    local valueW = 30
    local arrowW = 15
    local namePos = Vector(x, y, 0)
    local name = SimpleText(attConfig[key].shortName, namePos, w / 2, 'left', font)
    self.content:add(name)
    local valuePos1 = Vector(x + w / 2, y, 0)
    local value1 = SimpleText(round(att[i].oldValue), valuePos1, valueW, 'left', font)
    self.content:add(value1)
    local arrowPos = Vector(x + w / 2 + valueW, y - 2, 0)
    local arrow = SimpleText('→', arrowPos, arrowW, 'left')
    self.content:add(arrow)
    local valuePos2 = Vector(x + w / 2 + valueW + arrowW, y, 0)
    local value2 = SimpleText(round(att[i].newValue), valuePos2, valueW, 'left', font)
    self.content:add(value2)
    if att[i].newValue > att[i].oldValue then
      value2.sprite:setColor(Color.green)
    else
      value2.sprite:setColor(Color.red)
    end
    y = y + 10
  end
  for i = 1, #self.content do
    self.content[i]:updatePosition(self.position)
  end
end
-- Shows the bonus for this item when equipped in the given slot.
-- @param(slotKey : string) Key of the slot to be changed.
-- @param(newEquip : table) Item's data from Database (nil to unequip).
function EquipBonusWindow:setEquip(slotKey, newEquip)
  self.equip = newEquip
  self.slotKey = slotKey
  -- Attribute Bonus
  local currentSet = self.member.equipSet
  local save = { equips = currentSet:getState() }
  local simulationSet = EquipSet(nil, save)
  simulationSet:setEquip(slotKey, newEquip)
  local bonusList = {}
  for i = 1, #attConfig do
    local key = attConfig[i].key
    local oldValue = self.member.att[key]()
    self.member.equipSet = simulationSet
    local newValue = self.member.att[key]()
    self.member.equipSet = currentSet
    if oldValue ~= newValue then
      bonusList[#bonusList + 1] = {
        oldValue = oldValue,
        newValue = newValue,
        key = key }
    end
  end
  self:updateBonus(bonusList)
end
-- @param(member : Battler) The owner of the current equipment set.
--  It is necessary so the attribute to calculate the attribute bonus.
function EquipBonusWindow:setMember(member)
  self.member = member
  self:setEquip(self.slotKey, self.equip)
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

-- @ret(string) String representation (for debugging)
function EquipBonusWindow:__tostring()
  return 'Equip Bonus Window'
end

return EquipBonusWindow