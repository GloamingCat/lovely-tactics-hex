
--[[===============================================================================================

MenuTargetGUI
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MemberWindow = require('core/gui/members/window/MemberWindow')
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
  self.MemberWindow = MemberWindow(self.troop, self)
  if self.position then
    self.MemberWindow:setPosition(self.position)
  end
  self:setActiveWindow(self.MemberWindow)
end

---------------------------------------------------------------------------------------------------
-- Member Input
---------------------------------------------------------------------------------------------------

-- When player selects a character from the member list window.
-- @param(index : number) the index of the button
function MenuTargetGUI:onMemberConfirm(index)
  self.input.target = self.MemberWindow.list[index]
  local result = self.input.action:menuUse(self.input)
  if result.executed then
    self.MemberWindow:refreshMembers()
    self:updateEnabled()
  end
end
-- When player cancels from the member list window.
function MenuTargetGUI:onMemberCancel()
  self.MemberWindow.result = 1
end
-- Sets the button as enabled according to the skill.
-- @param(input : ActionInput)
function MenuTargetGUI:updateEnabled()
  local enabled = self.input.action:canMenuUse(self.input.user)
  local buttons = self.MemberWindow.matrix
  for i = 1, #buttons do
    buttons[i]:setEnabled(enabled)
  end
end

return MenuTargetGUI
