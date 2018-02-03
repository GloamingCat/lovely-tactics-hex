
--[[===============================================================================================

MenuTargetGUI
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local Vector = require('core/math/Vector')

local MenuTargetGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(input : ActionInput)
function MenuTargetGUI:init(troop)
  self.name = 'Confirm GUI'
  self.troop = troop
  GUI.init(self)
end
-- Overrides GUI:createWindow.
function MenuTargetGUI:createWindows()
  self.memberListWindow = MemberListWindow(self.troop, self)
  if self.position then
    self.memberListWindow:setPosition(self.position)
  end
  self:setActiveWindow(self.memberListWindow)
end

---------------------------------------------------------------------------------------------------
-- Member Input
---------------------------------------------------------------------------------------------------

-- When player selects a character from the member list window.
-- @param(index : number) the index of the button
function MenuTargetGUI:onMemberConfirm(index)
  self.input.target = self.memberListWindow.list[index]
  local result = self.input.action:menuUse(self.input)
  if result.executed then
    self.memberListWindow:refreshMembers()
    self:updateEnabled()
  end
end
-- When player cancels from the member list window.
function MenuTargetGUI:onMemberCancel()
  self.memberListWindow.result = 1
end
-- Sets the button as enabled according to the skill.
-- @param(input : ActionInput)
function MenuTargetGUI:updateEnabled()
  local enabled = self.input.action:canMenuUse(self.input.user)
  local buttons = self.memberListWindow.matrix
  for i = 1, #buttons do
    buttons[i]:setEnabled(enabled)
  end
end

return MenuTargetGUI
