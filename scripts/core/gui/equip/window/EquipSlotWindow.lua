
--[[===============================================================================================

EquipSlotWindow
---------------------------------------------------------------------------------------------------
The window that shows each equipment slot.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/SimpleText')
local Button = require('core/gui/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

-- Alias
local max = math.max

local EquipSlotWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipSlotWindow:init(GUI, w, h, pos, rows, member)
  self.fitRowCount = rows
  ListButtonWindow.init(self, Config.equipTypes, GUI, w, h, pos)
  self.member = member
  self:setSelectedButton(nil)
end
-- @param(slot : table)
function EquipSlotWindow:createListButton(slot)
  for i = 1, slot.count do
    local button = Button(self, self.onButtonConfirm, self.onButtonSelect)
    local w = self:buttonWidth()
    button:createText(slot.name, 'gui_medium', 'left', w / 3)
    button:createInfoText(Vocab.empty, 'gui_medium', 'left', w / 3 * 2, Vector(w / 3, 1, 0))
    button.key = slot.key .. i
    button.slot = slot
  end
end

function EquipSlotWindow:setMember(member)
  self.member = member
  for i = 1, #self.buttonMatrix do
    local button = self.buttonMatrix[i]
    local slot = self.member.data.equipment[button.key]
    local name = Vocab.empty
    if slot and slot.id >= 0 then
      local item = Database.items[slot.id]
      name = item.name
    end
    button:setInfoText(name)
    button:setEnabled(slot.freedom ~= 0)
  end
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipSlotWindow:onButtonConfirm(button)
  self:setSelectedButton(nil)
  self.GUI.itemWindow:activate()
end

function EquipSlotWindow:onButtonSelect(button)
  self.GUI.itemWindow:setSlot(button.key, button.slot)
end

function EquipSlotWindow:onCancel()
  self:setSelectedButton(nil)
  self.GUI.memberWindow:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function EquipSlotWindow:colCount()
  return 1
end

function EquipSlotWindow:rowCount()
  return self.fitRowCount
end

function EquipSlotWindow:buttonWidth()
  return self.width - self:hPadding() * 2
end

function EquipSlotWindow:__tostring()
  return 'EquipSlotWindow'
end

return EquipSlotWindow