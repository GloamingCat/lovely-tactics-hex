
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
function EquipItemWindow:init(GUI, w, h, rowCount, troop)
  self.troop = troop
  local m = GUI:windowMargin()
  self.fitRowCount = rowCount
  local pos = Vector(ScreenManager.width / 2 - w / 2 - m, h / 2 - ScreenManager.height / 2 + m, 0)
  self.slot = Config.equipTypes[1]
  ListButtonWindow.init(self, {}, GUI, w, h, pos)
end

function EquipItemWindow:createButtons()
  local button = Button(self, self.onButtonConfirm, self.onButtonSelect)
  button:createText(Vocab.unequip, 'gui_medium')
  ListButtonWindow.createButtons(self)
end

function EquipItemWindow:createListButton(itemID)
  local data = Database.items[itemID]
  local button = Button(self, self.onButtonConfirm, self.onButtonSelect)
  button:createText(data.name)
  button.item = data
  return button
end
-- @param(data : table)
function EquipItemWindow:setMember(member, data)
  self.memberData = data
end
-- @param(slot : string)
function EquipItemWindow:setSlot(key, slot)
  self.slot = slot
  self.slotKey = key
  -- Override buttons to show the item for the given slot
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipItemWindow:onButtonSelect(button)
  if button.item then
    self.GUI.descriptionWindow:setText(button.item.description)
  else
    self.GUI.descriptionWindow:setText('')
  end
end

function EquipItemWindow:onButtonConfirm(button)
  if button.item then
    self.memberData.equipment[self.slotKey].id = button.item.id
  else
    self.memberData.equipment[self.slotKey].id = -1
  end
  self:setSelectedButton(nil)
  self.GUI.slotWindow:activate()
end

function EquipItemWindow:onCancel()
  self:setSelectedButton(nil)
  self.GUI.slotWindow:activate()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

function EquipItemWindow:buttonWidth()
  return self.width - self:hPadding() * 2 - self.GUI:windowMargin() * 2
end
-- Overrides GridWindow:colCount.
function EquipItemWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function EquipItemWindow:rowCount()
  return self.fitRowCount
end

return EquipItemWindow