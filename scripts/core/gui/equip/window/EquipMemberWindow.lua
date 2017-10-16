
--[[===============================================================================================

EquipMemberWindow
---------------------------------------------------------------------------------------------------
A window that shows the troop's members in the Equip GUI.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Vector = require('core/math/Vector')
local Button = require('core/gui/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

local EquipMemberWindow = class(ListButtonWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Constructor.
function EquipMemberWindow:init(GUI, troop)
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

function EquipMemberWindow:createListButton(member)
  local data = self.troop:getMemberData(member.key)
  local button = Button(self, self.onButtonConfirm, self.onButtonSelect)
  button:createText(data.name)
  button.member = member
  button.memberData = data
  return button
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipMemberWindow:onButtonSelect(button)
  self.GUI.slotWindow:setMember(button.member, button.memberData)
  self.GUI.itemWindow:setMember(button.member, button.memberData)
end

function EquipMemberWindow:onButtonConfirm(button)
  self:setSelectedButton(nil)
  self.GUI.slotWindow:activate()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

function EquipMemberWindow:buttonWidth()
  return self.width - self:hPadding() * 2 - self.GUI:windowMargin() * 2
end
-- Overrides GridWindow:colCount.
function EquipMemberWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function EquipMemberWindow:rowCount()
  return self.fitRowCount
end

return EquipMemberWindow