
--[[===============================================================================================

EquipSlotWindow
---------------------------------------------------------------------------------------------------
The window that shows each equipment slot.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/widget/SimpleText')
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

-- Alias
local max = math.max
local min = math.min

local EquipSlotWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipSlotWindow:init(GUI)
  self.visibleRowCount = 0
  for i = 1, #Config.equipTypes do
    self.visibleRowCount = Config.equipTypes[i].count + self.visibleRowCount
  end
  self.visibleRowCount = min(6, max(self.visibleRowCount, 4))
  ListButtonWindow.init(self, Config.equipTypes, GUI)
  local x = GUI:windowMargin() - ScreenManager.width / 2 + self.width / 2
  local y = GUI.initY + self.height / 2 - ScreenManager.height / 2
  self:setXYZ(x, y)
end
-- @param(slot : table)
function EquipSlotWindow:createListButton(slot)
  for i = 1, slot.count do
    local button = Button(self)
    local w = self:cellWidth()
    button:createText(slot.name, 'gui_medium', 'left', w / 3)
    button:createInfoText(Vocab.empty, 'gui_medium', 'left', w / 3 * 2, Vector(w / 3, 1, 0))
    button.key = slot.key .. i
    button.slot = slot
  end
end

function EquipSlotWindow:setMember(member)
  self.member = member
  for i = 1, #self.matrix do
    local button = self.matrix[i]
    local slot = self.member.data.equipment[button.key]
    local name = Vocab.empty
    if slot and slot.id >= 0 then
      local item = Database.items[slot.id]
      name = item.name
    end
    button:setInfoText(name)
    button:setEnabled(slot.freedom ~= 0)
  end
  local button = self:currentButton()
  self.GUI.itemWindow:setSlot(button.key, button.slot)
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipSlotWindow:onButtonConfirm(button)
  self:hide()
  self.GUI.itemWindow:show()
  self.GUI.itemWindow:activate()
end

function EquipSlotWindow:onButtonSelect(button)
  self.GUI.itemWindow:setSlot(button.key, button.slot)
end

function EquipSlotWindow:onButtonCancel()
  self.result = 0
end
-- Called when player presses "next" key.
function EquipSlotWindow:onNext()
  self.GUI.memberGUI:nextMember()
end
-- Called when player presses "prev" key.
function EquipSlotWindow:onPrev()
  self.GUI.memberGUI:prevMember()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function EquipSlotWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function EquipSlotWindow:rowCount()
  return self.visibleRowCount
end

function EquipSlotWindow:__tostring()
  return 'EquipSlotWindow'
end

return EquipSlotWindow