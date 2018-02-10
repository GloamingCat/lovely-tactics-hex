
--[[===============================================================================================

EquipItemWindow
---------------------------------------------------------------------------------------------------
A window that shows the possible items to equip.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Vector = require('core/math/Vector')
local Button = require('core/gui/widget/Button')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')

-- Constans
local equipSound = Config.sounds.equip
local unequipSound = Config.sounds.unequip

local EquipItemWindow = class(InventoryWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI)
-- @param(w : number) window's width (optional)
-- @param(h : number) window's height (optional)
-- @param(pos : Vector) position of the window's center (optional)
function EquipItemWindow:init(GUI, w, h, pos, rowCount)
  self.member = GUI.memberGUI:currentMember()
  InventoryWindow.init(self, GUI, GUI.inventory, {}, w, h, pos, rowCount)
end
-- Overrides ListButtonWindow:createWidgets.
-- Adds the "unequip" button.
function EquipItemWindow:createWidgets(...)
  if self.slotKey then
    local button = Button(self)
    button:createText(Vocab.unequip, 'gui_medium')
    button:setEnabled(self.member.equipSet:canUnequip(self.slotKey))
    button.confirmSound = unequipSound
    InventoryWindow.createWidgets(self, ...)
  end
end
-- Overrides ListButtonWindow:createListButton.
function EquipItemWindow:createListButton(itemSlot)
  local button = InventoryWindow.createListButton(self, itemSlot)
  button:setEnabled(self.member.equipSet:canEquip(self.slotKey, button.item))
  button.confirmSound = equipSound
  return button
end
-- @param(member : Battler)
function EquipItemWindow:setMember(member)
  self.member = member
end
-- @param(slot : string)
function EquipItemWindow:setSlot(key, slot)
  self.slotKey = key
  self.slotType = slot
  self:refreshItems()
end
-- Refresh item buttons in case the slot changed.
function EquipItemWindow:refreshItems()
  local list = self.GUI.inventory:getEquipItems(self.slotType.key, self.member)
  self:refreshButtons(list)
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

-- Called when player selects an item button.
function EquipItemWindow:onButtonSelect(button)
  InventoryWindow.onButtonSelect(self, button)
  self.GUI.bonusWindow:setEquip(self.slotKey, button.item)
end
-- Called when player chooses an item to equip.
function EquipItemWindow:onButtonConfirm(button)
  local char = TroopManager:getBattlerCharacter(self.member)
  self.member.equipSet:setEquip(self.slotKey, button.item, self.GUI.inventory, char)
  self.GUI.memberGUI:refreshMember()
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
-- @ret(string) String representation (for debugging)
function EquipItemWindow:__tostring()
  return 'Equip Item Window'
end

return EquipItemWindow