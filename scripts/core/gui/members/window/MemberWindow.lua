
--[[===============================================================================================

MemberWindow
---------------------------------------------------------------------------------------------------
A button window that shows all the visibles members in the troop.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/control/Button')
local List = require('core/datastruct/List')
local ListWindow = require('core/gui/ListWindow')
local MemberInfo = require('core/gui/widget/data/MemberInfo')
local Vector = require('core/math/Vector')

local MemberWindow = class(ListWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Gets the member list from the troop.
-- @param(troop : TroopBase)
-- @param(...) parameters from ListWindow:init
function MemberWindow:init(troop, ...)
  local memberList = troop:visibleMembers()
  ListWindow.init(self, memberList, ...)
end
-- Overrides ListWindow:createListButton.
-- Creates a button for the given member.
-- @param(member : table)
-- @ret(Button)
function MemberWindow:createListButton(battler)
  local button = Button(self)
  button.member = battler
end

---------------------------------------------------------------------------------------------------
-- Member Info
---------------------------------------------------------------------------------------------------

-- Refresh each member info.
function MemberWindow:refreshMembers()
  for i = 1, #self.matrix do
    local button = self.matrix[i]
    if button.memberInfo then
      button.memberInfo:destroy()
      button.content:removeElement(button.memberInfo)
    end
    local w, h = self:cellWidth(), self:cellHeight()
    button.memberInfo = MemberInfo(button.member, w - self:paddingX(), h)
    button.content:add(button.memberInfo)
    button:updatePosition(self.position)
  end
end
-- Overrides Window:show.
function MemberWindow:show(...)
  if not self.open then
    self:refreshMembers()
    self:hideContent()
  end
  ListWindow.show(self, ...)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Called when player presses "confirm" on this button.
-- Shows the GUI for member management.
-- @param(button : Button)
function MemberWindow:onButtonConfirm(button)
  self.GUI:onMemberConfirm(button.index)
end
-- @param(button : Button)
-- Called when player presses "cancel" on this button.
-- Hides this windows and shows the main window.
function MemberWindow:onButtonCancel(button)
  self.GUI:onMemberCancel()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function MemberWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function MemberWindow:rowCount()
  return 4
end
-- Overrides ListWindow:cellWidth.
function MemberWindow:cellWidth()
  return ListWindow.cellWidth(self) + 101
end
-- Overrides GridWindow:cellHeight.
function MemberWindow:cellHeight()
  return (ListWindow.cellHeight(self) * 3 + self:rowMargin() * 2)
end
-- @ret(string) String representation (for debugging).
function MemberWindow:__tostring()
  return 'Member List Window'
end

return MemberWindow