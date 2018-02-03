
--[[===============================================================================================

MemberListWindow
---------------------------------------------------------------------------------------------------
A button window that shows all the visibles members in the troop.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local List = require('core/datastruct/List')
local ListButtonWindow = require('core/gui/ListButtonWindow')
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
  local memberList = troop:visibleMembers()
  ListButtonWindow.init(self, memberList, ...)
end
-- Overrides ListButtonWindow:createListButton.
-- Creates a button for the given member.
-- @param(member : table)
-- @ret(Button)
function MemberListWindow:createListButton(battler)
  local button = Button(self)
  button.member = battler
end

---------------------------------------------------------------------------------------------------
-- Member Info
---------------------------------------------------------------------------------------------------

-- Refresh each member info.
function MemberListWindow:refreshMembers()
  for i = 1, #self.matrix do
    local button = self.matrix[i]
    if button.memberInfo then
      button.memberInfo:destroy()
      button.content:removeElement(button.memberInfo)
    end
    local w, h = self:cellWidth(), self:cellHeight()
    button.memberInfo = MemberInfo(button.member, w - self:hPadding(), h)
    button.content:add(button.memberInfo)
    button:updatePosition(self.position)
  end
end
-- Overrides Window:show.
function MemberListWindow:show(...)
  if not self.open then
    self:refreshMembers()
    self:hideContent()
  end
  ListButtonWindow.show(self, ...)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Called when player presses "confirm" on this button.
-- Shows the GUI for member management.
-- @param(button : Button)
function MemberListWindow:onButtonConfirm(button)
  self.GUI:onMemberConfirm(button.index)
end
-- @param(button : Button)
-- Called when player presses "cancel" on this button.
-- Hides this windows and shows the main window.
function MemberListWindow:onButtonCancel(button)
  self.GUI:onMemberCancel()
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

function MemberListWindow:__tostring()
  return 'Member List Window'
end

return MemberListWindow