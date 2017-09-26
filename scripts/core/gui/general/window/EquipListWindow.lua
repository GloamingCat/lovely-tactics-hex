
--[[===============================================================================================

EquipListWindow
---------------------------------------------------------------------------------------------------
A window that shows the troop's members in the Equip GUI.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Vector = require('core/math/Vector')
local Button = require('core/gui/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

local EquipListWindow = class(ListButtonWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Constructor.
function EquipListWindow:init(GUI, troop)
  local list = List(troop.current)
  list:addAll(troop.backup)
  self.troop = troop
  local m = GUI:windowMargin()
  local w = ScreenManager.width / 4
  local h = ScreenManager.height * 4 / 5 - self:vPadding() * 2 - m * 3
  self.fitRowCount = math.floor(h / self:buttonHeight())
  local fith = self.fitRowCount * self:buttonHeight() + self:vPadding() * 2
  local pos = Vector(w / 2 - ScreenManager.width / 2 + m, fith / 2 - ScreenManager.height / 2 + m, 0)
  ListButtonWindow.init(self, list, GUI, w, fith, pos)
end

function EquipListWindow:createListButton(member)
  local data = self.troop:getMemberData(member.key)
  local button = Button(self, self.onButtonConfirm)
  button:createText(data.name)
  button.member = member
  button.onSelect = self.onButtonSelect
  return button
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipListWindow:onButtonSelect(button)
  self.GUI.mainWindow:setMember(button.member)
end

function EquipListWindow:onButtonConfirm(button)
  self:setSelectedButton(nil)
  self.GUI.mainWindow:activate()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

function EquipListWindow:buttonWidth()
  return self.width - self:hPadding() * 2 - self.GUI:windowMargin() * 2
end
-- Overrides GridWindow:colCount.
function EquipListWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function EquipListWindow:rowCount()
  return self.fitRowCount
end

return EquipListWindow