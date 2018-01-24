
--[[===============================================================================================

EquipItemWindow
---------------------------------------------------------------------------------------------------
A window that shows the possible items to equip.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Vector = require('core/math/Vector')
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

local EquipItemWindow = class(ListButtonWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Constructor.
function EquipItemWindow:init(GUI, w, h, pos, rowCount)
  self.slot = Config.equipTypes[1]
  self.visibleRowCount = rowCount
  ListButtonWindow.init(self, {}, GUI, w, h, pos)
end

function EquipItemWindow:createWidgets(...)
  local button = Button(self)
  button:createText(Vocab.unequip, 'gui_medium')
  ListButtonWindow.createWidgets(self, ...)
end

function EquipItemWindow:createListButton(itemSlot)
  local item = Database.items[itemSlot.id]
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self)
  button:createText(item.name, 'gui_medium')
  button:createIcon(icon)
  button.item = item
  button:createInfoText(itemSlot.count, 'gui_medium')
  return button
end
-- @param(data : table)
function EquipItemWindow:setMember(member)
  self.member = member
  --self:refreshItems()
end
-- @param(slot : string)
function EquipItemWindow:setSlot(key, slot)
  self.slot = slot
  self.slotKey = key
  self:refreshItems()
end

function EquipItemWindow:refreshItems()
  local list = self.GUI.troop.inventory:getEquipItems(self.slotKey, self.member)
  self:overrideButtons(list)
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

-- Called when player selects an item button.
function EquipItemWindow:onButtonSelect(button)
  if button.item then
    self.GUI.descriptionWindow:setText(button.item.description)
  else
    self.GUI.descriptionWindow:setText('')
  end
end
-- Called when player chooses an item to equip.
function EquipItemWindow:onButtonConfirm(button)
  self.member.equipSet:setEquip(self.slotKey, button.item, self.GUI.troop.inventory)
  self.GUI.slotWindow:refreshSlots()
  self:showSlotWindow()
end
-- Called when player cancels and returns to the slot window.
function EquipItemWindow:onButtonCancel()
  self:showSlotWindow()
end
-- Closes this window and shows the previous one (Equip Slot Window).
function EquipItemWindow:showSlotWindow()
  self:hide()
  self.GUI.slotWindow:show()
  self.GUI.slotWindow:activate()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function EquipItemWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function EquipItemWindow:rowCount()
  return self.visibleRowCount
end

function EquipItemWindow:__tostring()
  return 'EquipItemWindow'
end

return EquipItemWindow