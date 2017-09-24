
--[[===============================================================================================

EquipItemWindow
---------------------------------------------------------------------------------------------------
A window that shows the possible items to equip.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Vector = require('core/math/Vector')
local Button = require('core/gui/Button')
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
  ListButtonWindow.init(self, {}, GUI, w, h, pos)
end

function EquipItemWindow:createButton(itemID)
  local data = Database.items[itemID]
  local button = Button(self, data.name, nil, self.onButtonConfirm)
  button.item = data
  button.onSelect = self.onButtonSelect
  return button
end

function EquipItemWindow:setSlot(member, slot)
  
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipItemWindow:onButtonSelect(button)
  -- TODO: show info in DescriptionWindow
end

function EquipItemWindow:onButtonConfirm(button)
  -- TODO: equip item
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