
--[[===============================================================================================

MemberListWindow
---------------------------------------------------------------------------------------------------
A button window that shows all the visibles members in the troop.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local List = require('core/datastruct/List')
local ListButtonWindow = require('core/gui/ListButtonWindow')
local MemberGUI = require('core/gui/members/MemberGUI')
local MemberInfo = require('core/gui/general/widget/MemberInfo')
local Vector = require('core/math/Vector')

local MemberListWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Gets the member list from the troop.
-- @param(troop : TroopBase)
-- @param(...) parameters from ListButtonWindow:init
function MemberListWindow:init(troop, ...)
  self.troop = troop
  local memberList = troop:visibleMembers()
  ListButtonWindow.init(self, memberList, ...)
end
-- Overrides ListButtonWindow:createListButton.
-- Creates a button for the given member.
-- @param(member : table)
-- @ret(Button)
function MemberListWindow:createListButton(battler)
  local button = Button(self)
  local w, h = self:cellWidth(), self:cellHeight()
  local memberInfo = MemberInfo(battler, w - self:hPadding(), h)
  button.content:add(memberInfo)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Called when player presses "confirm" on this button.
-- Shows the GUI for member management.
-- @param(button : Button)
function MemberListWindow:onButtonConfirm(button)
  self.GUI:hide()
  local gui = MemberGUI(self.troop, self.list, button.index)
  GUIManager:showGUIForResult(gui)
  self.GUI:show()
end
-- @param(button : Button)
-- Called when player presses "cancel" on this button.
-- Hides this windows and shows the main window.
function MemberListWindow:onButtonCancel(button)
  self:hide()
  self.GUI.mainWindow:show()
  self.GUI.mainWindow:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function MemberListWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function MemberListWindow:rowCount()
  return 4
end
-- Overrides ListButtonWindow:cellWidth.
function MemberListWindow:cellWidth()
  return ListButtonWindow.cellWidth(self) + 100
end
-- Overrides GridWindow:cellHeight.
function MemberListWindow:cellHeight()
  return (ListButtonWindow.cellHeight(self) * 3 + self:rowMargin() * 2)
end

return MemberListWindow