
--[[===============================================================================================

MainGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned when player presses the menu button in the field.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MainWindow = require('core/gui/field/window/MainWindow')
local MemberGUI = require('core/gui/members/MemberGUI')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local Troop = require('core/battle/Troop')

local MainGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides GUI:createWindows.
function MainGUI:createWindows()
  self.name = 'Main GUI'
  self.troop = Troop()
  self:createMainWindow()
  self:createMembersWindow()
end
-- Creates the list with the main commands.
function MainGUI:createMainWindow()
  local w = MainWindow(self)
  local m = self:windowMargin()
  w:setXYZ((w.width - ScreenManager.width) / 2 + m, (w.height - ScreenManager.height) / 2 + m)
  self.mainWindow = w
  self:setActiveWindow(self.mainWindow)
end
-- Creates the member list window the shows when player selects "Characters" button.
function MainGUI:createMembersWindow()
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end

---------------------------------------------------------------------------------------------------
-- Member Input
---------------------------------------------------------------------------------------------------

-- When player selects a character from the member list window.
-- @param(index : number) the index of the button
function MainGUI:onMemberConfirm(index)
  self:hide()
  local gui = MemberGUI(self.troop, self.membersWindow.list, index)
  GUIManager:showGUIForResult(gui)
  self:show()
end
-- When player cancels from the member list window.
function MainGUI:onMemberCancel()
  self.membersWindow:hide()
  self.mainWindow:show()
  self.mainWindow:activate()
end

return MainGUI