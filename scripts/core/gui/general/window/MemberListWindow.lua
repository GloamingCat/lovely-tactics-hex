
--[[===============================================================================================

MemberListWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

local ListButtonWindow = require('core/gui/ListButtonWindow')
--local MemberButton = require('core/gui/general/widget/MemberButton')
local Button = require('core/gui/widget/Button')

local MemberListWindow = class(ListButtonWindow)

function MemberListWindow:init(troop, ...)
  local list = troop:visibleMembers()
  ListButtonWindow.init(self, list, ...)
end

function MemberListWindow:createListButton(member)
  local button = Button(self)
  button:createText(member.key)
  return button
end

function MemberListWindow:onButtonConfirm(button)
  print('Selected member', button.index)
end

function MemberListWindow:onButtonCancel(button)
  self:hide()
  self.GUI.mainWindow:show()
  self.GUI.mainWindow:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function MemberListWindow:colCount()
  return 1
end

function MemberListWindow:rowCount()
  return 4
end

function MemberListWindow:buttonWidth()
  return 120
end

function MemberListWindow:buttonHeight()
  return 40
end

return MemberListWindow