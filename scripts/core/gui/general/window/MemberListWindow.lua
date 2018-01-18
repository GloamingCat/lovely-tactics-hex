
--[[===============================================================================================

MemberListWindow
---------------------------------------------------------------------------------------------------
A button window that shows all the visibles members in the troop.

=================================================================================================]]

-- Imports
local MemberGUI = require('core/gui/members/MemberGUI')
local ListButtonWindow = require('core/gui/ListButtonWindow')
local Button = require('core/gui/widget/Button')
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
  local list = troop:visibleMembers()
  ListButtonWindow.init(self, list, ...)
end
-- Overrides ListButtonWindow:createListButton.
-- Creates a button for the given member.
-- @param(member : table)
-- @ret(Button)
function MemberListWindow:createListButton(member)
  local button = Button(self)
  local w, h = self:cellWidth(), self:cellHeight()
  local memberInfo = MemberInfo(member, w, h)
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
  local gui = MemberGUI(self.list, button.index)
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
-- Overrides ListButtonWindow:cellHeight.
function MemberListWindow:cellHeight()
  return ListButtonWindow.cellHeight(self) * 2
end

return MemberListWindow